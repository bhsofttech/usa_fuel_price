import 'package:flutter/material.dart';

import 'package:usa_gas_price/flight/country_selection_screen.dart';
import 'package:usa_gas_price/flight/flight_search_screen.dart';
import 'package:usa_gas_price/flight/live_map_screen.dart';


class FlightHomeSetupScreen extends StatefulWidget {
  const FlightHomeSetupScreen({super.key});

  @override
  State<FlightHomeSetupScreen> createState() => _FlightHomeSetupScreenState();
}

class _FlightHomeSetupScreenState extends State<FlightHomeSetupScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const LiveFlightMap(),
    const FlightSearchScreen(),
    const CountrySelectionScreen(),
  ];

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: const Color(0xFF2563EB),
            unselectedItemColor: const Color(0xFF94A3B8),
            selectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.map_rounded, size: 25),
                activeIcon: Icon(Icons.map_rounded, size: 25),
                label: 'Live Map',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded, size: 25),
                activeIcon: Icon(Icons.search_rounded, size: 25),
                label: 'Flight Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.public_rounded, size: 25),
                activeIcon: Icon(Icons.public_rounded, size: 25),
                label: 'Countries',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
