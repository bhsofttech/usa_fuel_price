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

  @override
  void initState() {
    super.initState();
    googleAdsController.loadAdMobRewardedAd();

    Future.delayed(const Duration(milliseconds: 2000), () {
      //exit full-screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      Get.offAll(() => const HomeSetupScreen());
      FirebaseAnalyticsObserver observer =
          FirebaseAnalyticsObserver(analytics: analytics);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900.withOpacity(0.9),
              Colors.blue.shade800.withOpacity(0.9),
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
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.tealAccent.withOpacity(0.8),
                        Colors.cyan.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.tealAccent.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_gas_station,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // App title with animation
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: const Text(
                  "USA FUEL PRICES",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Poppins",
                    fontSize: 32.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Subtitle
              const Text(
                "Real-time fuel price tracker",
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: "Poppins",
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              // Loading indicator at the bottom
              const SizedBox(height: 80),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
