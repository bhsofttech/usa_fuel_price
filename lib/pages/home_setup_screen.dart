// ignore_for_file: unused_field

import 'package:usa_gas_price/controller/airlines_controller.dart';
import 'package:usa_gas_price/controller/eu_fule_controller.dart';
import 'package:usa_gas_price/controller/gas_controller.dart';
import 'package:usa_gas_price/controller/stock_controller.dart';
import 'package:usa_gas_price/controller/time_controller.dart';
import 'package:usa_gas_price/controller/update_controller.dart';
import 'package:usa_gas_price/controller/weather_controller.dart';
import 'package:usa_gas_price/flight/country_selection_screen.dart';
import 'package:usa_gas_price/pages/europe/eu_service_screen.dart';
import 'package:usa_gas_price/pages/market/market_page.dart';
import 'package:usa_gas_price/pages/desial_price.dart';
import 'package:usa_gas_price/pages/ev_price.dart';
import 'package:usa_gas_price/pages/gas_price.dart';
import 'package:usa_gas_price/pages/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:usa_gas_price/controller/reward_ads_controller.dart';

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
  final RewardAdsController _rewardAdsController =
      Get.put(RewardAdsController());

  final Color primaryBlue = const Color(0xFF007AFF); // iOS system blue
  final Color darkBlue = const Color(0xFF0A4B9A); // Darker blue variant

  int _selectedIndex = 0;

  // Unlock status for tabs
  bool _isTab1Unlocked = false; // Index 1 (Gas)
  bool _isTab3Unlocked = false; // Index 3 (Diesel)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadUnlockStatus();
    });
  }

  Future<void> _loadUnlockStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;

    // Check Tab 1 (Gas)
    final tab1UnlockTime = prefs.getInt('tab1_unlock_time') ?? 0;
    final tab1Unlocked = now < tab1UnlockTime;

    // Check Tab 3 (Diesel)
    final tab3UnlockTime = prefs.getInt('tab3_unlock_time') ?? 0;
    final tab3Unlocked = now < tab3UnlockTime;

    if (mounted) {
      setState(() {
        _isTab1Unlocked = tab1Unlocked;
        _isTab3Unlocked = tab3Unlocked;
      });
    }
  }

  Future<void> _unlockTab(int tabIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final unlockUntil = now + (12 * 60 * 60 * 1000); // 12 hours in milliseconds

    if (tabIndex == 1) {
      await prefs.setInt('tab1_unlock_time', unlockUntil);
      if (mounted) {
        setState(() {
          _isTab1Unlocked = true;
        });
      }
      _scheduleAutoLock(tabIndex, const Duration(hours: 12));
    } else if (tabIndex == 3) {
      await prefs.setInt('tab3_unlock_time', unlockUntil);
      if (mounted) {
        setState(() {
          _isTab3Unlocked = true;
        });
      }
      _scheduleAutoLock(tabIndex, const Duration(hours: 12));
    }
  }

  void _scheduleAutoLock(int tabIndex, Duration duration) {
    Future.delayed(duration, () {
      if (mounted) {
        setState(() {
          if (tabIndex == 1) {
            _isTab1Unlocked = false;
          } else if (tabIndex == 3) {
            _isTab3Unlocked = false;
          }
        });
      }
    });
  }

  void _handleTabTap(int index) async {
    // Check internet connection first
    final hasInternet = await _checkInternetConnection();

    if (!hasInternet) {
      _showNoInternetToast();
      return;
    }

    // Check if tabs 1 or 3 are locked
    if ((index == 1 && !_isTab1Unlocked) || (index == 3 && !_isTab3Unlocked)) {
      _showUnlockDialog(index);
    } else {
      if (mounted) {
        setState(() {
          _selectedIndex = index;
        });
      }
    }
  }

  Future<bool> _checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void _showNoInternetToast() {
    Get.snackbar(
      'No Internet Connection',
      'Please check your internet connection and try again',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.wifi_off, color: Colors.white),
    );
  }

  void _showUnlockDialog(int tabIndex) {
    final tabName = tabIndex == 1 ? 'Gas' : 'Diesel';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: Row(
          children: [
            Icon(Icons.lock, color: primaryBlue, size: 24),
            const SizedBox(width: 8),
            Text(
              'Unlock $tabName',
              style: const TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Watch a short ad to unlock the $tabName feature',
          style: const TextStyle(
            fontFamily: 'SF Pro Text',
            fontSize: 13,
            color: Color(0xFF8E8E93),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 17,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showLoadingAndAd(tabIndex);
            },
            child: Text(
              'Watch Ad',
              style: TextStyle(
                fontFamily: 'SF Pro Text',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoadingAndAd(int tabIndex) {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
              ),
              const SizedBox(height: 16),
              const Text(
                'Loading ad...',
                style: TextStyle(
                  fontFamily: 'SF Pro Text',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Load and show ad
    _rewardAdsController.loadAndShowRewardedAd(
      onAdLoaded: () {
        // Dismiss loading dialog
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      onRewardEarned: () async {
        await _unlockTab(tabIndex);
        if (mounted) {
          setState(() {
            _selectedIndex = tabIndex;
          });
        }
        Get.snackbar(
          'Unlocked!',
          'You can now access ${tabIndex == 1 ? 'Gas' : 'Diesel'} feature for 12 hours',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: primaryBlue.withOpacity(0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        );
      },
      onAdSkipped: () {
        // Dismiss loading dialog if still showing
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        Get.snackbar(
          'Ad Not Completed',
          'Please watch the full ad to unlock this feature',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFF9500).withOpacity(0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          icon: const Icon(Icons.info_outline, color: Colors.white),
        );
      },
      onAdFailedToLoad: () {
        // Dismiss loading dialog
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        Get.snackbar(
          'Ad Unavailable',
          'Unable to load ad. Please try again later.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        );
      },
    );
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
                        ? const Expanded(child: CountrySelectionScreen())
                        : _selectedIndex == 3
                            ? const Expanded(child: DesialPrice())
                            : _selectedIndex == 4
                                ? const Expanded(child: EvPrice())
                                : _selectedIndex == 5
                                    ? const Expanded(child: MarketPage())
                                    : const Expanded(child: EUServiceScreen())
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
              onTap: _handleTabTap,
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
                  label: 'Airpot',
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
                // _buildNavItem(
                //   icon: Icons.more_horiz,
                //   activeIcon: Icons.more_horiz,
                //   label: 'More',
                //   index: 8,
                // ),
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
    final isLocked =
        (index == 1 && !_isTab1Unlocked) || (index == 3 && !_isTab3Unlocked);

    return BottomNavigationBarItem(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Icon(icon, size: 24),
          ),
          if (isLocked)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9500),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 8,
                ),
              ),
            ),
        ],
      ),
      activeIcon: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Icon(activeIcon, size: 24),
          ),
          if (isLocked)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9500),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 8,
                ),
              ),
            ),
        ],
      ),
      label: label,
    );
  }
}


