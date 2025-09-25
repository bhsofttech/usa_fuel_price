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
  final Color primaryBlue = const Color(0xFF007AFF);

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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                "NATIONAL AVG GAS PRICE",
                style: TextStyle(
                  color: primaryBlue,
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
                  color: primaryBlue.withOpacity(0.6),
                  fontFamily: "SF Pro Text",
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _gasController.gasInfoAvg[0].regular,
                style: TextStyle(
                  color: primaryBlue,
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
                      color: primaryBlue,
                    ),
                    buildPrice(
                      title: "MidGrade",
                      price: _gasController.gasInfoAvg[0].midGrade,
                      color: primaryBlue,
                    ),
                    buildPrice(
                      title: "Premium",
                      price: _gasController.gasInfoAvg[0].premium,
                      color: primaryBlue,
                    ),
                    buildPrice(
                      title: "Diesel",
                      price: _gasController.gasInfoAvg[0].diesel,
                      color: primaryBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.9),
                    Colors.white.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _gasController.gasInfoAvg[index].city,
                    style: TextStyle(
                      color: primaryBlue,
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
                          color: primaryBlue,
                        ),
                        buildPrice(
                          title: "MidGrade",
                          price: _gasController.gasInfoAvg[index].midGrade,
                          color: primaryBlue,
                        ),
                        buildPrice(
                          title: "Premium",
                          price: _gasController.gasInfoAvg[index].premium,
                          color: primaryBlue,
                        ),
                        buildPrice(
                          title: "Diesel",
                          price: _gasController.gasInfoAvg[index].diesel,
                          color: primaryBlue,
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
          fontSize: 12.0, // Consistent font size
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 4), // Consistent spacing
      Text(
        price,
        style: TextStyle(
          color: color,
          fontFamily: "SF Pro Text",
          fontSize: 14.0, // Reduced font size
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
