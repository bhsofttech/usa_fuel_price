import 'dart:async';
import 'package:intl/intl.dart';
import 'package:usa_gas_price/controller/gas_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:usa_gas_price/model/gas_info.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';

class GasStateWisePrice extends StatefulWidget {
  final Gasinfo gasinfo;
  const GasStateWisePrice({super.key, required this.gasinfo});

  @override
  State<GasStateWisePrice> createState() => _GasStateWiseGasPriceState();
}

class _GasStateWiseGasPriceState extends State<GasStateWisePrice> {
  final GasController _gasController = Get.find();

  // Modern iOS color palette
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color darkBlue = const Color(0xFF0A4B9A);
  final Color lightBlue = const Color(0xFF4DA6FF);
  final Color backgroundGray = const Color(0xFFF2F2F7);
  final Color cardWhite = const Color(0xFFFFFFFF);
  final Color textPrimary = const Color(0xFF1C1C1E);
  final Color textSecondary = const Color(0xFF8E8E93);
  final Color separatorGray = const Color(0xFFD1D1D6);
  final Color successGreen = const Color(0xFF34C759);
  final Color warningOrange = const Color(0xFFFF9500);
  final Color errorRed = const Color(0xFFFF3B30);
  final Color purpleAccent = const Color(0xFFAF52DE);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callApi();
    });
  }

  Future<void> callApi() async {
    Get.find<GoogleAdsController>().showAds();
    await _gasController.fetchGasDetailsPrice(endPoint: widget.gasinfo.link);
  }

  @override
  void dispose() {
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
            () => _gasController.showGasDetailLoading.value
                ? _buildLoadingState()
                : _buildGasDetailsList(),
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
      title: Text(
        "${widget.gasinfo.city} Gas Price".toUpperCase(),
        style: TextStyle(
          color: primaryBlue,
          fontFamily: "SF Pro Display",
          fontSize:
              16.0, // Reduced font size for consistency with gas_price.dart
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
                "Fetching Details",
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 14, // Smaller font for less clutter
                  fontWeight: FontWeight.w600,
                  fontFamily: "SF Pro Text",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGasDetailsList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 16), // Balanced padding
      itemCount: _gasController.getGasDetails.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: 10), // Reduced separator height
      itemBuilder: (context, index) {
        final isFirstItem = index == 0;
        return _buildGasDetailsCard(index, isFirstItem);
      },
    );
  }

  Widget _buildGasDetailsCard(int index, bool isFirstItem) {
    return Container(
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(12), // Smaller radius for modern look
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
        padding: const EdgeInsets.all(16), // Reduced padding for compact card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(index, isFirstItem),
            const SizedBox(height: 16), // Reduced spacing
            _buildPriceGrid(index),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(int index, bool isFirstItem) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isFirstItem) ...[
                    Container(
                      padding: const EdgeInsets.all(6), // Smaller padding
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryBlue, lightBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 14, // Smaller icon
                      ),
                    ),
                    const SizedBox(width: 6), // Tighter spacing
                  ],
                  Expanded(
                    child: Text(
                      _gasController.getGasDetails[index].city,
                      style: TextStyle(
                        color: textPrimary,
                        fontFamily: "SF Pro Display",
                        fontSize:
                            isFirstItem ? 18.0 : 16.0, // Reduced font sizes
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              if (isFirstItem) ...[
                const SizedBox(height: 4), // Tighter spacing
                Text(
                  "Current Gas Prices",
                  style: TextStyle(
                    color: textSecondary,
                    fontFamily: "SF Pro Text",
                    fontSize: 13.0, // Smaller font
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (isFirstItem)
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5), // Smaller padding
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  successGreen.withOpacity(0.1),
                  successGreen.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10), // Smaller radius
              border: Border.all(
                color: successGreen.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule,
                  color: successGreen,
                  size: 12, // Smaller icon
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, yyyy')
                      .format(DateTime.now().toUtc().toLocal()),
                  style: TextStyle(
                    color: successGreen,
                    fontSize: 11, // Smaller font
                    fontWeight: FontWeight.w600,
                    fontFamily: "SF Pro Text",
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFeaturedPrice(int index) {
    return Container(
      padding: const EdgeInsets.all(16), // Reduced padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue.withOpacity(0.08),
            lightBlue.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(10), // Smaller radius
        border: Border.all(
          color: primaryBlue.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6), // Smaller padding
                decoration: BoxDecoration(
                  color: successGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8), // Smaller radius
                ),
                child: Icon(
                  Icons.local_gas_station_outlined,
                  color: successGreen,
                  size: 16, // Smaller icon
                ),
              ),
              const SizedBox(width: 8), // Reduced spacing
              Text(
                "Regular Gas",
                style: TextStyle(
                  color: textSecondary,
                  fontFamily: "SF Pro Text",
                  fontSize: 14.0, // Smaller font
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Reduced spacing
          Text(
            _gasController.getGasDetails[index].regular,
            style: TextStyle(
              color: primaryBlue,
              fontFamily: "SF Pro Display",
              fontSize: 28, // Reduced font size for balance
              fontWeight: FontWeight.w700,
              height: 1.1,
              letterSpacing: -0.5, // Adjusted for better readability
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceGrid(int index) {
    return Container(
      padding: const EdgeInsets.all(12), // Reduced padding
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), // Smaller radius
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundGray,
            backgroundGray.withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: separatorGray.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildEnhancedPrice(
                  title: "Regular",
                  price: _gasController.getGasDetails[index].regular,
                  color: successGreen,
                  icon: Icons.local_gas_station_outlined,
                ),
              ),
              Container(
                width: 1,
                height: 36, // Smaller height for divider
                color: separatorGray.withOpacity(0.5),
                margin: const EdgeInsets.symmetric(
                    horizontal: 12), // Reduced margin
              ),
              Expanded(
                child: _buildEnhancedPrice(
                  title: "MidGrade",
                  price: _gasController.getGasDetails[index].midGrade,
                  color: warningOrange,
                  icon: Icons.local_gas_station,
                ),
              ),
              Container(
                width: 1,
                height: 36, // Smaller height for divider
                color: separatorGray.withOpacity(0.5),
                margin: const EdgeInsets.symmetric(
                    horizontal: 12), // Reduced margin
              ),
              Expanded(
                child: _buildEnhancedPrice(
                  title: "Premium",
                  price: _gasController.getGasDetails[index].premium,
                  color: errorRed,
                  icon: Icons.local_gas_station_sharp,
                ),
              ),
            ],
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6), // Smaller padding
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8), // Smaller radius
          ),
          child: Icon(
            icon,
            color: color,
            size: 16, // Smaller icon
          ),
        ),
        const SizedBox(height: 6), // Tighter spacing
        Text(
          title,
          style: TextStyle(
            color: textSecondary,
            fontFamily: "SF Pro Text",
            fontSize: 11.0, // Smaller font
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 4), // Tighter spacing
        Text(
          price,
          style: TextStyle(
            color: color,
            fontFamily: "SF Pro Display",
            fontSize: 15.0, // Smaller font for proportion
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ],
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
          fontSize: 11.0, // Reduced font size for consistency
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        price,
        style: TextStyle(
          color: color,
          fontFamily: "SF Pro Text",
          fontSize: 14.0, // Reduced font size
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
