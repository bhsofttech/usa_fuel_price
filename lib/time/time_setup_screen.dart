import 'package:flutter/material.dart';

import 'converter_screen.dart';
import 'usa_time_screen.dart';
import 'world_clock_screen.dart';

class TimeSetupScreen extends StatefulWidget {
  const TimeSetupScreen({super.key});

  @override
  State<TimeSetupScreen> createState() => _TimeSetupScreenState();
}

class _TimeSetupScreenState extends State<TimeSetupScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const USATimeScreen(),
    const WorldClockScreen(),
    // const ConverterScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.grey.shade200,
        indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.2),
        surfaceTintColor: Colors.transparent,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.access_time_outlined, color: theme.hintColor),
            selectedIcon: Icon(Icons.access_time_filled,
                color: theme.colorScheme.primary),
            label: 'USA',
          ),
          NavigationDestination(
            icon: Icon(Icons.public_outlined, color: theme.hintColor),
            selectedIcon: Icon(Icons.public, color: theme.colorScheme.primary),
            label: 'World',
          ),
          // NavigationDestination(
          //   icon: Icon(Icons.shuffle_outlined, color: theme.hintColor),
          //   selectedIcon: Icon(Icons.shuffle, color: theme.colorScheme.primary),
          //   label: 'Converter',
          // ),
        ],
      ),
    );
  }
}
