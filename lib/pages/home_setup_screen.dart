// ignore_for_file: unused_field

import 'package:usa_gas_price/controller/airlines_controller.dart';
import 'package:usa_gas_price/controller/eu_fule_controller.dart';
import 'package:usa_gas_price/controller/gas_controller.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';
import 'package:usa_gas_price/controller/stock_controller.dart';
import 'package:usa_gas_price/controller/time_controller.dart';
import 'package:usa_gas_price/controller/update_controller.dart';
import 'package:usa_gas_price/controller/weather_controller.dart';
import 'package:usa_gas_price/flight/home_setup_screen.dart';
import 'package:usa_gas_price/pages/europe/eu_service_screen.dart';
import 'package:usa_gas_price/pages/market/market_page.dart';
import 'package:usa_gas_price/pages/service_page.dart';
import 'package:usa_gas_price/pages/desial_price.dart';
import 'package:usa_gas_price/pages/ev_price.dart';
import 'package:usa_gas_price/pages/gas_price.dart';
import 'package:usa_gas_price/pages/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usa_gas_price/pages/weather_screen.dart';

class HomeSetupScreen extends StatefulWidget {
  const HomeSetupScreen({super.key});

  @override
  _HomeSetupScreenState createState() => _HomeSetupScreenState();
}

class _HomeSetupScreenState extends State<HomeSetupScreen> {
  final GasController _gasController = Get.put(GasController());
  final TimeController _timeController = Get.put(TimeController());
  final UpdateController _updateController = Get.put(UpdateController());
  final EUFuelController _euFuelController = Get.put(EUFuelController());
  final StockController stockConroller = Get.put(StockController());
  final WeatherController weatherController = Get.put(WeatherController());
  final AirlinesController _airlinesController = Get.put(AirlinesController());
  final Color primaryBlue = const Color(0xFF007AFF); // iOS system blue
  final Color darkBlue = const Color(0xFF0A4B9A); // Darker blue variant

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Get.find<GoogleAdsController>().showAppOpenAd();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F7), // iOS style background
        extendBody: true,
        bottomNavigationBar: _buildIOSNavBar(),
        body: Container(
          color: const Color(0xFFF2F2F7),
          child: Column(children: [
            _selectedIndex == 0
                ? const Expanded(child: GasMapHitTestApp())
                : _selectedIndex == 1
                    ? const Expanded(child: GasPrice())
                    : _selectedIndex == 2
                        ? const Expanded(child: FlightHomeSetupScreen())
                        : _selectedIndex == 3
                            ? const Expanded(child: DesialPrice())
                            : _selectedIndex == 4
                                ? const Expanded(child: EvPrice())
                                : _selectedIndex == 5
                                    ? const Expanded(
                                        child: MarketPage())
                                    : _selectedIndex == 6
                                        ? const Expanded(
                                            child: EUServiceScreen())
                                        : const Expanded(child: ServicePage())
          ]),
        ),
      ),
    );
  }

  Widget _buildIOSNavBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.red,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              selectedItemColor: primaryBlue,
              unselectedItemColor: const Color(0xFF8E8E93), // iOS gray
              selectedLabelStyle: const TextStyle(
                fontFamily: "SF Pro Text",
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: "SF Pro Text",
                fontSize: 12.0,
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              elevation: 0,
              currentIndex: _selectedIndex,
              onTap: (index) {
                if (mounted) {
                  setState(() {
                    _selectedIndex = index;
                  });
                }
              },
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: [
                _buildNavItem(
                  icon: Icons.map_outlined,
                  activeIcon: Icons.map,
                  label: 'Map',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.local_gas_station_outlined,
                  activeIcon: Icons.local_gas_station,
                  label: 'Gas',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.flight,
                  activeIcon: Icons.flight,
                  label: 'Flights',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.oil_barrel_outlined,
                  activeIcon: Icons.oil_barrel,
                  label: 'Diesel',
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.electric_bolt_outlined,
                  activeIcon: Icons.electric_bolt,
                  label: 'EV',
                  index: 4,
                ),
                _buildNavItem(
                  icon: Icons.bar_chart_rounded,
                  activeIcon: Icons.bar_chart_rounded,
                  label: 'Stock',
                  index: 5,
                ),
                _buildNavItem(
                  icon: Icons.directions_car_outlined,
                  activeIcon: Icons.directions_car,
                  label: 'Europe',
                  index: 6,
                ),
                _buildNavItem(
                  icon: Icons.more_horiz,
                  activeIcon: Icons.more_horiz,
                  label: 'More',
                  index: 8,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Icon(icon, size: 24),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Icon(activeIcon, size: 24),
      ),
      label: label,
    );
  }
}
