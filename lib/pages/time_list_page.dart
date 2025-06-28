import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flip_panel_plus/flip_panel_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:usa_gas_price/controller/time_controller.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';

class TimeListPage extends StatefulWidget {
  const TimeListPage({super.key});

  @override
  State<TimeListPage> createState() => _TimeListPageState();
}

class _TimeListPageState extends State<TimeListPage> {
  final TimeController _timeController = Get.find();
  final Map<int, Timer> _timers = {};
  final Map<int, DateTime> _currentTimes = {};
  final GoogleAdsController _googleAdsController = Get.find();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color darkBlue = const Color(0xFF0A4B9A);

  @override
  void initState() {
    super.initState();
    callApi();
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
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          "World Time",
          style: TextStyle(
            color: Color(0xFF0A4B9A),
            fontFamily: "SF Pro Display",
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0A4B9A)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFD1D1D6),
                width: 0.5,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => _timeController.showLoading.value
              ? _buildLoadingIndicator()
              : _buildTimeList(),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCircle(
            color: primaryBlue,
            size: 40.0,
          ),
          const SizedBox(height: 20),
          Text(
            "Loading World Times...",
            style: TextStyle(
              color: darkBlue.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: "SF Pro Text",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _timeController.getTimeInfo.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        thickness: 0.5,
        color: Color(0xFFD1D1D6),
      ),
      itemBuilder: (context, index) {
        if (!_timers.containsKey(index)) {
          _startTimer(
            index,
            _timeController.getTimeInfo[index].timerCurrentTime!.toUtc(),
          );
        }

        final timeInfo = _timeController.getTimeInfo[index];
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(0),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: timeInfo.city,
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontFamily: "SF Pro Text",
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: " (${timeInfo.country})",
                                  style: TextStyle(
                                    color: const Color(0xFF8E8E93),
                                    fontFamily: "SF Pro Text",
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: FlipClockPlus.simple(
                        startTime:
                            _currentTimes[index]?.toLocal() ?? DateTime.now(),
                        digitColor: darkBlue,
                        backgroundColor: Colors.transparent,
                        digitSize: 20.0,
                        height: 50,
                        width: 25,
                        centerGapSpace: 0.0,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4.0),
                        ),
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
