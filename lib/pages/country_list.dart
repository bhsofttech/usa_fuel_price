import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:usa_gas_price/controller/time_controller.dart';
import 'package:usa_gas_price/pages/holiday_list.dart';

class CountryPage extends StatefulWidget {
  const CountryPage({super.key});

  @override
  State<CountryPage> createState() => _CountryPageState();
}

class _CountryPageState extends State<CountryPage>
    with TickerProviderStateMixin {
  final TimeController _timeController = Get.find();

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

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      callApi();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> callApi() async {
    await _timeController.fetchCountry();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Obx(
          () => _timeController.showCountryLoading.value
              ? _buildLoadingIndicator()
              : _buildCountryList(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: cardWhite,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.1),
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      centerTitle: true,
      title: Text(
        "Countries",
        style: TextStyle(
          color: primaryBlue,
          fontFamily: "SF Pro Display",
          fontSize: 16.0, // Reduced font size
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

  Widget _buildLoadingIndicator() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16), // Reduced padding
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(12), // Smaller radius
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12, // Reduced blur
              spreadRadius: 0,
              offset: const Offset(0, 2), // Smaller offset
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpinKitFadingCircle(
              color: primaryBlue,
              size: 36.0, // Smaller spinner
            ),
            const SizedBox(height: 12), // Reduced spacing
            Text(
              "Fetching Countries",
              style: TextStyle(
                color: textPrimary,
                fontSize: 14, // Reduced font size
                fontWeight: FontWeight.w600,
                fontFamily: "SF Pro Text",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderStats(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 16), // Balanced padding
              itemCount: _timeController.getCountrys.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 10), // Reduced separator
              itemBuilder: (context, index) {
                final country = _timeController.getCountrys[index];
                return _buildCountryCard(country, index == 0);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStats() {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 16), // Balanced margin
      padding: const EdgeInsets.all(16), // Reduced padding
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // Smaller radius
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
            padding: const EdgeInsets.all(8), // Reduced padding
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue, lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10), // Smaller radius
            ),
            child: const Icon(
              Icons.flag,
              color: Colors.white,
              size: 20, // Smaller icon
            ),
          ),
          const SizedBox(width: 12), // Reduced spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Countries",
                  style: TextStyle(
                    color: textPrimary,
                    fontFamily: "SF Pro Display",
                    fontSize: 18.0, // Reduced font size
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4), // Tighter spacing
                Text(
                  "${_timeController.getCountrys.length} countries available",
                  style: TextStyle(
                    color: textSecondary,
                    fontFamily: "SF Pro Text",
                    fontSize: 13.0, // Reduced font size
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

  Widget _buildCountryCard(dynamic country, bool isFirstItem) {
    return InkWell(
      borderRadius: BorderRadius.circular(12), // Smaller radius
      onTap: () {
        Get.to(() => HoliDayPage(countryInfo: country),
            transition: Transition.cupertino);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), // Smaller radius
          color: cardWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12, // Reduced blur
              spreadRadius: 0,
              offset: const Offset(0, 2), // Smaller offset
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16), // Reduced padding
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryBlue, lightBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.flag,
                  color: Colors.white,
                  size: 14, // Smaller icon
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      country.country.toString().trim(),
                      style: TextStyle(
                        color: textPrimary,
                        fontFamily: "SF Pro Display",
                        fontSize: 16.0, // Reduced font sizes
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4), // Reduced spacing

                    Text(
                      "Select to view holidays",
                      style: TextStyle(
                        color: textSecondary,
                        fontFamily: "SF Pro Text",
                        fontSize: 13.0, // Reduced font size
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6), // Reduced padding
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10), // Smaller radius
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: primaryBlue,
                  size: 18, // Smaller icon
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
