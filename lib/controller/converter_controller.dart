import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../model/smart_time_model.dart';

class ConverterController extends GetxController {
  // Data Source
  RxList<AppRegion> availableRegions = <AppRegion>[].obs;

  // Selections
  Rx<AppRegion?> fromRegion = Rx<AppRegion?>(null);
  Rx<AppLocation?> fromLocation = Rx<AppLocation?>(null);

  Rx<AppRegion?> toRegion = Rx<AppRegion?>(null);
  Rx<AppLocation?> toLocation = Rx<AppLocation?>(null);

  // Time State
  Rx<DateTime> selectedTime = DateTime.now().obs;
  Rx<DateTime> convertedTime = DateTime.now().obs;

  // Slider Value (0 - 1439 minutes from midnight)
  RxDouble sliderValue = 0.0.obs;

  // UI Helpers
  RxString timeDifferenceText = "".obs;
  RxString humanReadableText = "".obs;
  RxBool isDayTime = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTimeZones();

    // Set default time to now (clamped to minutes)
    final now = DateTime.now();
    sliderValue.value = (now.hour * 60 + now.minute).toDouble();
    selectedTime.value = now;

    // Listen to changes
    ever(fromLocation, (_) => _calculateConversion());
    ever(toLocation, (_) => _calculateConversion());
    ever(sliderValue, (_) => _updateTimeFromSlider());
  }

  void _loadTimeZones() {
    final database = tz.timeZoneDatabase;

    Map<String, List<AppLocation>> tempRegions = {};

    // Helper to add location
    void add(String region, AppLocation loc) {
      if (!tempRegions.containsKey(region)) tempRegions[region] = [];
      tempRegions[region]!.add(loc);
    }

    // Common USA Timezones (Manual List for accuracy as requested)
    final usaIds = [
      'America/New_York',
      'America/Chicago',
      'America/Denver',
      'America/Los_Angeles',
      'America/Phoenix',
      'America/Anchorage',
      'America/Honolulu',
      'America/Detroit',
      'America/Indiana/Indianapolis'
    ];

    for (var id in database.locations.keys) {
      final parts = id.split('/');
      if (parts.length < 2) continue;

      final regionKey = parts[0];
      final city = parts.sublist(1).join(' ').replaceAll('_', ' ');
      final appLoc = AppLocation(name: city, timezoneId: id);

      if (usaIds.contains(id)) {
        add('USA', appLoc);
      }

      if (regionKey == 'Europe')
        add('Europe', appLoc);
      else if (regionKey == 'Asia')
        add('Asia', appLoc);
      else if (regionKey == 'Australia')
        add('Australia', appLoc);
      else if (regionKey == 'Africa')
        add('Africa', appLoc);
      else if (regionKey == 'America') {
        if (!usaIds.contains(id)) {
          add('Americas', appLoc);
        }
      }
    }

    // Convert map to list and sort
    final List<AppRegion> regions = [];
    tempRegions.forEach((key, value) {
      value.sort((a, b) => a.name.compareTo(b.name));
      regions.add(AppRegion(name: key, locations: value));
    });

    regions.sort((a, b) => a.name.compareTo(b.name));

    // Move USA to top if exists
    final usaIndex = regions.indexWhere((r) => r.name == 'USA');
    if (usaIndex != -1) {
      final usa = regions.removeAt(usaIndex);
      regions.insert(0, usa);
    }

    availableRegions.value = regions;

    // Defaults
    if (regions.isNotEmpty) {
      fromRegion.value = regions.first;
      if (regions.first.locations.isNotEmpty) {
        fromLocation.value = regions.first.locations.first;
      }

      // Try to find a different default for 'To'
      if (regions.length > 1) {
        toRegion.value = regions[1];
        if (regions[1].locations.isNotEmpty) {
          var diff = regions[1].locations.first;
          toLocation.value = diff;
        }
      } else {
        toRegion.value = regions.first;
        toLocation.value = regions.first.locations.last;
      }
    }
  }

  void _updateTimeFromSlider() {
    if (fromLocation.value == null) return;

    final int totalMinutes = sliderValue.value.round();
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;

    final fromLoc = tz.getLocation(fromLocation.value!.timezoneId);
    final tz.TZDateTime nowInFrom = tz.TZDateTime.now(fromLoc);

    final newTime = tz.TZDateTime(
      fromLoc,
      nowInFrom.year,
      nowInFrom.month,
      nowInFrom.day,
      hours,
      minutes,
    );

    selectedTime.value = newTime;
    _calculateConversion();
  }

  void _calculateConversion() {
    if (fromLocation.value == null || toLocation.value == null) return;

    final fromLoc = tz.getLocation(fromLocation.value!.timezoneId);
    final toLoc = tz.getLocation(toLocation.value!.timezoneId);

    final int totalMinutes = sliderValue.value.round();
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;

    final tz.TZDateTime nowInFrom = tz.TZDateTime.now(fromLoc);
    final fromTime = tz.TZDateTime(
      fromLoc,
      nowInFrom.year,
      nowInFrom.month,
      nowInFrom.day,
      hours,
      minutes,
    );

    selectedTime.value = fromTime;

    // Convert
    final toTime = tz.TZDateTime.from(fromTime, toLoc);
    convertedTime.value = toTime;

    // Calc Difference
    final offsetDiff = toTime.timeZoneOffset - fromTime.timeZoneOffset;
    final inMinutes = offsetDiff.inMinutes;
    final absMinutes = inMinutes.abs();
    final diffHours = absMinutes ~/ 60;
    final diffMins = absMinutes % 60;
    final sign = inMinutes >= 0 ? "+" : "-";

    String diffText = "$sign$diffHours h";
    if (diffMins > 0) diffText += " $diffMins min";

    String aheadBehind = inMinutes >= 0 ? "Ahead" : "Behind";
    if (inMinutes == 0) aheadBehind = "Same Time";

    timeDifferenceText.value = "$diffText ($aheadBehind)";

    // Human Readable
    // Check day difference
    String dayDiff = "";
    final dayOnlyDiff = DateTime(toTime.year, toTime.month, toTime.day)
        .difference(DateTime(fromTime.year, fromTime.month, fromTime.day))
        .inDays;

    if (dayOnlyDiff > 0)
      dayDiff = " (Next Day)";
    else if (dayOnlyDiff < 0) dayDiff = " (Prev Day)";

    final fmt = DateFormat('h:mm a');
    humanReadableText.value =
        "When it's ${fmt.format(fromTime)} in ${fromLocation.value!.name} → ${fmt.format(toTime)} in ${toLocation.value!.name}$dayDiff";

    // Update visuals
    isDayTime.value = fromTime.hour >= 6 && fromTime.hour < 18;
    update();
  }

  void savePairAsFavorite() {
    Get.snackbar(
      "Saved",
      "Location pair saved to favorites (Placeholder)",
      colorText: Colors.white,
      backgroundColor: Colors.white12,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }
}
