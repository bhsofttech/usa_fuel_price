import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:usa_gas_price/controller/google_ads_controller.dart';
import 'package:usa_gas_price/new_flow/crude_oil_list_screen.dart';
import 'package:usa_gas_price/new_flow/natural_gas_list_screen.dart';
import 'package:usa_gas_price/time/time_setup_screen.dart';

class NationalAvgPrice extends StatefulWidget {
  const NationalAvgPrice({super.key});

  @override
  State<NationalAvgPrice> createState() => _NationalAvgPriceState();
}

class _NationalAvgPriceState extends State<NationalAvgPrice>
    with TickerProviderStateMixin {
  Map<String, Map<String, String>> gasPrices = {};
  List<Map<String, String>> crudeOilPrices = [];
  List<Map<String, String>> naturalGasPrices = [];
  bool isLoading = true;
  String errorMessage = '';

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Color primaryBlue = const Color(0xFF007AFF);
  final Color lightBlue = const Color(0xFF4DA6FF);
  final Color backgroundGray = const Color(0xFFF2F2F7);
  final Color cardWhite = const Color(0xFFFFFFFF);
  final Color textPrimary = const Color(0xFF1C1C1E);
  final Color textSecondary = const Color(0xFF8E8E93);

  @override
  void initState() {
    super.initState();
    analytics.logScreenView(screenName: "US National Gas Prices");

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fetchNationalGasPrices();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchNationalGasPrices() async {
    const url = 'https://www.oilmonster.com/gas-prices';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load page: ${response.statusCode}');
      }

      final document = parser.parse(response.body);

      // Find all price boxes (they are in .col-md-3 > .border)
      final priceBoxes = document.querySelectorAll('div.col-md-3 div.border');

      Map<String, Map<String, String>> tempPrices = {};

      for (var box in priceBoxes) {
        final nameEl = box.querySelector('h4.wdname');
        final priceEl = box.querySelector('div.wdprice');
        final changeEl = box.querySelector('.wdpriceup, .wdpricedown');

        if (nameEl != null && priceEl != null) {
          final fuelType = nameEl.text.trim();
          final price = priceEl.text.trim();

          String change = '0.00';
          if (changeEl != null) {
            change = changeEl.text.trim();
          }

          tempPrices[fuelType] = {
            'price': price,
            'change': change,
          };
        }
      }

      if (tempPrices.isEmpty) {
        final allPrices = document.querySelectorAll('div.wdprice');
        final allNames = document.querySelectorAll('h4.wdname');

        for (int i = 0; i < allNames.length && i < allPrices.length; i++) {
          final fuelType = allNames[i].text.trim();
          final price = allPrices[i].text.trim();
          tempPrices[fuelType] = {'price': price, 'change': 'N/A'};
        }
      }

      // 2. Fetch Crude Oil Prices from home page
      const homeUrl = 'https://www.oilmonster.com/';
      final homeResponse = await http.get(
        Uri.parse(homeUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36',
        },
      );

      List<Map<String, String>> tempCrude = [];
      List<Map<String, String>> tempNaturalGas = [];
      if (homeResponse.statusCode == 200) {
        final homeDoc = parser.parse(homeResponse.body);

        // Crude Oil
        final crudeRows =
            homeDoc.querySelectorAll('table.iternataionalcrude tbody tr');
        for (var row in crudeRows) {
          final cells = row.querySelectorAll('td');
          if (cells.length >= 4) {
            final region = cells[0].text.trim();
            final blend = cells[1].text.trim();
            final price = cells[2].text.trim();
            final change = cells[3].text.trim();

            tempCrude.add({
              'region': region,
              'blend': blend,
              'price': price,
              'change': change,
            });
          }
        }

        // Natural Gas
        final gasRows =
            homeDoc.querySelectorAll('table.gaselectricity tbody tr');
        for (var row in gasRows) {
          final cells = row.querySelectorAll('td');
          if (cells.length >= 3) {
            final location = cells[0].text.trim();
            final price = cells[1].text.trim();
            final change = cells[2].text.trim();

            tempNaturalGas.add({
              'location': location,
              'price': price,
              'change': change,
            });
          }
        }
      }

      if (mounted) {
        setState(() {
          gasPrices = tempPrices;
          crudeOilPrices = tempCrude;
          naturalGasPrices = tempNaturalGas;
          isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage =
              'Error: $e\n\nSite structure may have changed slightly.';
          isLoading = false;
        });
      }
    }
  }

  Color _getChangeColor(String change) {
    if (change.contains('+')) return Colors.green;
    if (change.contains('-')) return Colors.red;
    return Colors.grey;
  }

  IconData _getFuelIcon(String fuelType) {
    final lower = fuelType.toLowerCase();
    if (lower.contains('diesel')) return Icons.local_shipping_rounded;
    if (lower.contains('premium')) return Icons.star_rounded;
    if (lower.contains('midgrade')) return Icons.local_gas_station_outlined;
    return Icons.local_gas_station_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: AppBar(
          leadingWidth: 50,
          actions: [
            IconButton(
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.access_time_outlined,
                  color: primaryBlue,
                  size: 18,
                ),
              ),
              onPressed: () {
                Get.to(() => const TimeSetupScreen());
              },
            ).paddingOnly(bottom: 5, right: 4),
          ],
          backgroundColor: cardWhite.withOpacity(0.95),
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          centerTitle: true,
          title: Text(
            "US NATIONAL PRICES",
            style: TextStyle(
              color: primaryBlue,
              fontFamily: "SF Pro Display",
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          iconTheme: IconThemeData(color: primaryBlue),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: cardWhite.withOpacity(0.95),
              border: const Border(
                bottom: BorderSide(
                  color: Color(0xFFE5E5EA),
                  width: 0.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: primaryBlue,
                      strokeWidth: 2.5,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Fetching live prices...",
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                        fontFamily: "SF Pro Text",
                      ),
                    ),
                  ],
                ),
              )
            : errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wifi_off_rounded,
                              color: textSecondary, size: 36),
                          const SizedBox(height: 8),
                          Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14.0, vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              label: "USA Gas Prices",
                              icon: Icons.local_gas_station_rounded,
                              color: primaryBlue,
                            ),
                            const SizedBox(height: 8),
                            // Gas Prices as grouped card
                            Container(
                              decoration: BoxDecoration(
                                color: cardWhite,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: gasPrices.entries
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  int index = entry.key;
                                  final fuel = entry.value.key;
                                  final data = entry.value.value;
                                  final change = data['change'] ?? '0.00';
                                  final isLast = index == gasPrices.length - 1;

                                  return AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(
                                            0,
                                            (1 - _animationController.value) *
                                                15 *
                                                (index + 1)),
                                        child: Opacity(
                                          opacity: _animationController.value,
                                          child: _buildGasRow(
                                            fuel,
                                            data['price'] ?? 'N/A',
                                            change,
                                            isLast: isLast,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                              ),
                            ),

                            const SizedBox(height: 16),

                            if (crudeOilPrices.isNotEmpty) ...[
                              _buildSectionHeader(
                                label: "International Crude Oil",
                                icon: Icons.opacity_rounded,
                                color: Colors.deepOrange,
                                trailing: GestureDetector(
                                  onTap: () {
                                    Get.find<GoogleAdsController>()
                                        .navigateWithAd(
                                            nextPage: CrudeOilListScreen(
                                      crudeOilPrices: crudeOilPrices,
                                    ));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: primaryBlue.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "View All",
                                      style: TextStyle(
                                        color: primaryBlue,
                                        fontFamily: "SF Pro Text",
                                        fontSize: 11.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: cardWhite,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: crudeOilPrices
                                      .take(2)
                                      .toList()
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int index = entry.key;
                                    final data = entry.value;
                                    final isLast = index ==
                                        (crudeOilPrices.length > 4
                                                ? 4
                                                : crudeOilPrices.length) -
                                            1;

                                    return AnimatedBuilder(
                                      animation: _animationController,
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset: Offset(
                                              0,
                                              (1 - _animationController.value) *
                                                  15 *
                                                  (index +
                                                      gasPrices.length +
                                                      1)),
                                          child: Opacity(
                                            opacity: _animationController.value,
                                            child: _buildCrudeRow(data,
                                                isLast: isLast),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],

                            const SizedBox(height: 16),

                            if (naturalGasPrices.isNotEmpty) ...[
                              _buildSectionHeader(
                                label: "USA Natural Gas",
                                icon: Icons.whatshot_rounded,
                                color: const Color(0xFF007AFF),
                                trailing: GestureDetector(
                                  onTap: () {
                                    Get.find<GoogleAdsController>()
                                        .navigateWithAd(
                                            nextPage: NaturalGasListScreen(
                                                naturalGasPrices:
                                                    naturalGasPrices));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: primaryBlue.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "View All",
                                      style: TextStyle(
                                        color: primaryBlue,
                                        fontFamily: "SF Pro Text",
                                        fontSize: 11.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: cardWhite,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: naturalGasPrices
                                      .take(2)
                                      .toList()
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int index = entry.key;
                                    final data = entry.value;
                                    final isLast = index ==
                                        (naturalGasPrices.length > 4
                                                ? 4
                                                : naturalGasPrices.length) -
                                            1;

                                    return AnimatedBuilder(
                                      animation: _animationController,
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset: Offset(
                                              0,
                                              (1 - _animationController.value) *
                                                  15 *
                                                  (index +
                                                      gasPrices.length +
                                                      crudeOilPrices.length +
                                                      1)),
                                          child: Opacity(
                                            opacity: _animationController.value,
                                            child: _buildNaturalGasRow(data,
                                                isLast: isLast),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  /// Compact section header with icon pill
  Widget _buildSectionHeader({
    required String label,
    required IconData icon,
    required Color color,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 13),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontFamily: "SF Pro Text",
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing,
      ],
    );
  }

  /// Row inside grouped card for Gas
  Widget _buildGasRow(String title, String price, String change,
      {bool isLast = false}) {
    final changeColor = _getChangeColor(change);
    final bool isPositive = change.contains('+');
    final bool isNegative = change.contains('-');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              // Icon
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  gradient: LinearGradient(
                    colors: [lightBlue, primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Icon(
                  _getFuelIcon(title),
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              // Title
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textPrimary,
                    fontFamily: "SF Pro Text",
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              // Change badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isPositive || isNegative)
                      Icon(
                        isPositive
                            ? Icons.arrow_drop_up_rounded
                            : Icons.arrow_drop_down_rounded,
                        color: changeColor,
                        size: 14,
                      ),
                    Text(
                      change,
                      style: TextStyle(
                        color: changeColor,
                        fontFamily: "SF Pro Text",
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Price
              Text(
                price,
                style: TextStyle(
                  color: textPrimary,
                  fontFamily: "SF Pro Display",
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 58,
            endIndent: 0,
            color: const Color(0xFFE5E5EA),
          ),
      ],
    );
  }

  /// Row inside grouped card for Crude Oil
  Widget _buildCrudeRow(Map<String, String> data, {bool isLast = false}) {
    final change = data['change'] ?? '0.00';
    final changeColor = _getChangeColor(change);
    final bool isPositive = change.contains('+');
    final bool isNegative = change.contains('-');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  gradient: const LinearGradient(
                    colors: [Colors.orangeAccent, Colors.deepOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.opacity_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['region'] ?? '',
                      style: TextStyle(
                        color: textPrimary,
                        fontFamily: "SF Pro Text",
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      data['blend'] ?? '',
                      style: TextStyle(
                        color: textSecondary,
                        fontFamily: "SF Pro Text",
                        fontSize: 11.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    data['price'] ?? 'N/A',
                    style: TextStyle(
                      color: textPrimary,
                      fontFamily: "SF Pro Display",
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: changeColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPositive || isNegative)
                          Icon(
                            isPositive
                                ? Icons.arrow_drop_up_rounded
                                : Icons.arrow_drop_down_rounded,
                            color: changeColor,
                            size: 12,
                          ),
                        Text(
                          change,
                          style: TextStyle(
                            color: changeColor,
                            fontFamily: "SF Pro Text",
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 58,
            color: const Color(0xFFE5E5EA),
          ),
      ],
    );
  }

  /// Row inside grouped card for Natural Gas
  Widget _buildNaturalGasRow(Map<String, String> data, {bool isLast = false}) {
    final change = data['change'] ?? '0.00';
    final changeColor = _getChangeColor(change);
    final bool isPositive = change.contains('+');
    final bool isNegative = change.contains('-');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4AC1FF), Color(0xFF007AFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.whatshot_rounded,
                  color: Colors.white,
                  size: 17,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['location'] ?? '',
                      style: TextStyle(
                        color: textPrimary,
                        fontFamily: "SF Pro Text",
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Natural Gas",
                      style: TextStyle(
                        color: textSecondary,
                        fontFamily: "SF Pro Text",
                        fontSize: 11.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    data['price'] ?? 'N/A',
                    style: TextStyle(
                      color: textPrimary,
                      fontFamily: "SF Pro Display",
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: changeColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPositive || isNegative)
                          Icon(
                            isPositive
                                ? Icons.arrow_drop_up_rounded
                                : Icons.arrow_drop_down_rounded,
                            color: changeColor,
                            size: 12,
                          ),
                        Text(
                          change,
                          style: TextStyle(
                            color: changeColor,
                            fontFamily: "SF Pro Text",
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 58,
            color: const Color(0xFFE5E5EA),
          ),
      ],
    );
  }
}
