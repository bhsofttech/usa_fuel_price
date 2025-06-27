import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue.shade900, // Solid color, no gradient
        centerTitle: true,
        title: const Text(
          "More",
          style: TextStyle(
            color: Colors.cyanAccent,
            fontFamily: "Poppins",
            fontSize: 22.0,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            shadows: [
              Shadow(
                blurRadius: 6.0,
                color: Colors.black26,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade900, // Solid color, no gradient
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade700.withOpacity(0.9),
                Colors.blue.shade900.withOpacity(1.0),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade700.withOpacity(0.4),
                          Colors.blue.shade900.withOpacity(0.3),
                        ],
                      ),
                      border: GradientBoxBorder(
                        gradient: LinearGradient(
                          colors: [
                            Colors.cyanAccent.withOpacity(0.5),
                            Colors.blueAccent.withOpacity(0.5),
                          ],
                        ),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      "If you enjoy using this app or have any suggestions, we kindly invite you to rate it and leave a review. Your feedback is greatly appreciated, and we thank you for your valuable contribution.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Colors.cyanAccent.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    onPressed: () {
                      _launchUrl();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          size: 24,
                          color: Colors.cyanAccent,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Rate and Review",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Colors.cyanAccent.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    onPressed: () {
                      _launchUrlOne();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.share,
                          size: 24,
                          color: Colors.cyanAccent,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Share app",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(Uri.parse(
        "https://play.google.com/store/apps/details?id=com.bhinfotech.usafuelprice"))) {
      throw Exception('Could not launch');
    }
  }

  Future<void> _launchUrlOne() async {
    await Share.share(
        'https://play.google.com/store/apps/details?id=com.bhinfotech.usafuelprice');
  }
}
