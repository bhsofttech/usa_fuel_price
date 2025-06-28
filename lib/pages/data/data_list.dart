import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'data_details_screen.dart';

class DataListScreen extends StatefulWidget {
  const DataListScreen({super.key});

  @override
  State<DataListScreen> createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen>
    with TickerProviderStateMixin {
  // Modern iOS color palette matching gas_state_wise_price.dart
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color darkBlue = const Color(0xFF0A4B9A);
  final Color lightBlue = const Color(0xFF4DA6FF);
  final Color backgroundGray = const Color(0xFFF2F2F7);
  final Color cardWhite = const Color(0xFFFFFFFF);
  final Color textPrimary = const Color(0xFF1C1C1E);
  final Color textSecondary = const Color(0xFF8E8E93);
  final Color separatorGray = const Color(0xFFD1D1D6);
  final Color successGreen = const Color(0xFF34C759);
  final Color warningOrange = const Color(0xFFFF9500);
  final Color errorRed = const Color(0xFFFF3B30);
  final Color purpleAccent = const Color(0xFFAF52DE);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, String>> dataItems = [
    {
      "title": "World Currencies Price",
      "endPoint": "https://tradingeconomics.com/currencies",
    },
    {
      "title": "World Crypto Price",
      "endPoint": "https://tradingeconomics.com/crypto",
    },
    {
      "title": "World Bonds",
      "endPoint": "https://tradingeconomics.com/bonds",
    },
    {
      "title": "GDP Growth Rate By Country",
      "endPoint":
          "https://tradingeconomics.com/country-list/gdp-growth-rate?continent=world",
    },
    {
      "title": "Employment Rate",
      "endPoint": "https://tradingeconomics.com/country-list/employment-rate",
    },
    {
      "title": "Unemployment Rate",
      "endPoint":
          "https://tradingeconomics.com/country-list/unemployment-rate?continent=world",
    },
    {
      "title": "Minimum Wages",
      "endPoint": "https://tradingeconomics.com/country-list/minimum-wages",
    },
    {
      "title": "Central Bank Balance Sheet",
      "endPoint":
          "https://tradingeconomics.com/country-list/central-bank-balance-sheet",
    },
    {
      "title": "Foreign Exchange Reserves",
      "endPoint":
          "https://tradingeconomics.com/country-list/foreign-exchange-reserves",
    },
    {
      "title": "Crude Oil Production",
      "endPoint":
          "https://tradingeconomics.com/country-list/crude-oil-production",
    },
    {
      "title": "Gold Reserves",
      "endPoint": "https://tradingeconomics.com/country-list/gold-reserves",
    },
    {
      "title": "GDP Per Capita",
      "endPoint": "https://tradingeconomics.com/country-list/gdp-per-capita",
    },
    {
      "title": "GDP Per Capita PPP",
      "endPoint":
          "https://tradingeconomics.com/country-list/gdp-per-capita-ppp",
    },
    {
      "title": "Military Expenditure",
      "endPoint":
          "https://tradingeconomics.com/country-list/military-expenditure",
    },
    {
      "title": "Corporate Tax Rate",
      "endPoint":
          "https://tradingeconomics.com/country-list/corporate-tax-rate",
    },
    {
      "title": "Personal Income Tax Rate",
      "endPoint":
          "https://tradingeconomics.com/country-list/personal-income-tax-rate",
    },
    {
      "title": "Hospitals",
      "endPoint": "https://tradingeconomics.com/country-list/hospitals",
    },
    {
      "title": "Medical Doctors",
      "endPoint": "https://tradingeconomics.com/country-list/medical-doctors",
    },
    {
      "title": "ICU Beds",
      "endPoint": "https://tradingeconomics.com/country-list/icu-beds",
    },
    {
      "title": "Nurses",
      "endPoint": "https://tradingeconomics.com/country-list/nurses",
    },
    {
      "title": "CO2 Emissions",
      "endPoint": "https://tradingeconomics.com/country-list/co2-emissions",
    },
    {
      "title": "Natural Gas Stocks Capacity",
      "endPoint":
          "https://tradingeconomics.com/country-list/natural-gas-stocks-capacity",
    },
  ];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Simulate loading for consistency with gas_state_wise_price.dart
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _animationController.forward();
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Container(
          color: backgroundGray,
          child: _isLoading ? _buildLoadingState() : _buildDataList(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leadingWidth: 50,
      backgroundColor: cardWhite,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      title: Text(
        "Economic Data".toUpperCase(),
        style: TextStyle(
          color: primaryBlue,
          fontFamily: "SF Pro Display",
          fontSize: 17.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      iconTheme: IconThemeData(color: primaryBlue),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: cardWhite,
          border: Border(
            bottom: BorderSide(
              color: separatorGray,
              width: 0.33,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              SpinKitFadingCircle(
                color: primaryBlue,
                size: 40.0,
              ),
              const SizedBox(height: 16),
              Text(
                "Fetching Economic Data",
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: "SF Pro Text",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildHeaderStats(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: dataItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = dataItems[index];
                return _buildDataCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStats() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue.withOpacity(0.08),
            lightBlue.withOpacity(0.04),
          ],
        ),
        border: Border.all(
          color: primaryBlue.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue, lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.bar_chart,
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
                  "Economic Data",
                  style: TextStyle(
                    color: textPrimary,
                    fontFamily: "SF Pro Display",
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${dataItems.length} categories available",
                  style: TextStyle(
                    color: textSecondary,
                    fontFamily: "SF Pro Text",
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(Map<String, String> item) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Get.to(
        () => DataDetailsScreen(
          title: item["title"]!,
          endPoint: item["endPoint"]!,
        ),
        transition: Transition.cupertino,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: cardWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 25,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryBlue, lightBlue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.bar_chart,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item["title"]!,
                            style: TextStyle(
                              color: textPrimary,
                              fontFamily: "SF Pro Display",
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Tap to view details",
                      style: TextStyle(
                        color: textSecondary,
                        fontFamily: "SF Pro Text",
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: primaryBlue,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
