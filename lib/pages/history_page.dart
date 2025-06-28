import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:usa_gas_price/controller/time_controller.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
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

  DateTime selectedDate = DateTime.now();
  final DateFormat dateFormat = DateFormat('d MMMM yyyy');

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
      analytics.logScreenView(screenName: "Historical Events");
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> callApi() async {
    final DateFormat df = DateFormat('d MMMM');
    String today = df.format(selectedDate);
    await _timeController.fetchHistory(
      date: today.split(" ").first.toString().toLowerCase(),
      month: today.split(" ").last.toString().toLowerCase(),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final firstDayOfYear = DateTime(1900, 1, 1);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDayOfYear,
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: cardWhite,
              headerBackgroundColor: primaryBlue,
              headerForegroundColor: Colors.white,
              headerHeadlineStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: "SF Pro Display",
                letterSpacing: -0.3,
              ),
              dayStyle: TextStyle(
                fontFamily: "SF Pro Text",
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.24,
              ),
              todayBackgroundColor:
                  MaterialStateProperty.all(primaryBlue.withOpacity(0.12)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: primaryBlue,
                textStyle: const TextStyle(
                  fontFamily: "SF Pro Text",
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.41,
                ),
              ),
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: primaryBlue,
                textStyle: const TextStyle(
                  fontFamily: "SF Pro Text",
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.41,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      _googleAdsController.showAds();
      setState(() {
        selectedDate = picked;
      });
      final DateFormat df = DateFormat('d MMMM');
      String today = df.format(selectedDate);
      await _timeController.fetchHistory(
        date: today.split(" ").first.toString().toLowerCase(),
        month: today.split(" ").last.toString().toLowerCase(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Obx(
          () => _timeController.showHistoryLoading.value
              ? _buildLoadingIndicator()
              : _buildHistoryContent(),
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
        "Historical Events",
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

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 25,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                SpinKitFadingCircle(
                  color: primaryBlue,
                  size: 45.0,
                ),
                const SizedBox(height: 16),
                Text(
                  "Fetching Historical Events",
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: "SF Pro Text",
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "Loading events for ${dateFormat.format(selectedDate)}...",
            style: TextStyle(
              color: textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              fontFamily: "SF Pro Text",
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Text(
            "Select date",
            style: TextStyle(
              color: Colors.blue,
              fontFamily: "SF Pro Text",
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(selectedDate),
                  style: TextStyle(
                    color: textPrimary,
                    fontFamily: "SF Pro Text",
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "(${_timeController.getHistory.length} events)",
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
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _timeController.getHistory.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final event = _timeController.getHistory[index];
                return _buildEventCard(event, index == 0);
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
              Icons.history,
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
                  "Historical Events",
                  style: TextStyle(
                    color: textPrimary,
                    fontFamily: "SF Pro Display",
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(dynamic event, bool isFirstItem) {
    return Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 4, right: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryBlue, lightBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    event.title,
                    style: TextStyle(
                      color: textPrimary,
                      fontFamily: "SF Pro Display",
                      fontSize: isFirstItem ? 22.0 : 18.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (isFirstItem)
              Text(
                "Significant Event",
                style: TextStyle(
                  color: textSecondary,
                  fontFamily: "SF Pro Text",
                  fontSize: 15.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    backgroundGray,
                    backgroundGray.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
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
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.subTitle,
                    style: TextStyle(
                      color: textPrimary,
                      fontFamily: "SF Pro Display",
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.3,
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
