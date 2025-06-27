import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'data_details_screen.dart';

class MoreDataListScreen extends StatefulWidget {
  const MoreDataListScreen({super.key});

  @override
  State<MoreDataListScreen> createState() => _MoreDataListScreenState();
}

class _MoreDataListScreenState extends State<MoreDataListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildContainer(
              title: "World Currencies Price",
              onTap: () => Get.to(
                () => const DataDetailsScreen(
                  title: "AirPorts",
                  endPoint:
                      "https://en.wikipedia.org/wiki/List_of_busiest_airports_in_India#2023-24",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainer({
    required String title,
    required Function() onTap,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: const Color.fromRGBO(0, 0, 0, 0),
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: "RiformaLL",
                fontSize: 14,
              ),
            ),
            const RotatedBox(
              quarterTurns: 2,
              child: Icon(
                Icons.arrow_back_ios,
                size: 16,
              ),
            )
          ],
        ),
      ),
    );
  }
}
