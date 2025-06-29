import 'dart:async';
import 'package:usa_gas_price/controller/gas_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:usa_gas_price/widgets/data_widget.dart';

import '../controller/google_ads_controller.dart';

class EvPrice extends StatefulWidget {
  const EvPrice({super.key});

  @override
  State<EvPrice> createState() => _EvPriceState();
}

class _EvPriceState extends State<EvPrice> with TickerProviderStateMixin {
  final GasController _gasController = Get.find();

  // Modern iOS color palette matching desial_price.dart
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color darkBlue = const Color(0xFF0A4B9A);
  final Color lightBlue = const Color(0xFF4DA6FF);
  final Color backgroundGray = const Color(0xFFF2F2F7);
  final Color cardWhite = const Color(0xFFFFFFFF);
  final Color textPrimary = const Color(0xFF1C1C1E);
  final Color textSecondary = const Color(0xFF8E8E93);
  final Color separatorGray = const Color(0xFFD1D1D6);
  final Color electricGreen = const Color(0xFF34C759);
  final Color electricPurple = const Color(0xFFAF52DE);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      callApi();
      Get.find<GoogleAdsController>().showAds();
    });
  }

  Future<void> callApi() async {
    await _gasController.fetchGasPrice(endPoint: "/ev-charging-prices/");
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Container(
          color: backgroundGray,
          child: Obx(
            () => _gasController.showGasLoading.value
                ? _buildLoadingState()
                : _buildEvPriceContent(),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leadingWidth: 50,
      backgroundColor: cardWhite,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
          Text(
            "USA EV Charging Prices".toUpperCase(),
            style: TextStyle(
              color: primaryBlue,
              fontFamily: "SF Pro Display",
              fontSize: 16.0, // Reduced font size for consistency
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              SpinKitFadingCircle(
                color: primaryBlue,
                size: 36.0, // Smaller spinner for balance
              ),
              const SizedBox(height: 12), // Tighter spacing
              Text(
                "Loading EV Charging Prices",
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 14, // Smaller font for less clutter
                  fontWeight: FontWeight.w500,
                  fontFamily: "SF Pro Text",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEvPriceContent() {
    return Column(
      children: [
        _buildHeaderStats(),
        Expanded(
          child: _buildEvPriceList(),
        ),
      ],
    );
  }

  Widget _buildHeaderStats() {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 16), // Balanced margin
      padding: const EdgeInsets.all(16), // Reduced padding
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // Smaller radius
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue.withOpacity(0.1),
            electricPurple.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8), // Smaller padding
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue, electricPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10), // Smaller radius
            ),
            child: const Icon(
              Icons.electric_car,
              color: Colors.white,
              size: 20, // Smaller icon
            ),
          ),
          const SizedBox(width: 12), // Reduced spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "EV Charging Prices",
                  style: TextStyle(
                    color: textPrimary,
                    fontFamily: "SF Pro Display",
                    fontSize: 18.0, // Reduced font size
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4), // Tighter spacing
                const DateTimeWidget(),
                const SizedBox(height: 4), // Tighter spacing
                Text(
                  "${_gasController.gasInfo.length} states available",
                  style: TextStyle(
                    color: textSecondary,
                    fontFamily: "SF Pro Text",
                    fontSize: 13.0, // Smaller font
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvPriceList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 12), // Balanced padding
        itemCount: _gasController.gasInfo.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: 10), // Reduced separator height
        itemBuilder: (context, index) {
          return _buildEvPriceCard(index);
        },
      ),
    );
  }

  Widget _buildEvPriceCard(int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // Smaller radius
        color: cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12, // Reduced blur for sharper shadow
            spreadRadius: 0,
            offset: const Offset(0, 2), // Smaller offset
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16), // Reduced padding
        child: Row(
          children: [
            _buildStateInfo(index),
            const Spacer(),
            _buildPriceSection(index),
          ],
        ),
      ),
    );
  }

  Widget _buildStateInfo(int index) {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6, // Smaller dot
                height: 6, // Smaller dot
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryBlue, electricPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(3), // Smaller radius
                ),
              ),
              const SizedBox(width: 10), // Reduced spacing
              Expanded(
                child: Text(
                  _gasController.gasInfo[index].city,
                  style: TextStyle(
                    color: textPrimary,
                    fontFamily: "SF Pro Display",
                    fontSize: 16.0, // Reduced font size
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4), // Tighter spacing
          Padding(
            padding:
                const EdgeInsets.only(left: 16), // Slightly reduced padding
            child: Text(
              "EV Charging Rate",
              style: TextStyle(
                color: textSecondary,
                fontFamily: "SF Pro Text",
                fontSize: 12.0, // Smaller font
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 10), // Reduced padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue.withOpacity(0.1),
            electricPurple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(10), // Smaller radius
        border: Border.all(
          color: primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _gasController.gasInfo[index].midGrade,
                style: TextStyle(
                  color: primaryBlue,
                  fontFamily: "SF Pro Display",
                  fontSize: 18.0, // Reduced font size
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4), // Tighter spacing
              Text(
                "Cost/kWh",
                style: TextStyle(
                  color: textSecondary,
                  fontFamily: "SF Pro Text",
                  fontSize: 12.0, // Smaller font
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12), // Reduced spacing
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _gasController.gasInfo[index].regular,
                style: TextStyle(
                  color: electricGreen,
                  fontFamily: "SF Pro Display",
                  fontSize: 18.0, // Reduced font size
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4), // Tighter spacing
              Text(
                "Chargers",
                style: TextStyle(
                  color: textSecondary,
                  fontFamily: "SF Pro Text",
                  fontSize: 12.0, // Smaller font
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
