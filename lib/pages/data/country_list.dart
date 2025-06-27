import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:usa_gas_price/main.dart';
import 'package:usa_gas_price/widgets/select_state_widget.dart';
import '../../controller/google_ads_controller.dart';
import 'emport_export_category_list.dart';

class CountryListScreen extends StatefulWidget {
  const CountryListScreen({super.key});

  @override
  State<CountryListScreen> createState() => _CountryListScreenState();
}

class _CountryListScreenState extends State<CountryListScreen> {
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
          "Select Country".toUpperCase(),
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          itemCount: CountryList.values.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12.0),
          itemBuilder: (context, index) {
            final countryName =
                CountryList.values[index].name.replaceAll("_", " ");
            return InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                bool isInternet = await checkConnection();
                if (isInternet) {
                  Get.to(
                    () => ImportexportCategoryList(countryName: countryName),
                    transition: Transition.cupertino,
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: "No internet connection available.",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP,
                    timeInSecForIosWeb: 3,
                    backgroundColor: Colors.redAccent.withOpacity(0.9),
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              },
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
                        countryName,
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