// // ignore_for_file: unused_field

// import 'package:usa_gas_price/controller/airlines_controller.dart';
// import 'package:usa_gas_price/controller/eu_fule_controller.dart';
// import 'package:usa_gas_price/controller/gas_controller.dart';
// import 'package:usa_gas_price/controller/google_ads_controller.dart';
// import 'package:usa_gas_price/controller/stock_controller.dart';
// import 'package:usa_gas_price/controller/time_controller.dart';
// import 'package:usa_gas_price/controller/update_controller.dart';
// import 'package:usa_gas_price/controller/weather_controller.dart';
// import 'package:usa_gas_price/flight/home_setup_screen.dart';
// import 'package:usa_gas_price/pages/europe/eu_service_screen.dart';
// import 'package:usa_gas_price/pages/market/market_page.dart';
// import 'package:usa_gas_price/pages/service_page.dart';
// import 'package:usa_gas_price/pages/desial_price.dart';
// import 'package:usa_gas_price/pages/ev_price.dart';
// import 'package:usa_gas_price/pages/gas_price.dart';
// import 'package:usa_gas_price/pages/map_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:usa_gas_price/pages/weather_screen.dart';

// class HomeSetupScreen extends StatefulWidget {
//   const HomeSetupScreen({super.key});

//   @override
//   _HomeSetupScreenState createState() => _HomeSetupScreenState();
// }

// class _HomeSetupScreenState extends State<HomeSetupScreen> {
//   final GasController _gasController = Get.put(GasController());
//   final TimeController _timeController = Get.put(TimeController());
//   final UpdateController _updateController = Get.put(UpdateController());
//   final EUFuelController _euFuelController = Get.put(EUFuelController());
//   final StockController stockConroller = Get.put(StockController());
//   final WeatherController weatherController = Get.put(WeatherController());
//   final AirlinesController _airlinesController = Get.put(AirlinesController());
//   final Color primaryBlue = const Color(0xFF007AFF); // iOS system blue
//   final Color darkBlue = const Color(0xFF0A4B9A); // Darker blue variant

