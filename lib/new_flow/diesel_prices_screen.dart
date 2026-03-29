import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:usa_gas_price/new_flow/diesel_city_screen.dart';
import 'package:usa_gas_price/time/time_setup_screen.dart';

class DieselPriceScreen extends StatefulWidget {
  const DieselPriceScreen({super.key});

  @override
  State<DieselPriceScreen> createState() => _DieselPriceScreenState();
}

class _DieselPriceScreenState extends State<DieselPriceScreen>
    with TickerProviderStateMixin {
  List<Map<String, String>> dieselData = [];
  bool isLoading = true;
  String errorMessage = '';

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Color primaryBlue = const Color(0xFF007AFF);
  final Color backgroundGray = const Color(0xFFF2F2F7);
  final Color cardWhite = const Color(0xFFFFFFFF);
  final Color textPrimary = const Color(0xFF1C1C1E);
  final Color textSecondary = const Color(0xFF8E8E93);

  @override
  void initState() {
    super.initState();
    analytics.logScreenView(screenName: "US Diesel Prices Screen");

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

    _fetchDieselPrices();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchDieselPrices() async {
    const url = 'https://www.oilmonster.com/gas-price/diesel';

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

      final table = document.querySelector('table.table.gpricetable') ??
          document.querySelector('table.table-bordered');

      if (table == null) {
        throw Exception('Table not found on the page');
      }

      final rows = table.querySelectorAll('tbody tr');

      List<Map<String, String>> tempData = [];

      for (var row in rows) {
        final cells = row.querySelectorAll('td');

        if (cells.length >= 5) {
          final stateLink = cells[0].querySelector('a');
          final state = stateLink?.text.trim() ?? cells[0].text.trim();

          final currentPrice = cells[1].text.trim();
          final previousPrice = cells[2].text.trim();
          final change = cells[3].text.trim();
          final updated = cells[4].text.trim();

          tempData.add({
            'url': stateLink?.attributes['href'] ?? '',
            'state': state,
            'current': currentPrice,
            'previous': previousPrice,
            'change': change,
            'updated': updated,
          });
        }
      }

      if (mounted) {
        setState(() {
          dieselData = tempData;
          isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error scraping data: $e';
          isLoading = false;
        });
      }
    }
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
            "US Diesel Prices".toUpperCase(),
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
                              "State-wise Diesel Average",
                              style: TextStyle(
                                color: primaryBlue.withOpacity(0.8),
                                fontFamily: "SF Pro Text",
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (dieselData.isEmpty)
                              Center(
                                  child: Text("No diesel data found.",
                                      style: TextStyle(color: textSecondary)))
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: dieselData.length,
                                itemBuilder: (context, index) {
                                  final item = dieselData[index];
                                  return _buildStaggeredItem(
                                      index, _buildDieselCard(item));
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

  Widget _buildDieselCard(Map<String, String> item) {
    final changeText = item['change'] ?? '';
    final isUp = changeText.contains('+') || changeText.contains('priceup');
    final isDown = changeText.contains('-');
    final changeColor =
        isUp ? Colors.green : (isDown ? Colors.red : Colors.grey);

    return GestureDetector(
      onTap: () {
        // Get.to(
        //   () => DieselCityWiseScreen(
        //     stateName: item['state']!,
        //     stateUrl: item['url']!,
        //   ),
        // );
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
                    child: Icon(Icons.local_shipping_rounded,
                        color: primaryBlue, size: 18),
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
              const SizedBox(height: 16),
              _buildPriceRow('Current Price', item['current'] ?? '',
                  isBold: true, valueSize: 18),
              const Divider(height: 20, thickness: 0.5),
              _buildPriceRow('Previous Price', item['previous'] ?? ''),
              const Divider(height: 20, thickness: 0.5),
              _buildPriceRow('Change', changeText,
                  valueColor: changeColor, isBold: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value,
      {bool isBold = false, double valueSize = 15, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: textSecondary, fontSize: 14, fontFamily: "SF Pro Text")),
        Text(value,
            style: TextStyle(
              color: valueColor ?? textPrimary,
              fontSize: valueSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontFamily: "SF Pro Display",
            )),
      ],
    );
  }
}
