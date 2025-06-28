import 'dart:async';
import 'package:usa_gas_price/controller/gas_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:usa_gas_price/pages/gas_state_wise_price.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';

class GasPrice extends StatefulWidget {
  const GasPrice({super.key});

  @override
  State<GasPrice> createState() => _GasPriceState();
}

class _GasPriceState extends State<GasPrice> {
  final GasController _gasController = Get.find();
  final GoogleAdsController _googleAdsController = Get.find();

  // Modern iOS color palette
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color darkBlue = const Color(0xFF0A4B9A);
  final Color lightBlue = const Color(0xFF4DA6FF);
  final Color backgroundGray = const Color(0xFFF2F2F7);
  final Color cardWhite = const Color(0xFFFFFFFF);
  final Color textPrimary = const Color(0xFF1C1C1E);
  final Color textSecondary = const Color(0xFF8E8E93);
  final Color separatorGray = const Color(0xFFD1D1D6);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callApi();
    });
  }

  Future<void> callApi() async {
    _googleAdsController.showLoadads();
    _googleAdsController.isShow.value = false;
    await _gasController.fetchGasPrice(endPoint: "/state-gas-price-averages/");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        leadingWidth: 50,
        backgroundColor: cardWhite,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "USA State Gas Price".toUpperCase(),
          style: TextStyle(
            color: primaryBlue,
            fontFamily: "SF Pro Display",
            fontSize: 17.0,
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
        child: Container(
          color: backgroundGray,
          child: Obx(
            () => _gasController.showGasLoading.value
                ? _buildLoadingState()
                : _buildGasPriceList(),
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
          SpinKitFadingCircle(
            color: primaryBlue,
            size: 40.0,
          ),
          const SizedBox(height: 24),
          Text(
            "Loading Gas Prices...",
            style: TextStyle(
              color: textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: "SF Pro Text",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGasPriceList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _gasController.gasInfo.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildGasPriceCard(index);
      },
    );
  }

  Widget _buildGasPriceCard(int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.to(
            () => GasStateWisePrice(
              gasinfo: _gasController.gasInfo[index],
            ),
            transition: Transition.cupertino,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardHeader(index),
                const SizedBox(height: 20),
                _buildPriceContainer(index),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _gasController.gasInfo[index].city,
                style: TextStyle(
                  color: primaryBlue,
                  fontFamily: "SF Pro Display",
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "State Gas Prices",
                style: TextStyle(
                  color: textSecondary,
                  fontFamily: "SF Pro Text",
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryBlue.withOpacity(0.1),
                lightBlue.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.chevron_right_rounded,
            color: primaryBlue,
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceContainer(int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundGray,
            backgroundGray.withOpacity(0.8),
          ],
        ),
        border: Border.all(
          color: separatorGray.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildEnhancedPrice(
            title: "Regular",
            price: _gasController.gasInfo[index].regular,
            color: const Color(0xFF34C759), // iOS green
            icon: Icons.local_gas_station_outlined,
          ),
          Container(
            width: 1,
            height: 40,
            color: separatorGray.withOpacity(0.5),
          ),
          _buildEnhancedPrice(
            title: "MidGrade",
            price: _gasController.gasInfo[index].midGrade,
            color: const Color(0xFFFF9500), // iOS orange
            icon: Icons.local_gas_station,
          ),
          Container(
            width: 1,
            height: 40,
            color: separatorGray.withOpacity(0.5),
          ),
          _buildEnhancedPrice(
            title: "Premium",
            price: _gasController.gasInfo[index].premium,
            color: const Color(0xFFFF3B30), // iOS red
            icon: Icons.local_gas_station_sharp,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedPrice({
    required String title,
    required String price,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: textSecondary,
              fontFamily: "SF Pro Text",
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: TextStyle(
              color: color,
              fontFamily: "SF Pro Display",
              fontSize: 17.0,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// Legacy buildPrice function preserved for compatibility
Widget buildPrice({
  required String title,
  required String price,
  required Color color,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Color(0xFF8E8E93),
          fontFamily: "SF Pro Text",
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        price,
        style: TextStyle(
          color: color,
          fontFamily: "SF Pro Text",
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
