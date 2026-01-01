import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../controller/google_ads_controller.dart';

void main() {
  runApp(const MyApp());
}

/// ===================== APP ROOT =====================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LiveFlightMap(),
    );
  }
}

/// ===================== MODEL =====================
class Aircraft {
  final String icao24;
  final String callsign;
  final double lat;
  final double lon;
  final double heading;

  Aircraft({
    required this.icao24,
    required this.callsign,
    required this.lat,
    required this.lon,
    required this.heading,
  });

  factory Aircraft.fromList(List e) {
    return Aircraft(
      icao24: e[0],
      callsign: (e[1] ?? '').toString().trim(),
      lon: (e[5] as num).toDouble(),
      lat: (e[6] as num).toDouble(),
      heading: (e[10] ?? 0).toDouble(),
    );
  }
}

/// ===================== MAP SCREEN =====================
class LiveFlightMap extends StatefulWidget {
  const LiveFlightMap({super.key});

  @override
  State<LiveFlightMap> createState() => _LiveFlightMapState();
}

class _LiveFlightMapState extends State<LiveFlightMap>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  final Map<String, Aircraft> _current = {};
  final Map<String, Aircraft> _previous = {};
  final Map<String, AnimationController> _controllers = {};

  bool _mapReady = false;
  bool _isMapMoving = false;
  bool _isLoading = false;
  Timer? _debounce;
  DateTime? _lastUpdate;

  final Duration animationDuration = const Duration(seconds: 3);

  /// ===================== MAP EVENTS =====================
  void _onMapEvent(MapEvent event) {
    if (!_mapReady) return;

    if (event is MapEventMove || event is MapEventRotate) {
      _isMapMoving = true;
      for (final c in _controllers.values) {
        c.stop();
      }
      _debounce?.cancel();
    }

    if (event is MapEventMoveEnd || event is MapEventRotateEnd) {
      _isMapMoving = false;
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 700), () {
        _fetchUsingVisibleArea();
      });
    }
  }

  /// ===================== FETCH USING VISIBLE AREA =====================
  Future<void> _fetchUsingVisibleArea() async {
    if (!_mapReady || _isMapMoving) return;

    final bounds = _mapController.camera.visibleBounds;

    setState(() {
      _isLoading = true;
    });

    final aircrafts = await _fetchAircraft(
      lamin: bounds.southWest.latitude,
      lamax: bounds.northEast.latitude,
      lomin: bounds.southWest.longitude,
      lomax: bounds.northEast.longitude,
    );

    setState(() {
      _isLoading = false;
      _lastUpdate = DateTime.now();
      _previous
        ..clear()
        ..addAll(_current);

      _current.clear();

      for (final a in aircrafts) {
        _current[a.icao24] = a;
        _controllers[a.icao24]?.dispose();
        _controllers[a.icao24] = AnimationController(
          vsync: this,
          duration: animationDuration,
        )..forward();
      }
    });
  }

  /// ===================== OPENSKY API =====================
  Future<List<Aircraft>> _fetchAircraft({
    required double lamin,
    required double lamax,
    required double lomin,
    required double lomax,
  }) async {
    final url =
        'https://opensky-network.org/api/states/all'
        '?lamin=$lamin&lamax=$lamax&lomin=$lomin&lomax=$lomax';

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) return [];

      final json = jsonDecode(res.body);
      final List states = json['states'] ?? [];

      return states
          .where((e) => e[5] != null && e[6] != null)
          .map((e) => Aircraft.fromList(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// ===================== MARKERS =====================
  List<Marker> _buildMarkers() {
    // Static markers while moving (smooth UX)
    if (_isMapMoving) {
      return _current.values.map((a) {
        return Marker(
          width: 40,
          height: 40,
          point: LatLng(a.lat, a.lon),
          child: GestureDetector(
            onTap: () => _showAircraftInfo(a),
            child: _buildAircraftIcon(a.heading, false),
          ),
        );
      }).toList();
    }

    // Animated markers when idle
    final markers = <Marker>[];

    for (final id in _current.keys) {
      final newA = _current[id]!;
      final oldA = _previous[id] ?? newA;
      final controller = _controllers[id]!;

      markers.add(
        Marker(
          width: 40,
          height: 40,
          point: LatLng(
            oldA.lat + (newA.lat - oldA.lat) * controller.value,
            oldA.lon + (newA.lon - oldA.lon) * controller.value,
          ),
          child: GestureDetector(
            onTap: () => _showAircraftInfo(newA),
            child: _buildAircraftIcon(newA.heading, true),
          ),
        ),
      );
    }
    return markers;
  }

  Widget _buildAircraftIcon(double heading, bool animated) {
    return Transform.rotate(
      angle: heading * math.pi / 180,
      child: const Icon(Icons.flight, size: 24, color: Color(0xFF2563EB)),
    );
  }

  /// ===================== INFO POPUP =====================
  void _showAircraftInfo(Aircraft a) {
    Get.find<GoogleAdsController>().showAds();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.flight,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.callsign.isEmpty
                                  ? 'Unknown Flight'
                                  : "Flight: ${a.callsign}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Aircraft Information',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Info cards
                  _infoCard(
                    icon: Icons.fingerprint,
                    label: 'ICAO24',
                    value: a.icao24,
                    color: const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _infoCard(
                          icon: Icons.navigation,
                          label: 'Latitude',
                          value: a.lat.toStringAsFixed(4),
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _infoCard(
                          icon: Icons.explore,
                          label: 'Longitude',
                          value: a.lon.toStringAsFixed(4),
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _infoCard(
                    icon: Icons.compass_calibration,
                    label: 'Heading',
                    value: '${a.heading.toStringAsFixed(0)}°',
                    color: const Color(0xFFEF4444),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ===================== ZOOM CONTROLS =====================
  void _zoomIn() {
    if (!_mapReady) return;
    final c = _mapController.camera;
    _mapController.move(c.center, c.zoom + 1);
  }

  void _zoomOut() {
    if (!_mapReady) return;
    final c = _mapController.camera;
    _mapController.move(c.center, c.zoom - 1);
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _debounce?.cancel();
    super.dispose();
  }

  /// ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(37.1, -95.7), // 🇺🇸 USA focus
              initialZoom: 4.5,
              onMapReady: () {
                _mapReady = true;
                _fetchUsingVisibleArea();
              },
              onMapEvent: _onMapEvent,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flighttracker',
              ),
              MarkerLayer(markers: _buildMarkers()),
            ],
          ),

          /// ---------- ENHANCED APP BAR ----------
          SafeArea(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.flight_takeoff,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Live Flight Map",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const Text(
                            "Tap on the flight to get more details",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Aircraft count badge
                    if (_current.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.airplanemode_active,
                              size: 16,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${_current.length}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
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

          /// ---------- LOADING INDICATOR ----------
          if (_isLoading)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue[700]!,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Loading flights...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          /// ---------- ENHANCED ZOOM CONTROLS ----------
          Positioned(
            right: 16,
            bottom: 24,
            child: Column(
              children: [
                _buildZoomButton(
                  icon: Icons.add,
                  onPressed: _zoomIn,
                  heroTag: 'zoomIn',
                ),
                const SizedBox(height: 12),
                Container(width: 48, height: 1, color: Colors.grey[300]),
                const SizedBox(height: 12),
                _buildZoomButton(
                  icon: Icons.remove,
                  onPressed: _zoomOut,
                  heroTag: 'zoomOut',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String heroTag,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFF0F172A), size: 24),
          ),
        ),
      ),
    );
  }

  String _formatLastUpdate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Updated just now';
    } else if (difference.inMinutes < 60) {
      return 'Updated ${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return 'Updated ${difference.inHours}h ago';
    } else {
      return 'Updated ${difference.inDays}d ago';
    }
  }
}
