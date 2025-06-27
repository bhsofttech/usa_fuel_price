import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:usa_gas_price/controller/time_controller.dart';
import 'package:usa_gas_price/pages/age_cal_pag.dart';
import 'package:usa_gas_price/pages/born_page.dart';
import 'package:usa_gas_price/pages/country_list.dart';
import 'package:usa_gas_price/pages/data/country_list.dart';
import 'package:usa_gas_price/pages/data/data_list.dart';
import 'package:usa_gas_price/pages/history_page.dart';
import 'package:usa_gas_price/pages/time_list_page.dart';
import 'package:usa_gas_price/pages/unit_conveter.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> with TickerProviderStateMixin {
  final TimeController _timeController = Get.find();
  final Color primaryOrange = const Color(0xffF47D4E);
  final Color darkBlue = const Color(0xFF0A4B9A);
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
      curve: Curves.easeOutCubic,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    init();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> init() async {
 
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          leadingWidth: 50,
          backgroundColor: Colors.white.withOpacity(0.95),
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          centerTitle: true,
          title: Text(
            "Services".toUpperCase(),
            style: TextStyle(
              color: darkBlue,
              fontFamily: "SF Pro Display",
              fontSize: 18.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          iconTheme: IconThemeData(color: darkBlue),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              border: const Border(
                bottom: BorderSide(
                  color: Color(0xFFE5E5EA),
                  width: 0.33,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Choose a Service",
                    style: TextStyle(
                      color: darkBlue.withOpacity(0.8),
                      fontFamily: "SF Pro Text",
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuick(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuick() {
    final services = [
      {
        'title': 'All Unit Converter',
        'icon': Icons.swap_horiz_rounded,
        'color': const Color(0xFFFF3B30),
        'gradient': [const Color(0xFFFF6B6B), const Color(0xFFFF3B30)],
        'onTap': () => Get.to(() => const UnitConverterApp()),
      },
      {
        'title': 'Import Export Data',
        'icon': Icons.import_export_rounded,
        'color': const Color(0xFF007AFF),
        'gradient': [const Color(0xFF4A90E2), const Color(0xFF007AFF)],
        'onTap': () => Get.to(() => const CountryListScreen()),
      },
      {
        'title': 'World Economy',
        'icon': Icons.trending_up_rounded,
        'color': const Color(0xFF34C759),
        'gradient': [const Color(0xFF5AC8FA), const Color(0xFF34C759)],
        'onTap': () => Get.to(() => const DataListScreen()),
      },
      {
        'title': 'Famous People Born Today',
        'icon': Icons.people_alt_rounded,
        'color': const Color(0xFFAF52DE),
        'gradient': [const Color(0xFFBF5AF2), const Color(0xFFAF52DE)],
        'onTap': () => Get.to(() => const BornPage()),
      },
      {
        'title': 'Holiday',
        'icon': Icons.celebration_rounded,
        'color': const Color(0xFFFF9500),
        'gradient': [const Color(0xFFFFB340), const Color(0xFFFF9500)],
        'onTap': () => Get.to(() => const CountryPage()),
      },
      {
        'title': 'History',
        'icon': Icons.history_edu_rounded,
        'color': const Color(0xFF5856D6),
        'gradient': [const Color(0xFF8E8FFA), const Color(0xFF5856D6)],
        'onTap': () => Get.to(() => const HistoryPage()),
      },
      {
        'title': 'World Time',
        'icon': Icons.access_time_rounded,
        'color': const Color(0xFF00C7BE),
        'gradient': [const Color(0xFF32D8D2), const Color(0xFF00C7BE)],
        'onTap': () => Get.to(() => const TimeListPage()),
      },
      {
        'title': 'Age Calculator',
        'icon': Icons.calculate_rounded,
        'color': primaryOrange,
        'gradient': [const Color(0xFFFF8A65), primaryOrange],
        'onTap': () => Get.to(() => const AgeCalculatorScreen()),
      },
      {
        'title': 'Rate & Review',
        'icon': Icons.star_rounded,
        'color': const Color(0xFFFFD60A),
        'gradient': [const Color(0xFFFFE135), const Color(0xFFFFD60A)],
        'onTap': () async {
          if (!await launchUrl(
            Uri.parse(
                "https://play.google.com/store/apps/details?id=com.bhinfotech.usafuelprice&hl=en"),
          )) {
            throw Exception('Could not launch');
          }
        },
      },
    ];

    return Column(
      children: services.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> service = entry.value;
        
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, (1 - _animationController.value) * 30 * (index + 1)),
              child: Opacity(
                opacity: _animationController.value,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildEnhancedServiceCard(
                    service['title'],
                    service['icon'],
                    service['color'],
                    service['gradient'],
                    service['onTap'],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildEnhancedServiceCard(
    String title,
    IconData icon,
    Color color,
    List<Color> gradient,
    Function() onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: darkBlue,
                      fontFamily: "SF Pro Text",
                      fontSize: 17.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: darkBlue.withOpacity(0.4),
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}