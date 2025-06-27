import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'data_details_screen.dart';

class DataListScreen extends StatefulWidget {
  const DataListScreen({super.key});

  @override
  State<DataListScreen> createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen> {
  final Color primaryBlue = const Color(0xFF007AFF); // iOS system blue
  final Color darkBlue = const Color(0xFF0A4B9A); // Darker blue variant

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS style background
      appBar: AppBar(
        leadingWidth: 50,
        backgroundColor: Colors.white, // iOS style white app bar
        elevation: 0.5, // subtle shadow
        centerTitle: true,
        title: Text(
          "Economic Data".toUpperCase(),
          style: TextStyle(
            color: darkBlue,
            fontFamily: "SF Pro Display",
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
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
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          itemCount

: 21, // Number of data items
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final dataItems = [
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
                "endPoint": "https://tradingeconomics.com/country-list/gdp-growth-rate?continent=world",
              },
              {
                "title": "Employment Rate",
                "endPoint": "https://tradingeconomics.com/country-list/employment-rate",
              },
              {
                "title": "Unemployment Rate",
                "endPoint": "https://tradingeconomics.com/country-list/unemployment-rate?continent=world",
              },
              {
                "title": "Minimum Wages",
                "endPoint": "https://tradingeconomics.com/country-list/minimum-wages",
              },
              {
                "title": "Central Bank Balance Sheet",
                "endPoint": "https://tradingeconomics.com/country-list/central-bank-balance-sheet",
              },
              {
                "title": "Foreign Exchange Reserves",
                "endPoint": "https://tradingeconomics.com/country-list/foreign-exchange-reserves",
              },
              {
                "title": "Crude Oil Production",
                "endPoint": "https://tradingeconomics.com/country-list/crude-oil-production",
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
                "endPoint": "https://tradingeconomics.com/country-list/gdp-per-capita-ppp",
              },
              {
                "title": "Military Expenditure",
                "endPoint": "https://tradingeconomics.com/country-list/military-expenditure",
              },
              {
                "title": "Corporate Tax Rate",
                "endPoint": "https://tradingeconomics.com/country-list/corporate-tax-rate",
              },
              {
                "title": "Personal Income Tax Rate",
                "endPoint": "https://tradingeconomics.com/country-list/personal-income-tax-rate",
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
                "endPoint": "https://tradingeconomics.com/country-list/natural-gas-stocks-capacity",
              },
            ];

            final item = dataItems[index];
            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Get.to(
                () => DataDetailsScreen(
                  title: item["title"]!,
                  endPoint: item["endPoint"]!,
                ),
                transition: Transition.cupertino,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item["title"]!,
                        style: TextStyle(
                          color: darkBlue,
                          fontFamily: "SF Pro Text",
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
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
            );
          },
        ),
      ),
    );
  }
}