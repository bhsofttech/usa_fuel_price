import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:usa_gas_price/time/time_setup_screen.dart';

class NationalAvgPrice extends StatefulWidget {
  const NationalAvgPrice({super.key});

  @override
  State<NationalAvgPrice> createState() => _NationalAvgPriceState();
}

class _NationalAvgPriceState extends State<NationalAvgPrice>
    with TickerProviderStateMixin {
  Map<String, Map<String, String>> gasPrices = {};
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
        final changeEl = box.querySelector('div[class*="wdprice"]');

        if (nameEl != null && priceEl != null) {
          final fuelType = nameEl.text.trim();
          final price = priceEl.text.trim();

          String change = '0.00';
          if (changeEl != null && changeEl != priceEl) {
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

      if (mounted) {
        setState(() {
          gasPrices = tempPrices;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          leadingWidth: 50,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.access_time_outlined,
                color: Color(0xFF007AFF),
              ),
              onPressed: () {
                Get.to(() => const TimeSetupScreen());
              },
            ).paddingOnly(bottom: 5),
          ],
          backgroundColor: cardWhite.withOpacity(0.95),
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          centerTitle: true,
          title: Text(
            "US National Gas Prices".toUpperCase(),
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
                  width: 0.33,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
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
                child: CircularProgressIndicator(
                  color: primaryBlue,
                ),
              )
            : errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textSecondary),
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
                            horizontal: 16.0, vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "National Average",
                              style: TextStyle(
                                color: primaryBlue.withOpacity(0.8),
                                fontFamily: "SF Pro Text",
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...gasPrices.entries
                                .toList()
                                .asMap()
                                .entries
                                .map((entry) {
                              int index = entry.key;
                              final fuel = entry.value.key;
                              final data = entry.value.value;
                              final change = data['change'] ?? '0.00';

                              return AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                        0,
                                        (1 - _animationController.value) *
                                            20 *
                                            (index + 1)),
                                    child: Opacity(
                                      opacity: _animationController.value,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: _buildPriceCard(fuel,
                                            data['price'] ?? 'N/A', change),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildPriceCard(String title, String price, String change) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [lightBlue, primaryBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_gas_station_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textPrimary,
                      fontFamily: "SF Pro Text",
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    'Change: $change',
                    style: TextStyle(
                      color: _getChangeColor(change),
                      fontFamily: "SF Pro Text",
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                color: textPrimary,
                fontFamily: "SF Pro Display",
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
