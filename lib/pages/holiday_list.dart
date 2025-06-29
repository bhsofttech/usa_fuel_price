import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:usa_gas_price/controller/time_controller.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';
import 'package:usa_gas_price/model/country_info.dart';

class HoliDayPage extends StatefulWidget {
  final CountryInfo countryInfo;
  const HoliDayPage({super.key, required this.countryInfo});

  @override
  State<HoliDayPage> createState() => _HoliDayPageState();
}

class _HoliDayPageState extends State<HoliDayPage>
    with TickerProviderStateMixin {
  final TimeController _timeController = Get.find();
  final GoogleAdsController _googleAdsController = Get.find();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

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
      _googleAdsController.showAds();
      analytics.logScreenView(
          screenName: "${widget.countryInfo.country} Holidays");
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> callApi() async {
    await _timeController.fetchHoliDay(link: widget.countryInfo.link);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Obx(
          () => _timeController.showHolyDayLoading.value
              ? _buildLoadingIndicator()
              : _buildHolidayList(),
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
        "${widget.countryInfo.country} Holidays",
        style: TextStyle(
          color: textPrimary,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitFadingCircle(
            color: primaryBlue,
            size: 36.0, // Smaller spinner
          ),
          const SizedBox(height: 12), // Reduced spacing
          Text(
            "Fetching Holidays",
            style: TextStyle(
              color: textPrimary,
              fontSize: 14, // Reduced font size
              fontWeight: FontWeight.w600,
              fontFamily: "SF Pro Text",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHolidayList() {
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
              itemCount: _timeController.getHoliDays.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 10), // Reduced separator
              itemBuilder: (context, index) {
                final holiday = _timeController.getHoliDays[index];
                return _buildHolidayCard(holiday, index == 0);
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
              Icons.celebration,
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
                  "${widget.countryInfo.country} Holidays",
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
                  "${_timeController.getHoliDays.length} holidays listed",
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

  Widget _buildHolidayCard(dynamic holiday, bool isFirstItem) {
    return Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _getHolidayColor(holiday.type),
                        _getHolidayColor(holiday.type).withOpacity(0.7)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getHolidayIcon(holiday.type),
                    color: Colors.white,
                    size: 14, // Smaller icon
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    holiday.name,
                    style: TextStyle(
                      color: textPrimary,
                      fontFamily: "SF Pro Display",
                      fontSize: 16.0, // Reduced font sizes
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12), // Reduced spacing
            Container(
              padding: const EdgeInsets.all(16), // Reduced padding
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    backgroundGray,
                    backgroundGray.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12), // Smaller radius
                border: Border.all(
                  color: separatorGray.withOpacity(0.3),
                  width: 0.5,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.calendar_today,
                          color: successGreen,
                          title: "Date",
                          value: "${holiday.day} • ${holiday.date}",
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 44, // Reduced height
                        color: separatorGray.withOpacity(0.5),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12), // Reduced margin
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          icon: Icons.label,
                          color: warningOrange,
                          title: "Type",
                          value: holiday.type.isNotEmpty ? holiday.type : "N/A",
                        ),
                      ),
                    ],
                  ),
                  if (holiday.comment.isNotEmpty) ...[
                    const SizedBox(height: 12), // Reduced spacing
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10), // Reduced padding
                      decoration: BoxDecoration(
                        color: cardWhite,
                        borderRadius:
                            BorderRadius.circular(10), // Smaller radius
                        border: Border.all(
                          color: separatorGray.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Details",
                            style: TextStyle(
                              color: textSecondary,
                              fontFamily: "SF Pro Text",
                              fontSize: 12.0, // Reduced font size
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 4), // Reduced spacing
                          Text(
                            holiday.comment,
                            style: TextStyle(
                              color: textPrimary,
                              fontFamily: "SF Pro Display",
                              fontSize: 14.0, // Reduced font size
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8), // Reduced padding
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10), // Smaller radius
          ),
          child: Icon(
            icon,
            color: color,
            size: 18, // Smaller icon
          ),
        ),
        const SizedBox(height: 8), // Reduced spacing
        Text(
          title,
          style: TextStyle(
            color: textSecondary,
            fontFamily: "SF Pro Text",
            fontSize: 12.0, // Reduced font size
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 4), // Reduced spacing
        Text(
          value,
          style: TextStyle(
            color: color,
            fontFamily: "SF Pro Display",
            fontSize: 16.0, // Reduced font size
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Color _getHolidayColor(String type) {
    if (type.toLowerCase().contains('public')) {
      return successGreen; // Green for public holidays
    } else if (type.toLowerCase().contains('observance')) {
      return primaryBlue; // Blue for observances
    } else if (type.toLowerCase().contains('season')) {
      return warningOrange; // Orange for seasons
    }
    return primaryBlue; // Default color
  }

  IconData _getHolidayIcon(String type) {
    if (type.toLowerCase().contains('public')) {
      return Icons.celebration;
    } else if (type.toLowerCase().contains('observance')) {
      return Icons.visibility;
    } else if (type.toLowerCase().contains('season')) {
      return Icons.ac_unit;
    }
    return Icons.event;
  }
}
