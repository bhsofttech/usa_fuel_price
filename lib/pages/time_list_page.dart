import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flip_panel_plus/flip_panel_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:usa_gas_price/controller/time_controller.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';

class TimeListPage extends StatefulWidget {
  const TimeListPage({super.key});

  @override
  State<TimeListPage> createState() => _TimeListPageState();
}

class _TimeListPageState extends State<TimeListPage>
    with TickerProviderStateMixin {
  final TimeController _timeController = Get.find();
  final Map<int, Timer> _timers = {};
  final Map<int, DateTime> _currentTimes = {};
  final GoogleAdsController _googleAdsController = Get.find();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // Modern iOS color palette matching other screens
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color darkBlue = const Color(0xFF0A4B9A);
  final Color lightBlue = const Color(0xFF4DA6FF);
  final Color backgroundGray = const Color(0xFFF2F2F7);
  final Color cardWhite = const Color(0xFFFFFFFF);
  final Color textPrimary = const Color(0xFF1C1C1E);
  final Color textSecondary = const Color(0xFF8E8E93);
  final Color separatorGray = const Color(0xFFD1D1D6);

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
    analytics.logScreenView(screenName: "World Time");
  }

  Future<void> callApi() async {
    await _timeController.fetchTime();
    await _timeController.loadFavorites();
  }

  @override
  void dispose() {
    for (var timer in _timers.values) {
      timer.cancel();
    }
    _fadeController.dispose();
    super.dispose();
  }

  void _startTimer(int index, DateTime initialTime) {
    _timers[index]?.cancel();
    _currentTimes[index] = _currentTimes[index] ?? initialTime;

    _timers[index] = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (mounted) {
          setState(() {
            _currentTimes[index] =
                _currentTimes[index]!.add(const Duration(seconds: 1));
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
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
          "World Time".toUpperCase(),
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
      ),
      body: SafeArea(
        child: Obx(
          () => _timeController.showLoading.value
              ? _buildLoadingIndicator()
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildTimeList(),
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
            "Loading World Times",
            style: TextStyle(
              color: textPrimary,
              fontFamily: "SF Pro Text",
              fontSize: 14, // Reduced font size
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 16), // Balanced padding
      itemCount: _timeController.getTimeInfo.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: 10), // Reduced separator
      itemBuilder: (context, index) {
        if (!_timers.containsKey(index)) {
          _startTimer(
            index,
            _timeController.getTimeInfo[index].timerCurrentTime!.toUtc(),
          );
        }

        final timeInfo = _timeController.getTimeInfo[index];
        return Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 12), // Reduced padding
          decoration: BoxDecoration(
            color: cardWhite,
            borderRadius: BorderRadius.circular(12), // Updated radius
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12, // Reduced blur
                spreadRadius: 0,
                offset: const Offset(0, 2), // Smaller offset
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 8, // Consistent size
                height: 8, // Consistent size
                margin: const EdgeInsets.only(right: 10), // Reduced margin
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: timeInfo.city,
                            style: TextStyle(
                              color: textPrimary,
                              fontFamily: "SF Pro Display",
                              fontSize: 16.0, // Consistent font size
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                          TextSpan(
                            text: " (${timeInfo.country})",
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
                    const SizedBox(height: 8), // Reduced spacing
                    FlipClockPlus.simple(
                      startTime:
                          _currentTimes[index]?.toLocal() ?? DateTime.now(),
                      digitColor: textPrimary,
                      backgroundColor: backgroundGray,
                      digitSize: 18.0, // Reduced size
                      height: 40, // Reduced height
                      width: 22, // Reduced width
                      centerGapSpace: 0.0,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(4.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
