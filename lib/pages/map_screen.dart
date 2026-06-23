import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:usa_gas_price/controller/gas_controller.dart';
import 'package:usa_gas_price/model/gas_info.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';
import 'package:usa_gas_price/pages/national_gas_price.dart';
import 'package:usa_gas_price/time/time_setup_screen.dart';
import 'package:xml/xml.dart';

class GasMapHitTestApp extends StatefulWidget {
  const GasMapHitTestApp({super.key});

  @override
  State<GasMapHitTestApp> createState() => _GasMapHitTestAppState();
}

class _GasMapHitTestAppState extends State<GasMapHitTestApp> {
  final GasController _gasController = Get.find<GasController>();
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color darkBlue = const Color(0xFF0A4B9A);
  Map<String, Path> statePaths = {};
  String? hoveredState = "TX";
  Offset tooltipPos = Offset.zero;

  // State abbreviation mapping
  final Map<String, String> fullStateNameToAbbrev = {
    'ALABAMA': 'AL',
    'ALASKA': 'AK',
    'ARIZONA': 'AZ',
    'ARKANSAS': 'AR',
    'CALIFORNIA': 'CA',
    'COLORADO': 'CO',
    'CONNECTICUT': 'CT',
    'DELAWARE': 'DE',
    'FLORIDA': 'FL',
    'GEORGIA': 'GA',
    'HAWAII': 'HI',
    'IDAHO': 'ID',
    'ILLINOIS': 'IL',
    'INDIANA': 'IN',
    'IOWA': 'IA',
    'KANSAS': 'KS',
    'KENTUCKY': 'KY',
    'LOUISIANA': 'LA',
    'MAINE': 'ME',
    'MARYLAND': 'MD',
    'MASSACHUSETTS': 'MA',
    'MICHIGAN': 'MI',
    'MINNESOTA': 'MN',
    'MISSISSIPPI': 'MS',
    'MISSOURI': 'MO',
    'MONTANA': 'MT',
    'NEBRASKA': 'NE',
    'NEVADA': 'NV',
    'NEW HAMPSHIRE': 'NH',
    'NEW JERSEY': 'NJ',
    'NEW MEXICO': 'NM',
    'NEW YORK': 'NY',
    'NORTH CAROLINA': 'NC',
    'NORTH DAKOTA': 'ND',
    'OHIO': 'OH',
    'OKLAHOMA': 'OK',
    'OREGON': 'OR',
    'PENNSYLVANIA': 'PA',
    'RHODE ISLAND': 'RI',
    'SOUTH CAROLINA': 'SC',
    'SOUTH DAKOTA': 'SD',
    'TENNESSEE': 'TN',
    'TEXAS': 'TX',
    'UTAH': 'UT',
    'VERMONT': 'VT',
    'VIRGINIA': 'VA',
    'WASHINGTON': 'WA',
    'WEST VIRGINIA': 'WV',
    'WISCONSIN': 'WI',
    'WYOMING': 'WY',
    'DISTRICT OF COLUMBIA': 'DC',
  };

  @override
  void initState() {
    super.initState();
    _loadSvgPaths();
    _fetchGasPrices();
  }

