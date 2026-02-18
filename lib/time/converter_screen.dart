import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:usa_gas_price/controller/converter_controller.dart';
import 'package:usa_gas_price/model/smart_time_model.dart';

class ConverterScreen extends StatelessWidget {
  const ConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller
    final controller = Get.put(ConverterController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Converter'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Selection Area
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: _buildSelectionCard(context, controller),
              ),
              const SizedBox(height: 16),

              // Visual Slider & Source Time
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 200),
                child: _buildSliderCard(context, controller),
              ),
              const SizedBox(height: 16),

              // Result Area
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 400),
                child: _buildResultCard(context, controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard(
      BuildContext context, ConverterController controller) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          _buildDropdownRow(context, controller,
              label: "From",
              regionVar: controller.fromRegion,
              locVar: controller.fromLocation),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: theme.dividerColor, height: 1),
          ),
          _buildDropdownRow(context, controller,
              label: "To",
              regionVar: controller.toRegion,
              locVar: controller.toLocation),
        ],
      ),
    );
  }

  Widget _buildDropdownRow(
    BuildContext context,
    ConverterController controller, {
    required String label,
    required Rx<AppRegion?> regionVar,
    required Rx<AppLocation?> locVar,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: theme.hintColor)),
        const SizedBox(height: 8),
        Obx(() => Row(
              children: [
                // Region Dropdown
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF0F172A)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<AppRegion>(
                        value: regionVar.value,
                        dropdownColor: theme.cardColor,
                        isExpanded: true,
                        style: theme.textTheme.bodyMedium,
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: theme.iconTheme.color?.withOpacity(0.5)),
                        items: controller.availableRegions
                            .map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(r.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            regionVar.value = val;
                            // Reset location to first in new region
                            if (val.locations.isNotEmpty) {
                              locVar.value = val.locations.first;
                            } else {
                              locVar.value = null;
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Location Dropdown
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF0F172A)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<AppLocation>(
                        value: locVar.value,
                        dropdownColor: theme.cardColor,
                        isExpanded: true,
                        style: theme.textTheme.bodyMedium,
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: theme.iconTheme.color?.withOpacity(0.5)),
                        items: regionVar.value?.locations
                            .map((l) => DropdownMenuItem(
                                  value: l,
                                  child: Text(l.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ))
                            .toList(),
                        onChanged: (val) => locVar.value = val,
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ],
    );
  }

  Widget _buildSliderCard(
      BuildContext context, ConverterController controller) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          // Icon and Time
          Obx(() {
            final time = controller.selectedTime.value;
            final isDay = controller.isDayTime.value;
            return Column(
              children: [
                Icon(
                  isDay ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                  size: 32,
                  color: isDay ? Colors.amber : theme.colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('h:mm a').format(time),
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  controller.fromLocation.value?.name ?? "Select Location",
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.hintColor),
                ),
              ],
            );
          }),

          const SizedBox(height: 24),

          // Slider
          Obx(() => Slider(
                value: controller.sliderValue.value,
                min: 0,
                max: 1439,
                activeColor: theme.colorScheme.primary,
                inactiveColor: theme.dividerColor,
                onChanged: (val) => controller.sliderValue.value = val,
              )),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("12 AM",
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.hintColor)),
                Text("12 PM",
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.hintColor)),
                Text("11:59 PM",
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.hintColor)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildResultCard(
      BuildContext context, ConverterController controller) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text("CONVERTED TIME",
              style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: theme.colorScheme.primary)),
          const SizedBox(height: 12),
          Obx(() => Text(
                DateFormat('h:mm a').format(controller.convertedTime.value),
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              )),
          Obx(() => Text(
                controller.toLocation.value?.name ?? "Select Location",
                style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8)),
              )),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Obx(() => Text(
                  controller.timeDifferenceText.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600),
                )),
          ),
          const SizedBox(height: 20),
          Obx(() => Text(
                controller.humanReadableText.value,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.hintColor, height: 1.4),
              )),
        ],
      ),
    );
  }
}
