import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';
import 'dart:convert';

import '../controller/airlines_controller.dart';

class FlightDetailsScreen extends StatefulWidget {
  final String flightNumber;
  final String airLianceName;
  final String date;
  const FlightDetailsScreen({
    super.key,
    required this.airLianceName,
    required this.flightNumber,
    required this.date,
  });

  @override
  State<FlightDetailsScreen> createState() => _FlightDetailsScreenState();
}

class _FlightDetailsScreenState extends State<FlightDetailsScreen> {
  late AirlinesController controller;
  String iataCode = "";
  LatLng? departureLocation;
  LatLng? arrivalLocation;
  bool isLoadingLocations = false;
  final MapController _mapController = MapController();

  @override
  initState() {
    super.initState();
    Get.find<GoogleAdsController>().showAds();
    controller = Get.find<AirlinesController>();
    init();
  }

  Future<void> init() async {
    try {
      controller.isDetailLoading.value = true;

      iataCode = await controller.getIataCodeByAirlineName(
        widget.airLianceName,
      );
      await controller.flightDetails(
        airLianceName: widget.airLianceName,
        flightNumber: widget.flightNumber,
        date: widget.date,
      );
      await _loadAirportLocations();
    } catch (e) {
      setState(() {
        isLoadingLocations = false;
        controller.isDetailLoading.value = false;
      });
    } finally {
      controller.isDetailLoading.value = false;
    }
  }

  Future<void> _loadAirportLocations() async {
    if (!mounted) return;

    setState(() {
      isLoadingLocations = true;
    });

    try {
      final departure = controller.departure.value;
      final arrival = controller.arrival.value;

      final depCoords = await _getAirportCoordinates(departure.airportName);
      final arrCoords = await _getAirportCoordinates(arrival.airportName);

      if (mounted) {
        setState(() {
          departureLocation = depCoords;
          arrivalLocation = arrCoords;
          isLoadingLocations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingLocations = false;
        });
      }
    }
  }

  Future<LatLng?> _getAirportCoordinates(String airportName) async {
    final airportCode = extractAirportCode(airportName);
    if (airportCode.isNotEmpty) {
      try {
        final coords = await _getCoordinatesFromAirportCode(airportCode);
        if (coords != null) return coords;
      } catch (e) {
        setState(() {
          isLoadingLocations = false;
        });
      }
    }

    try {
      List<Location> locations = await locationFromAddress(airportName);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      setState(() {
        isLoadingLocations = false;
      });
    }

    final airportNameOnly = extractAirportName(airportName);
    if (airportNameOnly.isNotEmpty && airportNameOnly != airportName) {
      try {
        final query = '$airportNameOnly airport';
        List<Location> locations = await locationFromAddress(query);
        if (locations.isNotEmpty) {
          return LatLng(locations.first.latitude, locations.first.longitude);
        }
      } catch (e) {
        setState(() {
          isLoadingLocations = false;
        });
      }
    }

    if (airportCode.isNotEmpty) {
      try {
        final query = '$airportCode airport';
        List<Location> locations = await locationFromAddress(query);
        if (locations.isNotEmpty) {
          return LatLng(locations.first.latitude, locations.first.longitude);
        }
      } catch (e) {
        setState(() {
          isLoadingLocations = false;
        });
      }
    }

    return null;
  }

