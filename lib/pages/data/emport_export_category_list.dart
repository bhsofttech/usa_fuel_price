import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';
import 'exp_details_screen.dart';

class ImportexportCategoryList extends StatefulWidget {
  final String countryName;
  const ImportexportCategoryList({super.key, required this.countryName});

  @override
  State<ImportexportCategoryList> createState() =>
      _ImportexportCategoryListState();
}

class _ImportexportCategoryListState extends State<ImportexportCategoryList> {
  final GoogleAdsController _googleAdsController = Get.find();
  final Color primaryBlue = const Color(0xFF007AFF); // iOS system blue
  final Color darkBlue = const Color(0xFF0A4B9A); // Darker blue variant

  @override
  void initState() {
    super.initState();
    _googleAdsController.showAds();
  }

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
          widget.countryName.replaceAll("_", " ").toUpperCase(),
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
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          itemCount: 4, // Number of categories
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final categories = [
              {
                "title": "Exports By Country",
                "endPoint":
                    "https://tradingeconomics.com/${widget.countryName.toLowerCase().replaceAll("_", "-")}/exports-by-country",
              },
              {
                "title": "Exports By Category",
                "endPoint":
                    "https://tradingeconomics.com/${widget.countryName.toLowerCase().replaceAll("_", "-")}/exports-by-category",
              },
              {
                "title": "Imports By Country",
                "endPoint":
                    "https://tradingeconomics.com/${widget.countryName.toLowerCase().replaceAll("_", "-")}/imports-by-country",
              },
              {
                "title": "Imports By Category",
                "endPoint":
                    "https://tradingeconomics.com/${widget.countryName.toLowerCase().replaceAll("_", "-")}/imports-by-category",
              },
            ];

            final item = categories[index];
            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Get.to(
                () => ExpDetailsScreen(
                  endPoint: item["endPoint"]!,
                  title: widget.countryName,
                ),
                transition: Transition.cupertino,
              ),
              child: Container(
                padding: const EdgeInsets.all(16.0),
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