import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:usa_gas_price/controller/time_controller.dart';
import 'package:usa_gas_price/pages/holiday_list.dart';

class CountryPage extends StatefulWidget {
  const CountryPage({super.key});

  @override
  State<CountryPage> createState() => _CountryPageState();
}

class _CountryPageState extends State<CountryPage> {
  final TimeController _timeController = Get.find();
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color darkBlue = const Color(0xFF0A4B9A);

  @override
  void initState() {
    super.initState();
    callApi();
  }

  Future<void> callApi() async {
    await _timeController.fetchCountry();
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
          "Countries",
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
          () => _timeController.showCountryLoading.value
              ? _buildLoadingIndicator()
              : _buildCountryList(),
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
            "Loading Countries...",
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

  Widget _buildCountryList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _timeController.getCountrys.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        thickness: 0.5,
        color: Color(0xFFD1D1D6),
      ),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Get.to(() => HoliDayPage(
                countryInfo: _timeController.getCountrys[index]));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(0),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.flag,
                    size: 18,
                    color: primaryBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _timeController.getCountrys[index].country,
                    style: TextStyle(
                      color: darkBlue,
                      fontFamily: "SF Pro Text",
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: const Color(0xFF8E8E93),
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}