import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:usa_gas_price/controller/google_ads_controller.dart';
import 'package:usa_gas_price/new_flow/gas_city_screen.dart';
import 'package:usa_gas_price/time/time_setup_screen.dart';

class GasPricesScreen extends StatefulWidget {
  const GasPricesScreen({super.key});

  @override
  State<GasPricesScreen> createState() => _GasPricesScreenState();
}

class _GasPricesScreenState extends State<GasPricesScreen>
    with TickerProviderStateMixin {
  Map<String, Map<String, String>> nationalPrices = {};
  List<Map<String, String>> statePrices = [];
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
    analytics.logScreenView(screenName: "USA Gas Scraper Screen");

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fetchGasPrices();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchGasPrices() async {
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
        throw Exception('HTTP Error: ${response.statusCode}');
      }

      final document = parser.parse(response.body);

      // === 1. Parse National Averages ===
      Map<String, Map<String, String>> national = {};
      final wdNames = document.querySelectorAll('h4.wdname');
      final wdPrices = document.querySelectorAll('div.wdprice');
      final wdChanges = document.querySelectorAll('div[class*="wdprice"]');

      for (int i = 0; i < wdNames.length && i < wdPrices.length; i++) {
        final type = wdNames[i].text.trim();
        final price = wdPrices[i].text.trim();
        String change = '0.00';

        if (i < wdChanges.length) {
          final changeEl = wdChanges[i];
          if (changeEl != wdPrices[i]) {
            change = changeEl.text.trim();
          }
        }
        national[type] = {'price': price, 'change': change};
      }

      // === 2. Parse State Table ===
      dom.Element? table = document.querySelector('table.gpricetable') ??
          document.querySelector('table.table-bordered') ??
          document.querySelector('table.table');

      List<Map<String, String>> states = [];

      if (table != null) {
        final rows = table.querySelectorAll('tbody tr');

        for (var row in rows) {
          final cells = row.querySelectorAll('td');
          if (cells.length >= 5) {
            final stateLink = cells[0].querySelector('a');
            final state = (stateLink?.text ?? cells[0].text).trim();

            final regular = cells[1].text.trim();
            final midgrade = cells[2].text.trim();
            final premium = cells[3].text.trim();
            final diesel = cells[4].text.trim();

            states.add({
              'url': stateLink?.attributes['href'] ?? '',
              'state': state,
              'regular': regular,
              'midgrade': midgrade,
              'premium': premium,
              'diesel': diesel,
            });
          }
        }
      }

      if (mounted) {
        setState(() {
          nationalPrices = national;
          statePrices = states;
          isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Scraping error: $e';
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
            "US Gas Prices".toUpperCase(),
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
                child: CircularProgressIndicator(color: primaryBlue),
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
                              "State-wise Averages",
                              style: TextStyle(
                                color: primaryBlue.withOpacity(0.8),
                                fontFamily: "SF Pro Text",
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (statePrices.isEmpty)
                              Center(
                                  child: Text("No state data found.",
                                      style: TextStyle(color: textSecondary)))
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: statePrices.length,
                                itemBuilder: (context, index) {
                                  final item = statePrices[index];
                                  return _buildStaggeredItem(
                                      index + nationalPrices.length,
                                      _buildStateCard(item));
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildStaggeredItem(int index, Widget child) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(
              0, (1 - _animationController.value) * 20 * (index + 1) * 0.2),
          child: Opacity(
            opacity: _animationController.value,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: child,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceCard(String title, String price, String change) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
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
                ),
              ),
              child: const Icon(Icons.local_gas_station_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  Text('Change: $change',
                      style: TextStyle(
                          color: _getChangeColor(change), fontSize: 12)),
                ],
              ),
            ),
            Text(price,
                style: TextStyle(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "SF Pro Display")),
          ],
        ),
      ),
    );
  }

  Widget _buildStateCard(Map<String, String> item) {
    return GestureDetector(
      onTap: () {
        Get.find<GoogleAdsController>().navigateWithAd(
            nextPage: GasCityWiseScreen(
                stateName: item['state']!, stateUrl: item['url']!));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: cardWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child:
                        Icon(Icons.map_rounded, color: primaryBlue, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item['state'] ?? '',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                      fontFamily: "SF Pro Text",
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 16),
              // _buildPriceRow('Regular', item['regular'] ?? ''),
              // const Divider(height: 20, thickness: 0.5),
              // _buildPriceRow('Midgrade', item['midgrade'] ?? ''),
              // const Divider(height: 20, thickness: 0.5),
              // _buildPriceRow('Premium', item['premium'] ?? ''),
              // const Divider(height: 20, thickness: 0.5),
              // _buildPriceRow('Diesel', item['diesel'] ?? '', isBold: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: textSecondary, fontSize: 14, fontFamily: "SF Pro Text")),
        Text(value,
            style: TextStyle(
              color: textPrimary,
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontFamily: "SF Pro Display",
            )),
      ],
    );
  }
}
