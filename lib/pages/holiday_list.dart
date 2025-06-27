import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:usa_gas_price/controller/time_controller.dart';
import 'package:usa_gas_price/model/country_info.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';

class HoliDayPage extends StatefulWidget {
  final CountryInfo countryInfo;
  const HoliDayPage({super.key, required this.countryInfo});

  @override
  State<HoliDayPage> createState() => _HoliDayPageState();
}

class _HoliDayPageState extends State<HoliDayPage> {
  final TimeController _timeController = Get.find();
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color darkBlue = const Color(0xFF0A4B9A);

  @override
  void initState() {
    super.initState();
    callApi();
    Get.find<GoogleAdsController>().showAds();
    analytics.logScreenView(screenName: "Holidays");
  }

  Future<void> callApi() async {
    await _timeController.fetchHoliDay(
      link: widget.countryInfo.link,
    );
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
          "${widget.countryInfo.country} Holidays",
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
          () => _timeController.showHolyDayLoading.value
              ? _buildLoadingIndicator()
              : _buildHolidayList(),
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
            "Loading Holidays...",
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

  Widget _buildHolidayList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _timeController.getHoliDays.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        thickness: 0.5,
        color: Color(0xFFD1D1D6),
      ),
      itemBuilder: (context, index) {
        final holiday = _timeController.getHoliDays[index];
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getHolidayColor(holiday.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getHolidayIcon(holiday.type),
                      size: 20,
                      color: _getHolidayColor(holiday.type),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      holiday.name,
                      style: TextStyle(
                        color: darkBlue,
                        fontFamily: "SF Pro Text",
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 52),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: const Color(0xFF8E8E93),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${holiday.day} • ${holiday.date}",
                          style: TextStyle(
                            color: const Color(0xFF8E8E93),
                            fontFamily: "SF Pro Text",
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (holiday.type.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.label,
                            size: 14,
                            color: const Color(0xFF8E8E93),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            holiday.type,
                            style: TextStyle(
                              color: const Color(0xFF8E8E93),
                              fontFamily: "SF Pro Text",
                              fontSize: 14.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    if (holiday.comment.isNotEmpty) const SizedBox(height: 4),
                    if (holiday.comment.isNotEmpty)
                      Text(
                        holiday.comment,
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
        );
      },
    );
  }

  Color _getHolidayColor(String type) {
    if (type.toLowerCase().contains('public')) {
      return const Color(0xFF34C759); // Green for public holidays
    } else if (type.toLowerCase().contains('observance')) {
      return const Color(0xFF007AFF); // Blue for observances
    } else if (type.toLowerCase().contains('season')) {
      return const Color(0xFFFF9500); // Orange for seasons
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