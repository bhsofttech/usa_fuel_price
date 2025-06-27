import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeWidget extends StatelessWidget {
  final Color? titleColor;
  const DateTimeWidget({super.key, this.titleColor});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Text(
        "${DateFormat(' d MMM, yyyy').format(DateTime.now())} - ${DateFormat('EEEE').format(DateTime.now())}",
        style:  TextStyle(
          fontWeight: FontWeight.w500,
          fontFamily: "RiformaLL",
          fontSize: 14,
          color:titleColor?? const Color(0xff0D9D7C),
        ),
      ),
    );
  }
}
