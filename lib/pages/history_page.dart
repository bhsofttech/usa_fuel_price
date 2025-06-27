import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:usa_gas_price/controller/time_controller.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final TimeController _timeController = Get.find();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color darkBlue = const Color(0xFF0A4B9A);

  DateTime selectedDate = DateTime.now();
  final DateFormat dateFormat = DateFormat('d MMMM yyyy');

  @override
  void initState() {
    super.initState();
    callApi();
    analytics.logScreenView(screenName: "Historical Events");
  }

  Future<void> callApi() async {
    final DateFormat df = DateFormat('d MMMM');
    String today = df.format(DateTime.now());
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
              backgroundColor: Colors.white,
              headerBackgroundColor: primaryBlue,
              headerForegroundColor: Colors.white,
              headerHeadlineStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                fontFamily: "SF Pro Display",
              ),
              dayStyle: TextStyle(
                fontFamily: "SF Pro Text",
                color: darkBlue,
              ),
              todayBackgroundColor:
                  MaterialStateProperty.all(primaryBlue.withOpacity(0.1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      Get.find<GoogleAdsController>().showAds();
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
      backgroundColor: const Color(0xFFF2F2F7), // iOS style background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          "Historical Events",
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
          () => _timeController.showHistoryLoading.value
              ? _buildLoadingIndicator()
              : _buildHistoryContent(),
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
            "Loading Historical Events...",
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

  Widget _buildHistoryContent() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Selected Date: ",
                style: TextStyle(
                  color: const Color(0xFF8E8E93),
                  fontFamily: "SF Pro Text",
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFD1D1D6),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: primaryBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(selectedDate),
                        style: TextStyle(
                          color: darkBlue,
                          fontFamily: "SF Pro Text",
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _timeController.getHistory.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              thickness: 0.5,
              color: Color(0xFFD1D1D6),
            ),
            itemBuilder: (context, index) {
              final event = _timeController.getHistory[index];
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 6, right: 12),
                          decoration: BoxDecoration(
                            color: primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: TextStyle(
                                  color: darkBlue,
                                  fontFamily: "SF Pro Text",
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                event.subTitle,
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
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
