import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';
import 'package:usa_gas_price/pages/home_setup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Initialize firebase analytics...
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final GoogleAdsController googleAdsController =
      Get.put(GoogleAdsController());

  // Modern iOS color palette matching other screens
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color lightBlue = const Color(0xFF4DA6FF);
  final Color backgroundGray = const Color(0xFFF2F2F7);
  final Color cardWhite = const Color(0xFFFFFFFF);
  final Color textPrimary = const Color(0xFF1C1C1E);
  final Color textSecondary = const Color(0xFF8E8E93);

  @override
  void initState() {
    super.initState();
    googleAdsController.loadAppOpenAd();
    googleAdsController.loadAdMobRewardedAd();

    Future.delayed(const Duration(milliseconds: 2500), () {
      // Exit full-screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      Get.offAll(() => const HomeSetupScreen());
      FirebaseAnalyticsObserver observer =
          FirebaseAnalyticsObserver(analytics: analytics);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryBlue.withOpacity(0.9),
              lightBlue.withOpacity(0.9),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated logo/icon
              Hero(
                tag: 'app-logo',
                child: Container(
                  padding: const EdgeInsets.all(16), // Reduced padding
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        cardWhite.withOpacity(0.9),
                        cardWhite.withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryBlue.withOpacity(0.3),
                        blurRadius: 12, // Reduced blur
                        spreadRadius: 2, // Adjusted spread
                        offset: const Offset(0, 2), // Smaller offset
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.local_gas_station,
                    size: 48, // Reduced size
                    color: primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 20), // Reduced spacing
              // App title with animation
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic, // Aligned with other screens
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 15 * (1 - value)), // Reduced offset
                      child: child,
                    ),
                  );
                },
                child: Text(
                  "USA Fuel Prices",
                  style: TextStyle(
                    color: cardWhite,
                    fontFamily: "SF Pro Display", // Aligned font
                    fontSize: 28.0, // Reduced font size
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5, // Adjusted letter spacing
                  ),
                ),
              ),
              const SizedBox(height: 8), // Reduced spacing
              // Subtitle
              Text(
                "Real-time fuel price tracker",
                style: TextStyle(
                  color: cardWhite.withOpacity(0.8),
                  fontFamily: "SF Pro Text", // Aligned font
                  fontSize: 14.0, // Reduced font size
                  fontWeight: FontWeight.w400,
                ),
              ),
              // Loading indicator at the bottom
              const SizedBox(height: 40), // Reduced spacing
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(cardWhite),
                strokeWidth: 2,
                backgroundColor: cardWhite.withOpacity(0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
