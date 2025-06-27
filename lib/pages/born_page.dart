import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:usa_gas_price/controller/time_controller.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';

class BornPage extends StatefulWidget {
  const BornPage({super.key});

  @override
  State<BornPage> createState() => _BornPageState();
}

class _BornPageState extends State<BornPage> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final TimeController _timeController = Get.find();
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color darkBlue = const Color(0xFF0A4B9A);

  @override
  void initState() {
    super.initState();
    Get.find<GoogleAdsController>().showAds();
    callApi();
    analytics.logScreenView(screenName: "Famous People Born Today");
  }

  Future<void> callApi() async {
    await _timeController.fetchBornToday();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS style background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          "Born Today",
          style: TextStyle(
            color: darkBlue,
            fontFamily: "SF Pro Display",
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: darkBlue),
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
      body: 
      SafeArea(
        child: Obx(
          () => _timeController.showTodaysBornLoading.value
              ? _buildLoadingIndicator()
              : _buildBornTodayList(),
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
            "Loading Famous Birthdays...",
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

  Widget _buildBornTodayList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _timeController.getTodaysBorn.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final person = _timeController.getTodaysBorn[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 20,
                      color: primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "${person.name} • ${person.country}",
                      style: TextStyle(
                        color: darkBlue,
                        fontFamily: "SF Pro Text",
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.work,
                      size: 20,
                      color: const Color(0xFF34C759),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      person.type,
                      style: TextStyle(
                        color: const Color(0xFF8E8E93),
                        fontFamily: "SF Pro Text",
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9500).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.cake,
                      size: 20,
                      color: const Color(0xFFFF9500),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    person.date
                        .replaceAll("*", "")
                        .replaceAll("(", "")
                        .replaceAll(")", ""),
                    style: TextStyle(
                      color: const Color(0xFF8E8E93),
                      fontFamily: "SF Pro Text",
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}