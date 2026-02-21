import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:usa_gas_price/model/time_info.dart';
import 'package:usa_gas_price/time/time_detail_screen.dart';

class TimeCard extends StatelessWidget {
  final Timeinfo item;
  final bool isFav;
  final VoidCallback onFavTap;

  const TimeCard({
    super.key,
    required this.item,
    required this.isFav,
    required this.onFavTap,
  });

  @override
  Widget build(BuildContext context) {
    // Format Display Time
    String displayTime = item.time;
    String amPm = "";

    if (item.timerCurrentTime != null) {
      displayTime = DateFormat('h:mm').format(item.timerCurrentTime!);
      amPm = DateFormat('a').format(item.timerCurrentTime!);
    } else {
      final parts = item.time.trim().split(" ");
      if (parts.isNotEmpty) {
        displayTime = parts.last;
      }
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Get.to(
            //   () => TimeDetailScreen(timeInfo: item),
            //   transition: Transition.cupertino,
            // );
          },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // City and Country
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.city,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.country.toUpperCase(),
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurfaceVariant,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      displayTime,
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (amPm.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          amPm,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 12),

                // Action
                InkWell(
                  onTap: onFavTap,
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav
                          ? const Color(0xFFFF3B30)
                          : colorScheme.onSurfaceVariant.withOpacity(0.4),
                      size: 24,
                    ),
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
