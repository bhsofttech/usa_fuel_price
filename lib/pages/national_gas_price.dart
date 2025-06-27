import 'dart:async';
import 'package:intl/intl.dart';
import 'package:usa_gas_price/controller/gas_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NationalGasPrice extends StatefulWidget {
  const NationalGasPrice({super.key});

  @override
  State<NationalGasPrice> createState() => _NationalGasPriceState();
}

class _NationalGasPriceState extends State<NationalGasPrice> {
  final GasController _gasController = Get.find();
  final Color primaryOrange = const Color(0xffF47D4E);
  final Color darkBlue = const Color(0xFF0A4B9A);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _buildPriceList(),
    );
  }

  Widget _buildPriceList() {
    return Column(
      children: [
        // National Average Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                "NATIONAL AVG GAS PRICE",
                style: TextStyle(
                  color: darkBlue.withOpacity(0.8),
                  fontFamily: "SF Pro Text",
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMMM d, yyyy')
                    .format(DateTime.now().toUtc().toLocal()),
                style: TextStyle(
                  color: darkBlue.withOpacity(0.6),
                  fontFamily: "SF Pro Text",
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _gasController.gasInfoAvg[0].regular,
                style: TextStyle(
                  color: primaryOrange,
                  fontFamily: "SF Pro Display",
                  fontSize: 42.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFF2F2F7),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildPrice(
                      title: "Regular",
                      price: _gasController.gasInfoAvg[0].regular,
                      color: primaryOrange,
                    ),
                    buildPrice(
                      title: "MidGrade",
                      price: _gasController.gasInfoAvg[0].midGrade,
                      color: primaryOrange,
                    ),
                    buildPrice(
                      title: "Premium",
                      price: _gasController.gasInfoAvg[0].premium,
                      color: primaryOrange,
                    ),
                    buildPrice(
                      title: "Diesel",
                      price: _gasController.gasInfoAvg[0].diesel,
                      color: primaryOrange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Regional Prices List
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _gasController.gasInfoAvg.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) return const SizedBox.shrink();
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _gasController.gasInfoAvg[index].city,
                    style: TextStyle(
                      color: darkBlue,
                      fontFamily: "SF Pro Text",
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFF2F2F7),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildPrice(
                          title: "Regular",
                          price: _gasController.gasInfoAvg[index].regular,
                          color: darkBlue,
                        ),
                        buildPrice(
                          title: "MidGrade",
                          price: _gasController.gasInfoAvg[index].midGrade,
                          color: darkBlue,
                        ),
                        buildPrice(
                          title: "Premium",
                          price: _gasController.gasInfoAvg[index].premium,
                          color: darkBlue,
                        ),
                        buildPrice(
                          title: "Diesel",
                          price: _gasController.gasInfoAvg[index].diesel,
                          color: darkBlue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

Widget buildPrice({
  required String title,
  required String price,
  required Color color,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        title,
        style: TextStyle(
          color: const Color(0xFF8E8E93),
          fontFamily: "SF Pro Text",
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        price,
        style: TextStyle(
          color: color,
          fontFamily: "SF Pro Text",
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
