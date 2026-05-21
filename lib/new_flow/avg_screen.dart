import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:usa_gas_price/controller/google_ads_controller.dart';
import 'package:usa_gas_price/new_flow/crude_oil_list_screen.dart';
import 'package:usa_gas_price/new_flow/data_details_screen.dart';
import 'package:usa_gas_price/new_flow/natural_gas_list_screen.dart';
import 'package:usa_gas_price/new_flow/electricity_list_screen.dart';
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

                            // International Crude Oil Card
                            _buildNavigationCard(
                              label: "International Crude Oil",
                              subtitle: "Live Market Prices",
                              icon: Icons.opacity_rounded,
                              color1: const Color(0xFFFF9500),
                              color2: const Color(0xFFFF3B30),
                              onTap: () {
                                Get.find<GoogleAdsController>().navigateWithAd(
                                    nextPage: const CrudeOilListScreen());
                              },
                            ),

                            // USA Natural Gas Card
                            _buildNavigationCard(
                              label: "USA Natural Gas",
                              subtitle: "Natural Gas Indices",
                              icon: Icons.whatshot_rounded,
                              color1: const Color(0xFF5AC8FA),
                              color2: const Color(0xFF007AFF),
                              onTap: () {
                                Get.find<GoogleAdsController>().navigateWithAd(
                                    nextPage: const NaturalGasListScreen());
                              },
                            ),

                            //USA Electricity Prices
                            _buildNavigationCard(
                              label: "USA Electricity Prices",
                              subtitle: "Electricity Indices",
                              icon: Icons.power_rounded,
                              color1: const Color(0xFFFFD60A),
                              color2: const Color(0xFFFF9F0A),
                              onTap: () {
                                Get.find<GoogleAdsController>().navigateWithAd(
                                    nextPage: const ElectricityListScreen());
                              },
                            ),

                            // Finance Section
                            _buildNavigationCard(
                              label: "World Currencies Price",
                              subtitle: "Global Exchange Rates",
                              icon: Icons.currency_exchange_rounded,
                              color1: const Color(0xFFAF52DE),
                              color2: const Color(0xFF5856D6),
                              onTap: () => Get.find<GoogleAdsController>().navigateWithAd(
                                nextPage: const DataDetailsScreen(
                                  title: "World Currencies Price",
                                  endPoint: "https://tradingeconomics.com/currencies",
                                ),
                              ),
                            ),
                            _buildNavigationCard(
                              label: "World Crypto Price",
                              subtitle: "Digital Asset Markets",
                              icon: Icons.currency_bitcoin_rounded,
                              color1: const Color(0xFF5856D6),
                              color2: const Color(0xFF343396),
                              onTap: () => Get.find<GoogleAdsController>().navigateWithAd(
                                nextPage: const DataDetailsScreen(
                                  title: "World Crypto Price",
                                  endPoint: "https://tradingeconomics.com/crypto",
                                ),
                              ),
                            ),
                            _buildNavigationCard(
                              label: "World Bonds",
                              subtitle: "Fixed Income Securities",
                              icon: Icons.analytics_rounded,
                              color1: const Color(0xFF5E5CE6),
                              color2: const Color(0xFF24235C),
                              onTap: () => Get.find<GoogleAdsController>().navigateWithAd(
                                nextPage: const DataDetailsScreen(
                                  title: "World Bonds",
                                  endPoint: "https://tradingeconomics.com/bonds",
                                ),
                              ),
                            ),

                            // Economy Section
                            _buildNavigationCard(
                              label: "GDP Growth Rate By Country",
                              subtitle: "Economic Performance",
                              icon: Icons.trending_up_rounded,
                              color1: const Color(0xFF34C759),
                              color2: const Color(0xFF1D943B),
                              onTap: () => Get.find<GoogleAdsController>().navigateWithAd(
                                nextPage: const DataDetailsScreen(
                                  title: "GDP Growth Rate By Country",
                                  endPoint: "https://tradingeconomics.com/country-list/gdp-growth-rate?continent=world",
                                ),
                              ),
                            ),
                            _buildNavigationCard(
                              label: "Employment Rate",
                              subtitle: "Workforce Participation",
                              icon: Icons.people_rounded,
                              color1: const Color(0xFF30B0C7),
                              color2: const Color(0xFF1E8A9C),
                              onTap: () => Get.find<GoogleAdsController>().navigateWithAd(
                                nextPage: const DataDetailsScreen(
                                  title: "Employment Rate",
                                  endPoint: "https://tradingeconomics.com/country-list/employment-rate",
                                ),
                              ),
                            ),
                            _buildNavigationCard(
                              label: "Unemployment Rate",
                              subtitle: "Job Market Statistics",
                              icon: Icons.person_search_rounded,
                              color1: const Color(0xFFFF453A),
                              color2: const Color(0xFFD70015),
                              onTap: () => Get.find<GoogleAdsController>().navigateWithAd(
                                nextPage: const DataDetailsScreen(
                                  title: "Unemployment Rate",
                                  endPoint: "https://tradingeconomics.com/country-list/unemployment-rate?continent=world",
                                ),
                              ),
                            ),
                            _buildNavigationCard(
                              label: "Minimum Wages",
                              subtitle: "Labor Compensation",
                              icon: Icons.payments_rounded,
                              color1: const Color(0xFF32D74B),
                              color2: const Color(0xFF248A3D),
                              onTap: () => Get.find<GoogleAdsController>().navigateWithAd(
                                nextPage: const DataDetailsScreen(
                                  title: "Minimum Wages",
                                  endPoint: "https://tradingeconomics.com/country-list/minimum-wages",
                                ),
                              ),
                            ),

                            // Banking & Reserves
                            _buildNavigationCard(
                              label: "Central Bank Balance Sheet",
                              subtitle: "Monetary Policy Data",
                              icon: Icons.account_balance_rounded,
                              color1: const Color(0xFF007AFF),
                              color2: const Color(0xFF0040DD),
                              onTap: () => Get.find<GoogleAdsController>().navigateWithAd(
                                nextPage: const DataDetailsScreen(
                                  title: "Central Bank Balance Sheet",
                                  endPoint: "https://tradingeconomics.com/country-list/central-bank-balance-sheet",
                                ),
                              ),
                            ),
                            _buildNavigationCard(
                              label: "Foreign Exchange Reserves",
                              subtitle: "National Currency Assets",
                              icon: Icons.savings_rounded,
                              color1: const Color(0xFF64D2FF),
                              color2: const Color(0xFF007AFF),
                              onTap: () => Get.find<GoogleAdsController>().navigateWithAd(
                                nextPage: const DataDetailsScreen(
                                  title: "Foreign Exchange Reserves",
                                  endPoint: "https://tradingeconomics.com/country-list/foreign-exchange-reserves",
                                ),
                              ),
                            ),

                            // Resources & Energy
                            _buildNavigationCard(
                              label: "Crude Oil Production",
                              subtitle: "Energy Output Stats",
                              icon: Icons.oil_barrel_rounded,
                              color1: const Color(0xFFFF9500),
                              color2: const Color(0xFF8B4513),
                              onTap: () => Get.find<GoogleAdsController>().navigateWithAd(
                                nextPage: const DataDetailsScreen(
                                  title: "Crude Oil Production",
                                  endPoint: "https://tradingeconomics.com/country-list/crude-oil-production",
                                ),
                              ),
                            ),
                            _buildNavigationCard(
                              label: "Gold Reserves",
                              subtitle: "Precious Metal Holdings",
                              icon: Icons.toll_rounded,
                              color1: const Color(0xFFFFD60A),
                              color2: const Color(0xFFFF9F0A),
                              onTap: () => Get.find<GoogleAdsController>().navigateWithAd(
                                nextPage: const DataDetailsScreen(
                                  title: "Gold Reserves",
                                  endPoint: "https://tradingeconomics.com/country-list/gold-reserves",
                                ),
                              ),
                            ),

                            // GDP Detailed
                            _buildNavigationCard(
                              label: "GDP Per Capita",
                              subtitle: "Individual Economic Share",
                              icon: Icons.bar_chart_rounded,
                              color1: const Color(0xFF34C759),
                              color2: const Color(0xFF135D26),
                              onTap: () => Get.find<GoogleAdsController>().navigateWithAd(
                                nextPage: const DataDetailsScreen(
                                  title: "GDP Per Capita",
                                  endPoint: "https://tradingeconomics.com/country-list/gdp-per-capita",
                                ),
                              ),
                            ),
                            _buildNavigationCard(
                              label: "GDP Per Capita PPP",
                              subtitle: "Purchasing Power Parity",
                              icon: Icons.shopping_cart_rounded,
                              color1: const Color(0xFF30D158),
                              color2: const Color(0xFF1D943B),
                              onTap: () => Get.find<GoogleAdsController>().navigateWithAd(
                                nextPage: const DataDetailsScreen(
                                  title: "GDP Per Capita PPP",
                                  endPoint: "https://tradingeconomics.com/country-list/gdp-per-capita-ppp",
                                ),
                              ),
                            ),

                            // Governance & Tax
                            _buildNavigationCard(
                              label: "Military Expenditure",
                              subtitle: "Defense Spending Data",
                              icon: Icons.security_rounded,
                              color1: const Color(0xFF8E8E93),
                              color2: const Color(0xFF48484A),
                              onTap: () => Get.find<GoogleAdsController>().navigateWithAd(
                                nextPage: const DataDetailsScreen(
                                  title: "Military Expenditure",
                                  endPoint: "https://tradingeconomics.com/country-list/military-expenditure",
                                ),
                              ),
                            ),
                            _buildNavigationCard(
                              label: "Corporate Tax Rate",
                              subtitle: "Business Taxation Stats",
                              icon: Icons.business_rounded,
                              color1: const Color(0xFF5856D6),
                              color2: const Color(0xFF24235C),
                              onTap: () => Get.find<GoogleAdsController>().navigateWithAd(
                                nextPage: const DataDetailsScreen(
                                  title: "Corporate Tax Rate",
                                  endPoint: "https://tradingeconomics.com/country-list/corporate-tax-rate",
                                ),
                              ),
                            ),
                            _buildNavigationCard(
                              label: "Personal Income Tax Rate",
                              subtitle: "Individual Tax Burdens",
                              icon: Icons.person_rounded,
                              color1: const Color(0xFFBF5AF2),
                              color2: const Color(0xFF5E5CE6),
                              onTap: () => Get.find<GoogleAdsController>().navigateWithAd(
                                nextPage: const DataDetailsScreen(
                                  title: "Personal Income Tax Rate",
                                  endPoint: "https://tradingeconomics.com/country-list/personal-income-tax-rate",
                                ),
                              ),
                            ),

                            // Healthcare Section
                            _buildNavigationCard(
                              label: "Hospitals",
                              subtitle: "Healthcare Infrastructure",
                              icon: Icons.local_hospital_rounded,
                              color1: const Color(0xFFFF375F),
                              color2: const Color(0xFFBF1131),
                              onTap: () => Get.find<GoogleAdsController>().navigateWithAd(
                                nextPage: const DataDetailsScreen(
                                  title: "Hospitals",
                                  endPoint: "https://tradingeconomics.com/country-list/hospitals",
                                ),
                              ),
                            ),
                            _buildNavigationCard(
                              label: "Medical Doctors",
                              subtitle: "Physician Workforce",
                              icon: Icons.health_and_safety_rounded,
                              color1: const Color(0xFFFF2D55),
                              color2: const Color(0xFFD70015),
                              onTap: () => Get.find<GoogleAdsController>().navigateWithAd(
                                nextPage: const DataDetailsScreen(
                                  title: "Medical Doctors",
                                  endPoint: "https://tradingeconomics.com/country-list/medical-doctors",
                                ),
                              ),
                            ),
                            _buildNavigationCard(
                              label: "ICU Beds",
                              subtitle: "Critical Care Capacity",
                              icon: Icons.bed_rounded,
                              color1: const Color(0xFFFF453A),
                              color2: const Color(0xFFBF1131),
                              onTap: () => Get.find<GoogleAdsController>().navigateWithAd(
                                nextPage: const DataDetailsScreen(
                                  title: "ICU Beds",
                                  endPoint: "https://tradingeconomics.com/country-list/icu-beds",
                                ),
                              ),
                            ),
                            _buildNavigationCard(
                              label: "Nurses",
                              subtitle: "Nursing Staff Statistics",
                              icon: Icons.medical_services_rounded,
                              color1: const Color(0xFFFF375F),
                              color2: const Color(0xFFFF2D55),
                              onTap: () => Get.find<GoogleAdsController>().navigateWithAd(
                                nextPage: const DataDetailsScreen(
                                  title: "Nurses",
                                  endPoint: "https://tradingeconomics.com/country-list/nurses",
                                ),
                              ),
                            ),

                            // Environment & Infrastructure
                            _buildNavigationCard(
                              label: "CO2 Emissions",
                              subtitle: "Environmental Impact",
                              icon: Icons.cloud_rounded,
                              color1: const Color(0xFF636366),
                              color2: const Color(0xFF1C1C1E),
                              onTap: () => Get.find<GoogleAdsController>().navigateWithAd(
                                nextPage: const DataDetailsScreen(
                                  title: "CO2 Emissions",
                                  endPoint: "https://tradingeconomics.com/country-list/co2-emissions",
                                ),
                              ),
                            ),
                            _buildNavigationCard(
                              label: "Natural Gas Stocks Capacity",
                              subtitle: "Energy Storage Stats",
                              icon: Icons.storage_rounded,
                              color1: const Color(0xFF0A84FF),
                              color2: const Color(0xFF0040DD),
                              onTap: () => Get.find<GoogleAdsController>().navigateWithAd(
                                nextPage: const DataDetailsScreen(
                                  title: "Natural Gas Stocks Capacity",
                                  endPoint: "https://tradingeconomics.com/country-list/natural-gas-stocks-capacity",
                                ),
                              ),
                            ),
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

  /// Stylized navigation card with gradient and watermark
  Widget _buildNavigationCard({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color1,
    required Color color2,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 75,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: color2.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Watermark Icon
            Positioned(
              right: -10,
              bottom: -15,
              child: Icon(
                icon,
                size: 85,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Icon Container
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Text Content
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: "SF Pro Display",
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontFamily: "SF Pro Text",
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action Icon
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: color2,
                      size: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