//   int _selectedIndex = 0;

//   @override
//   void initState() {
//     super.initState();
 
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       top: false,
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF2F2F7), // iOS style background
//         extendBody: true,
//         bottomNavigationBar: _buildIOSNavBar(),
//         body: Container(
//           color: const Color(0xFFF2F2F7),
//           child: Column(children: [
//             _selectedIndex == 0
//                 ? const Expanded(child: GasMapHitTestApp())
//                 : _selectedIndex == 1
//                     ? const Expanded(child: GasPrice())
//                     : _selectedIndex == 2
//                         ? const Expanded(child: FlightHomeSetupScreen())
//                         : _selectedIndex == 3
//                             ? const Expanded(child: DesialPrice())
//                             : _selectedIndex == 4
//                                 ? const Expanded(child: EvPrice())
//                                 : _selectedIndex == 5
//                                     ? const Expanded(
//                                         child: MarketPage())
//                                     : _selectedIndex == 6
//                                         ? const Expanded(
//                                             child: EUServiceScreen())
//                                         : const Expanded(child: ServicePage())
//           ]),
//         ),
//       ),
//     );
//   }

//   Widget _buildIOSNavBar() {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             color: Colors.red,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1),
//                 blurRadius: 10,
//                 spreadRadius: 2,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(20),
//             child: BottomNavigationBar(
//               backgroundColor: Colors.white,
//               selectedItemColor: primaryBlue,
//               unselectedItemColor: const Color(0xFF8E8E93), // iOS gray
//               selectedLabelStyle: const TextStyle(
//                 fontFamily: "SF Pro Text",
//                 fontSize: 12.0,
//                 fontWeight: FontWeight.w500,
//                 height: 1.5,
//               ),
//               unselectedLabelStyle: const TextStyle(
//                 fontFamily: "SF Pro Text",
//                 fontSize: 12.0,
//                 fontWeight: FontWeight.w400,
//                 height: 1.5,
//               ),
//               elevation: 0,
//               currentIndex: _selectedIndex,
//               onTap: (index) {
//                 if (mounted) {
//                   setState(() {
//                     _selectedIndex = index;
//                   });
//                 }
//               },
//               type: BottomNavigationBarType.fixed,
//               showSelectedLabels: true,
//               showUnselectedLabels: true,
//               items: [
//                 _buildNavItem(
//                   icon: Icons.map_outlined,
//                   activeIcon: Icons.map,
//                   label: 'Map',
//                   index: 0,
//                 ),
//                 _buildNavItem(
//                   icon: Icons.local_gas_station_outlined,
//                   activeIcon: Icons.local_gas_station,
//                   label: 'Gas',
//                   index: 1,
//                 ),
//                 _buildNavItem(
//                   icon: Icons.flight,
//                   activeIcon: Icons.flight,
//                   label: 'Flights',
//                   index: 2,
//                 ),
//                 _buildNavItem(
//                   icon: Icons.oil_barrel_outlined,
//                   activeIcon: Icons.oil_barrel,
//                   label: 'Diesel',
//                   index: 3,
//                 ),
//                 _buildNavItem(
//                   icon: Icons.electric_bolt_outlined,
//                   activeIcon: Icons.electric_bolt,
//                   label: 'EV',
//                   index: 4,
//                 ),
//                 _buildNavItem(
//                   icon: Icons.bar_chart_rounded,
//                   activeIcon: Icons.bar_chart_rounded,
//                   label: 'Stock',
//                   index: 5,
//                 ),
//                 _buildNavItem(
//                   icon: Icons.directions_car_outlined,
//                   activeIcon: Icons.directions_car,
//                   label: 'Europe',
//                   index: 6,
//                 ),
//                 _buildNavItem(
//                   icon: Icons.more_horiz,
//                   activeIcon: Icons.more_horiz,
//                   label: 'More',
//                   index: 8,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   BottomNavigationBarItem _buildNavItem({
//     required IconData icon,
//     required IconData activeIcon,
//     required String label,
//     required int index,
//   }) {
//     return BottomNavigationBarItem(
//       icon: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 2),
//         child: Icon(icon, size: 24),
//       ),
//       activeIcon: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 2),
//         child: Icon(activeIcon, size: 24),
//       ),
//       label: label,
//     );
//   }
// }