  Future<void> _fetchGasPrices() async {
    try {
      await _gasController.fetchGasPrice(
          endPoint: "/state-gas-price-averages/");
      await _gasController.fetchGasPriceAvg(endPoint: "");
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load gas prices: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadSvgPaths() async {
    try {
      final svgStr = await DefaultAssetBundle.of(context)
          .loadString('assets/images/us.svg');
      final doc = XmlDocument.parse(svgStr);
      final paths = doc.findAllElements('path');

      for (var el in paths) {
        final id = el.getAttribute('id');
        final d = el.getAttribute('d');
        if (id != null && d != null) {
          final path = parseSvgPathData(d)..fillType = PathFillType.nonZero;
          statePaths[id] = path;
        }
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load SVG: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Map<String, Gasinfo> get stateCodeToGas {
    return {
      for (var g in _gasController.getGasInfo)
        if (fullStateNameToAbbrev.containsKey(g.city.toUpperCase()))
          fullStateNameToAbbrev[g.city.toUpperCase()]!: g
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7), // Softer modern grey background
      appBar: AppBar(
        leadingWidth: 50,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "USA Fuel Prices".toUpperCase(),
          style: TextStyle(
            color: primaryBlue,
            fontFamily: "SF Pro Display",
            fontSize: 16.0, // Reduced font size as requested
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: IconThemeData(color: darkBlue),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade200,
            height: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time_outlined,
                color: Color(0xFF007AFF)),
            onPressed: () => Get.to(() => const TimeSetupScreen()),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12), // Reduced padding as requested
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mapSize = Size(
                constraints.maxWidth,
                constraints.maxWidth *
                    0.65, // Adjust map ratio so it's fully visible
              );

              return Obx(() {
                final gasData = stateCodeToGas;
                return _gasController.showGasLoading.value ||
                        _gasController.showGasLoadingAvg.value
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SpinKitFadingCircle(
                                  color: primaryBlue, size: 40.0),
                              const SizedBox(height: 16),
                              Text(
                                "Loading Fuel Prices...",
                                style: TextStyle(
                                  color: darkBlue.withOpacity(0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "SF Pro Text",
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Interactive Map",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: darkBlue,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.touch_app,
                                      size: 16,
                                      color: primaryBlue.withOpacity(0.8)),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Tap a state to check prices",
                                    style: TextStyle(
                                      color: primaryBlue.withOpacity(0.9),
                                      fontFamily: "SF Pro Text",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTapDown: (e) {
                              Get.find<GoogleAdsController>().navigateWithAd(
                                  onAction: () {
                                tooltipPos = e.localPosition;
                                _detectHit(e.localPosition, mapSize);
                              });
                            },
                            child: MouseRegion(
                              onHover: (e) {
                                // tooltipPos = e.localPosition;
                                // _detectHit(e.localPosition, mapSize);
                              },
                              // Extracted the tooltip out of the Stack so the map is 100% visible
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CustomPaint(
                                    size: mapSize,
                                    painter: _MapPainter(
                                        statePaths, hoveredState, gasData),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (hoveredState != null &&
                              gasData.containsKey(hoveredState)) ...[
                            const SizedBox(height: 12),
                            _buildGasInfoCard(gasData[hoveredState]!),
                          ] else ...[
                            const SizedBox(height: 12),
                            _buildEmptyStateCard(),
                          ],
                          const SizedBox(height: 12),
                          // Visual Separation for the Next Section
                          Divider(color: Colors.grey.shade300, thickness: 1.5),
                          const SizedBox(height: 12),
                          Text(
                            "Averages Overview",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: darkBlue,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const NationalGasPrice(),
                        ],
                      );
              });
            },
          ),
        ),
      ),
    );
  }

  void _detectHit(Offset pos, Size mapSize) {
    String? hit;

    final bounds = statePaths.values.fold<Rect>(
      Rect.fromLTRB(double.infinity, double.infinity, double.negativeInfinity,
          double.negativeInfinity),
      (previous, path) => previous.expandToInclude(path.getBounds()),
    );

    final scaleX = mapSize.width / bounds.width;
    final scaleY = mapSize.height / bounds.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    final translateX = -bounds.left * scale;
    final translateY = -bounds.top * scale;

    final transformedPos = Offset(
      (pos.dx - translateX) / scale,
      (pos.dy - translateY) / scale,
    );

    statePaths.forEach((id, p) {
      if (p.contains(transformedPos)) {
        hit = id;
      }
    });

    if (hit != hoveredState) {
      setState(() => hoveredState = hit);
    }
    if (hit != null && (hit?.isNotEmpty ?? false)) {
      // Add Ads
    }
  }

  Widget _buildGasInfoCard(Gasinfo gas) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: primaryBlue),
              const SizedBox(width: 4),
              Text(
                gas.city,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1C1C1E)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPriceItem('Regular', gas.regular, const Color(0xFF34C759)),
              _buildPriceItem(
                  'Mid-Grade', gas.midGrade, const Color(0xFFFFCC00)),
              _buildPriceItem('Premium', gas.premium, const Color(0xFFFF9500)),
              _buildPriceItem('Diesel', gas.diesel, const Color(0xFFFF3B30)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItem(String label, String price, Color color) {
    // Prevent double dollar signs if the API returns it
    final displayPrice = price.startsWith('\$') ? price : '\$$price';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8E8E93),
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          displayPrice,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E)),
        ),
      ],
    );
  }

  Widget _buildEmptyStateCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 32, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            "No State Selected",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkBlue.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Tap on any state on the map to view its fuel prices.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final Map<String, Path> paths;
  final String? highlight;
  final Map<String, Gasinfo> gasData;

  _MapPainter(this.paths, this.highlight, this.gasData);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final bounds = paths.values.fold<Rect>(
      Rect.fromLTRB(double.infinity, double.infinity, double.negativeInfinity,
          double.negativeInfinity),
      (previous, path) => previous.expandToInclude(path.getBounds()),
    );

    final scaleX = size.width / bounds.width;
    final scaleY = size.height / bounds.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    final translateX = -bounds.left * scale;
    final translateY = -bounds.top * scale;

    canvas.save();
    canvas.translate(translateX, translateY);
    canvas.scale(scale, scale);

    paths.forEach((id, path) {
      final gas = gasData[id];
      paint.color = (id == highlight)
          ? const Color(0xFF007AFF).withOpacity(0.8)
          : gas != null
              ? _getColorForPrice(double.tryParse(gas.regular
                      .toString()
                      .replaceAll('\$', '')
                      .replaceAll(',', '')) ??
                  0)
              : const Color(0xFFE5E5EA);

      canvas.drawPath(path, paint);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.white
          ..strokeWidth = 0.5 / scale,
      );
    });

    canvas.restore();
  }

  Color _getColorForPrice(double price) {
    if (price < 3.0) return const Color(0xFF34C759);
    if (price < 3.5) return const Color(0xFFFFCC00);
    if (price < 4.0) return const Color(0xFFFF9500);
    return const Color(0xFFFF3B30);
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) {
    return old.highlight != highlight ||
        old.paths.length != paths.length ||
        old.gasData != gasData;
  }
}