  Future<LatLng?> _getCoordinatesFromAirportCode(String airportCode) async {
    try {
      final url = Uri.parse('https://avwx.rest/api/station/$airportCode');
      final response = await http.get(
        url,
        headers: {'User-Agent': 'AirlinesApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['latitude'] != null && data['longitude'] != null) {
          final lat = data['latitude'] is double
              ? data['latitude']
              : double.tryParse(data['latitude'].toString());
          final lon = data['longitude'] is double
              ? data['longitude']
              : double.tryParse(data['longitude'].toString());

          if (lat != null && lon != null && lat != 0 && lon != 0) {
            return LatLng(lat, lon);
          }
        }
      }
    } catch (e) {
      setState(() {
        isLoadingLocations = false;
      });
    }

    try {
      final url = Uri.parse(
        'https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final lines = response.body.split('\n');
        for (var line in lines) {
          if (line.isEmpty || !line.contains(airportCode)) continue;

          final parts = _parseCsvLine(line);
          if (parts.length >= 8) {
            final iata = parts[4].replaceAll('"', '').trim();
            if (iata == airportCode) {
              try {
                final latStr = parts[6].replaceAll('"', '').trim();
                final lonStr = parts[7].replaceAll('"', '').trim();
                final lat = double.tryParse(latStr);
                final lon = double.tryParse(lonStr);

                if (lat != null && lon != null && lat != 0 && lon != 0) {
                  return LatLng(lat, lon);
                }
              } catch (e) {
                setState(() {
                  isLoadingLocations = false;
                });
                continue;
              }
            }
          }
        }
      }
    } catch (e) {
      setState(() {
        isLoadingLocations = false;
      });
    }

    return null;
  }

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    var current = '';
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current);
        current = '';
      } else {
        current += char;
      }
    }
    result.add(current);
    return result;
  }

  String extractAirportCode(String airportName) {
    final regex = RegExp(r'\(([A-Z]{3})\)');
    final match = regex.firstMatch(airportName);
    return match?.group(1) ?? '';
  }

  String extractAirportName(String airportName) {
    final regex = RegExp(r'^(.+?)\s*\([A-Z]{3}\)');
    final match = regex.firstMatch(airportName);
    return match?.group(1)?.trim() ?? airportName;
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF1E3A8A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF0F172A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Flight ${widget.flightNumber}',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh details',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => controller.flightDetails(
              airLianceName: widget.airLianceName,
              flightNumber: widget.flightNumber,
              date: widget.date,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEFF4FF), Color(0xFFF8FAFC)],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Obx(() {
              if (controller.isDetailLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1E3A8A),
                    strokeWidth: 2.2,
                  ),
                );
              }

              final departure = controller.departure.value;
              final arrival = controller.arrival.value;

              final departureCode = extractAirportCode(departure.airportName);
              final arrivalCode = extractAirportCode(arrival.airportName);
              final departureName = extractAirportName(departure.airportName);
              final arrivalName = extractAirportName(arrival.airportName);

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: SingleChildScrollView(
                  key: const ValueKey('details'),
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                  child: Column(
                    children: [
                      _buildCombinedFlightCard(
                        accent: accent,
                        departureCode: departureCode,
                        departureName: departureName,
                        arrivalCode: arrivalCode,
                        arrivalName: arrivalName,
                        departureTime: departure.scheduledDeparture,
                        arrivalTime: arrival.scheduledArrival,
                      ),
                      const SizedBox(height: 10),
                      // Map
                      if (departureLocation != null && arrivalLocation != null)
                        _buildMapCard(accent)
                      else if (isLoadingLocations)
                        _buildLoadingMapCard(),
                      const SizedBox(height: 10),
                      _buildInfoSection(
                        accent: accent,
                        departureName: departureName,
                        arrivalName: arrivalName,
                        departure: departure,
                        arrival: arrival,
                      ),

                      // Quick Actions
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildCombinedFlightCard({
    required Color accent,
    required String departureCode,
    required String departureName,
    required String arrivalCode,
    required String arrivalName,
    required String departureTime,
    required String arrivalTime,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF1E3A8A),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Airline Info & Status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.flight_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.airLianceName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 0),
                    Text(
                      '${iataCode.isNotEmpty ? "$iataCode-" : ""}${widget.flightNumber} • ${widget.date}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Route: Departure & Arrival
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.flight_takeoff_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Departure',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      departureCode,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      departureName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            departureTime,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Flight Path Visualization
              Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.6),
                              Colors.white.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.flight_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Arrival',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.flight_land_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      arrivalCode,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      arrivalName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.end,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.flag_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            arrivalTime,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard(Color accent) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Color(0xFF1E3A8A),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        child: Stack(
          children: [
            // Header overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.map_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Flight Route',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Map
            Positioned(
              top: 48,
              left: 0,
              right: 0,
              bottom: 0,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCameraFit: CameraFit.bounds(
                    bounds: LatLngBounds(departureLocation!, arrivalLocation!),
                    padding: const EdgeInsets.all(24),
                  ),
                  minZoom: 2.0,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'airlines',
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [departureLocation!, arrivalLocation!],
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: departureLocation!,
                        width: 32,
                        height: 32,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF10B981),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.flight_takeoff_rounded,
                            size: 14,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                      Marker(
                        point: arrivalLocation!,
                        width: 32,
                        height: 32,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF3B82F6),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.flight_land_rounded,
                            size: 14,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Zoom controls
            Positioned(
              right: 8,
              top: 48,
              child: Column(
                children: [
                  _buildZoomButton(
                    icon: Icons.add_rounded,
                    onPressed: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  _buildZoomButton(
                    icon: Icons.remove_rounded,
                    onPressed: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMapCard() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Color(0xFF1E3A8A),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: const [
                Icon(Icons.map_rounded, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'Flight Route',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required Color accent,
    required String departureName,
    required String arrivalName,
    required dynamic departure,
    required dynamic arrival,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF1E3A8A),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Flight information',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoTile(
                  title: 'Departure',
                  color: const Color(0xFF10B981),
                  airport: departureName,
                  date: departure.departureDate,
                  primaryTime: departure.scheduledDeparture,
                  primaryTimeLabel: 'Scheduled Departure',
                  secondaryTime: departure.actualDeparture,
                  secondaryTimeLabel: 'Actual Departure',
                  terminal: departure.terminal,
                  gate: departure.gate,
                  alignEnd: false,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInfoTile(
                  title: 'Arrival',
                  color: const Color(0xFF3B82F6),
                  airport: arrivalName,
                  date: arrival.arrivalDate,
                  primaryTime: arrival.scheduledArrival,
                  primaryTimeLabel: 'Scheduled Arrival',
                  secondaryTime: arrival.estimatedArrival,
                  secondaryTimeLabel: 'Estimated Arrival',
                  terminal: arrival.terminal,
                  gate: arrival.gate,
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required Color color,
    required String airport,
    required String date,
    required String primaryTime,
    required String primaryTimeLabel,
    required String secondaryTime,
    required String secondaryTimeLabel,
    required String terminal,
    required String gate,
    required bool alignEnd,
  }) {
    String formatted(String value) => value.isEmpty ? '—' : value;
    TextAlign textAlign = alignEnd ? TextAlign.end : TextAlign.start;
    CrossAxisAlignment align = alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    MainAxisAlignment mainAlign = alignEnd
        ? MainAxisAlignment.end
        : MainAxisAlignment.start;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Row(
            mainAxisAlignment: mainAlign,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  title == 'Arrival'
                      ? Icons.flight_land_rounded
                      : Icons.flight_takeoff_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            airport,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: textAlign,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: mainAlign,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 12,
                color: Colors.white.withOpacity(0.85),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  formatted(date),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: textAlign,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Scheduled Time with Label
          Column(
            crossAxisAlignment: align,
            children: [
              Text(
                primaryTimeLabel,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: textAlign,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: mainAlign,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    formatted(primaryTime),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Actual/Estimated Time with Label
          Column(
            crossAxisAlignment: align,
            children: [
              Text(
                secondaryTimeLabel,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: textAlign,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: mainAlign,
                children: [
                  Icon(
                    title == 'Arrival'
                        ? Icons.query_builder_rounded
                        : Icons.timer_rounded,
                    size: 12,
                    color: Colors.white.withOpacity(0.85),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      formatted(secondaryTime),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: textAlign,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: mainAlign,
            children: [
              Icon(
                Icons.apartment_rounded,
                size: 12,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 6),
              Text(
                'Terminal ${formatted(terminal)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: mainAlign,
            children: [
              Icon(
                Icons.meeting_room_rounded,
                size: 12,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(width: 6),
              Text(
                'Gate ${formatted(gate)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label}) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.3),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: const Color(0xFF1E3A8A)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onPressed,
          child: Icon(icon, size: 16, color: const Color(0xFF1E3A8A)),
        ),
      ),
    );
  }
}
