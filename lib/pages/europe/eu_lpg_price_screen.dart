import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:usa_gas_price/controller/eu_fule_controller.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';
import 'package:usa_gas_price/widgets/data_widget.dart';


class EuLpgPriceScreen extends StatefulWidget {
  const EuLpgPriceScreen({super.key});

  @override
  State<EuLpgPriceScreen> createState() => _EuLpgPriceScreenState();
}

class _EuLpgPriceScreenState extends State<EuLpgPriceScreen>
    with TickerProviderStateMixin {
  final EUFuelController _fuelController = Get.find();

  // Color palette aligned with eu_gasoline_price.dart
  final Color backgroundColor = const Color(0xFFF8F8FA); // Very light gray
  final Color textColor = const Color(0xFF333333); // Dark gray for text
  final Color primaryColor = const Color(0xFFF06292); // Soft pink
  final Color selectedColor = const Color(0xFFF8BBD0); // Soft pink
  final Color cardColor = Colors.white;
  final Color accentOrange = const Color(0xFFFF9800); // Orange for consistency
  final Color accentCyan = const Color(0xFF26C6DA); // Cyan for header

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Fade animation for content
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    // Scale animation for tap feedback
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation for loading
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutSine,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      callApi();
    });
  }

  Future<void> callApi() async {
    Get.find<GoogleAdsController>().showAds();
    await _fuelController.fetchFuelPrice(endPoint: "");
    _animationController.forward();
  }

  void debounceApiCall() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), callApi);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Get.back(),
        ),
        backgroundColor: cardColor,
        elevation: 0.5,
        title: Text(
          'Europe LPG Prices',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: cardColor,
            border: Border(
              bottom: BorderSide(
                color: textColor.withOpacity(0.2),
                width: 0.5,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildHeaderStats(),
            const SizedBox(height: 8),
            Obx(
              () => _fuelController.showFuelLoading.value
                  ? _buildLoadingState()
                  : _buildLPGPriceContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: cardColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: SpinKitThreeBounce(
              color: primaryColor,
              size: 24.0,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Fetching LPG Prices",
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Loading country-wise prices...",
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 12,
              color: textColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLPGPriceContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildLPGPriceList(),
    );
  }

  Widget _buildHeaderStats() {
    final highestPrice = _fuelController.getFuelInfo.isNotEmpty
        ? _fuelController.getFuelInfo
            .reduce((a, b) => double.parse(a.lpg) > double.parse(b.lpg) ? a : b)
        : null;

    return Container(
      color: cardColor,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            Icons.propane_tank,
            color: accentCyan,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "LPG Fuel Prices",
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                const DateTimeWidget(),
                const SizedBox(height: 4),
                Text(
                  highestPrice != null
                      ? "Highest: ${highestPrice.country} (£${highestPrice.lpg})"
                      : "${_fuelController.getFuelInfo.length} countries available",
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 12,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLPGPriceList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _fuelController.getFuelInfo.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: textColor.withOpacity(0.1),
        indent: 16,
        endIndent: 16,
      ),
      itemBuilder: (context, index) {
        return _buildLPGPriceCard(index);
      },
    );
  }

  Widget _buildLPGPriceCard(int index) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          color: cardColor,
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Icon(
              Icons.propane_tank,
              color: primaryColor,
              size: 20,
            ),
            title: Text(
              _fuelController.getFuelInfo[index].country,
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            subtitle: Text(
              "LPG Rate",
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 12,
                color: textColor.withOpacity(0.6),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selectedColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "£${_fuelController.getFuelInfo[index].lpg}",
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: accentOrange,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}