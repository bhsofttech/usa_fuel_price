import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:usa_gas_price/controller/gas_controller.dart';
import 'package:usa_gas_price/model/gas_info.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';
import 'package:usa_gas_price/pages/national_gas_price.dart';
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
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        leadingWidth: 50,
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          "USA Fuel Prices".toUpperCase(),
          style: TextStyle(
            color: primaryBlue,
            fontFamily: "SF Pro Display",
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        iconTheme: IconThemeData(color: darkBlue),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFD1D1D6),
                width: 0.5,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mapSize = Size(
                constraints.maxWidth,
                constraints.maxWidth * 0.99,
              );

              return Obx(() {
                final gasData = stateCodeToGas;
                return _gasController.showGasLoading.value ||
                        _gasController.showGasLoadingAvg.value
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SpinKitFadingCircle(
                              color: primaryBlue,
                              size: 40.0,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Loading Fuel Prices...",
                              style: TextStyle(
                                color: darkBlue.withOpacity(0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: "SF Pro Text",
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          Text(
                            "Select a state to check fuel prices",
                            style: TextStyle(
                              color: const Color(0xFF8E8E93),
                              fontFamily: "SF Pro Text",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTapDown: (e) {},
                            child: MouseRegion(
                              onHover: (e) {
                                tooltipPos = e.localPosition;
                                _detectHit(e.localPosition, mapSize);
                              },
                              child: Stack(
                                alignment: AlignmentDirectional.bottomCenter,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: CustomPaint(
                                        size: mapSize,
                                        painter: _MapPainter(
                                            statePaths, hoveredState, gasData),
                                      ),
                                    ),
                                  ),
                                  if (hoveredState != null)
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        getTooltipText(hoveredState!, gasData),
                                        style: TextStyle(
                                          color: darkBlue,
                                          fontFamily: "SF Pro Text",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
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
      Get.find<GoogleAdsController>().showAds();
    }
  }

  String getTooltipText(String id, Map<String, Gasinfo> gasData) {
    final gas = gasData[id];
    return gas != null
        ? 'State: ${gas.city}\nRegular Gas Price: ${gas.regular}\nMid-Grade Gas Price: ${gas.midGrade}\nPremium Gas Price: ${gas.premium}\nDiesel Price: ${gas.diesel}'
        : 'No data for $id';
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
              ? _getColorForPrice(double.tryParse(gas.regular.toString()) ?? 0)
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
