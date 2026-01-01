import 'dart:async';
import 'dart:convert';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';
import 'package:usa_gas_price/model/airport_map_model.dart';

class MapScreen extends StatefulWidget {
  final String? selectedCountryCode;

  const MapScreen({super.key, this.selectedCountryCode});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<AirportMap> _allAirports = []; // Store all loaded airports
  List<AirportMap> _visibleAirports =
      []; // Only airports visible in current bounds
  bool _isLoading = true;
  AirportMap? _selectedAirport;
  Timer? _debounceTimer;

  // Cache all parsed airports to avoid reloading JSON
  List<AirportMap>? _cachedAllAirports;

  // Track loaded bounds to avoid reloading
  final Set<String> _loadedBounds = {};

  // Prevent concurrent loading operations
  bool _isLoadingData = false;

  // Track if map is ready
  bool _isMapReady = false;

  // Store initial center point for selected country
  LatLng _initialCenter = const LatLng(39.8283, -98.5795);

  // Track last update time to prevent too frequent updates
  DateTime _lastUpdateTime = DateTime.now();
  static const Duration _minUpdateInterval = Duration(milliseconds: 100);

  final GoogleAdsController _googleAdsController = Get.find();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _googleAdsController.showAds();
    });
    _loadInitialAirports();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _updateTimer?.cancel();
    _loadTimer?.cancel();
    super.dispose();
  }

  // Parse JSON in isolate to avoid blocking main thread
  static List<AirportMap> _parseAirportsInIsolate(String jsonString) {
    final List<dynamic> data = json.decode(jsonString);
    return data.map((x) => AirportMap.fromJson(x)).toList();
  }

  // Filter airports by bounds and country in isolate
  // Accepts serialized airport data (List<Map<String, dynamic>>)
  static List<Map<String, dynamic>> _filterAirportsInIsolate(
    Map<String, dynamic> params,
  ) {
    final List<dynamic> airportsData = params['airports'] as List<dynamic>;
    final String countryCode = params['countryCode'] as String;
    final double south = params['south'] as double;
    final double north = params['north'] as double;
    final double west = params['west'] as double;
    final double east = params['east'] as double;

    final List<Map<String, dynamic>> filtered = [];
    for (final airportData in airportsData) {
      final Map<String, dynamic> airport = airportData as Map<String, dynamic>;
      final String airportCountryCode =
          airport['country_code']?.toString() ?? '';

      // Skip if not from selected country
      if (airportCountryCode != countryCode) continue;

      final double lat = (airport['latitude'] ?? 0.0).toDouble();
      final double lng = (airport['longitude'] ?? 0.0).toDouble();

      // Handle longitude wrapping
      bool inLongitude = false;
      if (west <= east) {
        inLongitude = lng >= west && lng <= east;
      } else {
        inLongitude = lng >= west || lng <= east;
      }

      if (lat >= south && lat <= north && inLongitude) {
        filtered.add(airport);
      }
    }
    return filtered;
  }

  // Load airports for selected country
  Future<void> _loadInitialAirports() async {
    if (_isLoadingData) return;
    _isLoadingData = true;

    try {
      // Load JSON string on main thread (this is fast)
      final String response = await rootBundle.loadString(
        'lib/data/airport_for_map.json',
      );

      // Parse JSON in isolate to avoid blocking UI (this is the heavy operation)
      final List<AirportMap> allAirports = await compute(
        _parseAirportsInIsolate,
        response,
      );

      // Filter airports by selected country
      final String countryCode = widget.selectedCountryCode ?? 'US';
      final List<AirportMap> countryAirports = allAirports
          .where((airport) => airport.countryCode == countryCode)
          .toList();

      // Cache all airports for later use
      _cachedAllAirports = allAirports;

      // Calculate center point for the country's airports
      LatLng? calculatedCenter;
      if (countryAirports.isNotEmpty) {
        double avgLat = 0;
        double avgLng = 0;
        for (final airport in countryAirports) {
          avgLat += airport.latitude;
          avgLng += airport.longitude;
        }
        avgLat /= countryAirports.length;
        avgLng /= countryAirports.length;
        calculatedCenter = LatLng(avgLat, avgLng);
      }

      if (mounted) {
        setState(() {
          _allAirports = countryAirports;
          _visibleAirports = countryAirports;
          _isLoading = false;
          // Update initial center for map
          if (calculatedCenter != null) {
            _initialCenter = calculatedCenter;
          }
        });

        // Wait for map to be ready before loading airports for visible area
        // Use multiple post frame callbacks to ensure map is rendered
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _isMapReady = true;
              // Center map on country if we have a calculated center
              if (calculatedCenter != null) {
                _mapController.move(calculatedCenter, 5.0);
              }
              _loadAirportsForVisibleArea();
            }
          });
        });
      }
    } catch (e) {
      print("Error loading airports: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } finally {
      _isLoadingData = false;
    }
  }

  // Check if map controller is ready
  bool _isMapControllerReady() {
    if (!_isMapReady) return false;
    try {
      // Try to access camera to check if it's ready
      final _ = _mapController.camera.visibleBounds;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Load airports for the currently visible map area
  Future<void> _loadAirportsForVisibleArea() async {
    if (_isLoadingData || !mounted || !_isMapControllerReady()) return;

    try {
      final bounds = _mapController.camera.visibleBounds;
      final boundsKey = _getBoundsKey(bounds);

      // Always update visible airports first (even if area already loaded)
      // This ensures markers show up immediately
      _updateVisibleAirports();

      // Skip loading new data if we've already loaded this area
      if (_loadedBounds.contains(boundsKey)) {
        return;
      }

      _isLoadingData = true;
      // Use cached data if available, otherwise load from file
      List<AirportMap> allAirports;
      if (_cachedAllAirports != null) {
        allAirports = _cachedAllAirports!;
      } else {
        final String response = await rootBundle.loadString(
          'lib/data/airport_for_map.json',
        );
        allAirports = await compute(_parseAirportsInIsolate, response);
        _cachedAllAirports = allAirports;
      }

      // Filter airports within visible bounds in isolate to avoid blocking main thread
      // Add padding to bounds to load slightly more than visible area for smoother experience
      final double padding = 0.5; // degrees of padding
      final double south = bounds.south - padding;
      final double north = bounds.north + padding;
      final double west = bounds.west - padding;
      final double east = bounds.east + padding;

      // Only load airports from the selected country
      final String countryCode = widget.selectedCountryCode ?? 'US';

      // Convert airports to serializable format for isolate
      final List<Map<String, dynamic>> airportsData = allAirports
          .map((a) => a.toJson())
          .toList();

      // Filter in isolate to avoid blocking main thread
      final List<Map<String, dynamic>> filteredData =
          await compute(_filterAirportsInIsolate, {
            'airports': airportsData,
            'countryCode': countryCode,
            'south': south,
            'north': north,
            'west': west,
            'east': east,
          });

      // Convert back to AirportMap objects
      final List<AirportMap> airportsInBounds = filteredData
          .map((data) => AirportMap.fromJson(data))
          .toList();

      // Add new airports that aren't already loaded
      // Use a Set for O(1) lookup instead of O(n)
      final Set<String> existingKeys = {
        for (final a in _allAirports) '${a.latitude}_${a.longitude}_${a.iata}',
      };

      final List<AirportMap> newAirports = [];
      for (final airport in airportsInBounds) {
        final key = '${airport.latitude}_${airport.longitude}_${airport.iata}';
        if (!existingKeys.contains(key)) {
          newAirports.add(airport);
        }
      }

      if (newAirports.isNotEmpty && mounted) {
        // Use scheduleMicrotask to batch the update
        scheduleMicrotask(() {
          if (mounted) {
            setState(() {
              _allAirports.addAll(newAirports);
            });
            // Update visible airports after state update
            scheduleMicrotask(() {
              if (mounted) {
                _updateVisibleAirports();
              }
            });
          }
        });
      } else if (mounted) {
        // Even if no new airports, update visible list in case bounds changed
        scheduleMicrotask(() {
          if (mounted) {
            _updateVisibleAirports();
          }
        });
      }

      _loadedBounds.add(boundsKey);
    } catch (e) {
      // Map might not be ready yet, ignore the error
      if (e.toString().contains('camera') ||
          e.toString().contains('MapController')) {
        // Map not ready, will retry later
        return;
      }
      print("Error loading airports for visible area: $e");
    } finally {
      _isLoadingData = false;
    }
  }

  // Generate a key for bounds to track loaded areas
  // Use larger grid cells to avoid too many reloads, but ensure we load nearby areas
  String _getBoundsKey(LatLngBounds bounds) {
    // Round to 1 decimal place to create larger grid cells (about 11km)
    final latMin = (bounds.south * 10).round() / 10;
    final latMax = (bounds.north * 10).round() / 10;
    final lngMin = (bounds.west * 10).round() / 10;
    final lngMax = (bounds.east * 10).round() / 10;
    return '${latMin}_${latMax}_${lngMin}_$lngMax';
  }

  // Update visible airports based on current map bounds
  void _updateVisibleAirports() {
    if (!mounted || !_isMapControllerReady()) return;

    // Throttle updates to prevent too frequent calls
    final now = DateTime.now();
    if (now.difference(_lastUpdateTime) < _minUpdateInterval) {
      return;
    }
    _lastUpdateTime = now;

    try {
      final bounds = _mapController.camera.visibleBounds;
      final double zoom = _mapController.camera.zoom;

      // Adjust marker limit based on zoom level - fewer markers when zoomed out
      // Reduced limits to prevent performance issues
      final int maxMarkers = zoom < 5
          ? 50
          : zoom < 8
          ? 150
          : 250;

      final List<AirportMap> visible = [];
      int count = 0;

      for (final airport in _allAirports) {
        // Handle longitude wrapping (crossing -180/180 line)
        bool inLongitude = false;
        if (bounds.west <= bounds.east) {
          // Normal case: no wrapping
          inLongitude =
              airport.longitude >= bounds.west &&
              airport.longitude <= bounds.east;
        } else {
          // Wrapping case: bounds cross the -180/180 line
          inLongitude =
              airport.longitude >= bounds.west ||
              airport.longitude <= bounds.east;
        }

        if (airport.latitude >= bounds.south &&
            airport.latitude <= bounds.north &&
            inLongitude) {
          visible.add(airport);
          count++;
          if (count >= maxMarkers) break;
        }
      }

      // Only update if the list actually changed to avoid unnecessary rebuilds
      // Use scheduleMicrotask to batch the update and avoid blocking
      if (_visibleAirports.length != visible.length ||
          !_listEquals(_visibleAirports, visible)) {
        if (mounted) {
          scheduleMicrotask(() {
            if (mounted) {
              setState(() {
                _visibleAirports = visible;
              });
            }
          });
        }
      }
    } catch (e) {
      // Map controller not ready, ignore
    }
  }

  // Helper to compare lists efficiently
  bool _listEquals(List<AirportMap> a, List<AirportMap> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].iata != b[i].iata ||
          a[i].latitude != b[i].latitude ||
          a[i].longitude != b[i].longitude) {
        return false;
      }
    }
    return true;
  }

  Timer? _updateTimer;
  Timer? _loadTimer;

  // Build info chip widget
  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Handle map movement with debouncing
  void _onMapMoved() {
    // Cancel previous timers
    _updateTimer?.cancel();
    _loadTimer?.cancel();

    // Update visible airports with delay to avoid blocking (from already loaded data)
    _updateTimer = Timer(const Duration(milliseconds: 200), () {
      if (mounted && _isMapControllerReady()) {
        _updateVisibleAirports();
      }
    });

    // Load new data with longer delay to avoid blocking during movement
    _loadTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _loadAirportsForVisibleArea();
      }
    });
  }

  // Zoom in on the map
  void _zoomIn() {
    if (!_isMapControllerReady()) return;
    try {
      final currentZoom = _mapController.camera.zoom;
      final newZoom = (currentZoom + 1).clamp(1.0, 18.0);
      _mapController.move(_mapController.camera.center, newZoom);
      _onMapMoved();
    } catch (e) {
      // Map controller not ready, ignore
    }
  }

  // Zoom out on the map
  void _zoomOut() {
    if (!_isMapControllerReady()) return;
    try {
      final currentZoom = _mapController.camera.zoom;
      final newZoom = (currentZoom - 1).clamp(1.0, 18.0);
      _mapController.move(_mapController.camera.center, newZoom);
      _onMapMoved();
    } catch (e) {
      // Map controller not ready, ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF0F172A),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.selectedCountryCode != null
                  ? 'Airports - ${widget.selectedCountryCode}'
                  : 'Airport Map',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${_visibleAirports.length} airports visible',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF4FF), Color(0xFFF8FAFC)],
          ),
        ),
        child: SafeArea(
          top: false,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF1E3A8A),
                    strokeWidth: 2.2,
                  ),
                )
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        // Center will be updated when data loads
                        initialCenter: _initialCenter,
                        initialZoom:
                            5.0, // Zoom level appropriate for country view
                        minZoom: 1.0,
                        maxZoom: 18.0,
                        onTap: (tapPosition, point) {
                          setState(() {
                            _selectedAirport = null;
                          });
                        },
                        onMapReady: () {
                          // Map is ready, set flag and load initial visible airports
                          _isMapReady = true;
                          if (mounted) {
                            _loadAirportsForVisibleArea();
                          }
                        },
                        onMapEvent: (MapEvent event) {
                          // Only handle events if map is ready
                          if (!_isMapReady) return;

                          // Handle map events with smart debouncing
                          if (event is MapEventFlingAnimationEnd) {
                            // Immediately update after fling ends
                            _onMapMoved();
                          } else if (event is MapEventScrollWheelZoom) {
                            // Update on zoom
                            _onMapMoved();
                          } else if (event is MapEventMove) {
                            // During move, don't update immediately - wait for movement to stop
                            // This prevents constant updates that block the main thread
                            _updateTimer?.cancel();
                            _loadTimer?.cancel();

                            // Only update after user stops moving (longer delay)
                            _updateTimer = Timer(
                              const Duration(milliseconds: 300),
                              () {
                                if (mounted && _isMapControllerReady()) {
                                  _updateVisibleAirports();
                                }
                              },
                            );

                            // Load new data with even longer delay
                            _loadTimer = Timer(
                              const Duration(milliseconds: 1000),
                              () {
                                if (mounted) {
                                  _loadAirportsForVisibleArea();
                                }
                              },
                            );
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'com.flightfinder.flighttracker',
                        ),
                        MarkerLayer(
                          markers: _visibleAirports.map((airport) {
                            // Safely get zoom level with fallback
                            double zoom = 4.0;
                            try {
                              if (_isMapReady) {
                                zoom = _mapController.camera.zoom;
                              }
                            } catch (e) {
                              // Use default zoom if camera not ready
                            }
                            final isSelected =
                                _selectedAirport?.iata == airport.iata;

                            // Adjust marker size based on zoom level
                            final double markerSize = zoom < 5
                                ? 32
                                : zoom < 8
                                ? 36
                                : 40;
                            final double iconSize = zoom < 5
                                ? 16
                                : zoom < 8
                                ? 18
                                : 20;

                            return Marker(
                              point: LatLng(
                                airport.latitude,
                                airport.longitude,
                              ),
                              width: markerSize,
                              height: markerSize,
                              alignment: Alignment.center,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedAirport = airport;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: isSelected ? 8 : 4,
                                        spreadRadius: isSelected ? 2 : 1,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: isSelected
                                            ? [
                                                const Color(0xFF1E3A8A),
                                                const Color(0xFF0EA5E9),
                                              ]
                                            : [
                                                const Color(0xFF1E3A8A),
                                                const Color(0xFF0EA5E9),
                                              ],
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: isSelected ? 3 : 2.5,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.flight_takeoff_rounded,
                                      color: Colors.white,
                                      size: iconSize,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    // Zoom controls
                    Positioned(
                      right: 16,
                      bottom: _selectedAirport != null ? 200 : 20,
                      child: Column(
                        children: [
                          // Zoom in button
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF1E3A8A,
                                  ).withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: _zoomIn,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  padding: const EdgeInsets.all(12),
                                  child: const Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Zoom out button
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF1E3A8A,
                                  ).withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: _zoomOut,
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  padding: const EdgeInsets.all(12),
                                  child: const Icon(
                                    Icons.remove_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedAirport != null)
                      Positioned(
                        bottom: 20,
                        left: 12,
                        right: 12,
                        child: Hero(
                          tag: 'airport-${_selectedAirport!.iata}',
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF1E3A8A,
                                  ).withOpacity(0.25),
                                  blurRadius: 14,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.flight_takeoff_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _selectedAirport!.airport,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              if (_selectedAirport!
                                                      .iata
                                                      .isNotEmpty ||
                                                  _selectedAirport!
                                                      .icao
                                                      .isNotEmpty)
                                                const SizedBox(height: 4),
                                              if (_selectedAirport!
                                                      .iata
                                                      .isNotEmpty ||
                                                  _selectedAirport!
                                                      .icao
                                                      .isNotEmpty)
                                                Row(
                                                  children: [
                                                    if (_selectedAirport!
                                                        .iata
                                                        .isNotEmpty)
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white
                                                              .withOpacity(
                                                                0.15,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          _selectedAirport!
                                                              .iata,
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                        ),
                                                      ),
                                                    if (_selectedAirport!
                                                            .iata
                                                            .isNotEmpty &&
                                                        _selectedAirport!
                                                            .icao
                                                            .isNotEmpty)
                                                      const SizedBox(width: 6),
                                                    if (_selectedAirport!
                                                        .icao
                                                        .isNotEmpty)
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white
                                                              .withOpacity(
                                                                0.15,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          _selectedAirport!
                                                              .icao,
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close_rounded,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _selectedAirport = null;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        if (_selectedAirport!
                                            .countryCode
                                            .isNotEmpty)
                                          _buildInfoChip(
                                            Icons.public_rounded,
                                            _selectedAirport!.countryCode,
                                          ),
                                        if (_selectedAirport!.type.isNotEmpty)
                                          _buildInfoChip(
                                            Icons.category_rounded,
                                            _selectedAirport!.type.replaceAll(
                                              '_',
                                              ' ',
                                            ),
                                          ),
                                        if (_selectedAirport!.elevationFt > 0)
                                          _buildInfoChip(
                                            Icons.height_rounded,
                                            '${_selectedAirport!.elevationFt} ft',
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on_rounded,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              '${_selectedAirport!.latitude.toStringAsFixed(4)}, ${_selectedAirport!.longitude.toStringAsFixed(4)}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
