import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usa_gas_price/model/astronomy_data.dart' show AstronomyData;
import 'package:usa_gas_price/model/time_info.dart';
import 'package:usa_gas_price/model/weather_data.dart';

import '../model/location_data.dart';

class TimeController extends GetxController {
  // Existing USA specific list
  List<Timeinfo> usaTimeInfo = [];

  // Map to hold data for other continents/regions
  // Key: Region Name (e.g., 'Europe', 'Asia')
  Map<String, List<Timeinfo>> continentData = {};

  // Loading states for regions
  Map<String, bool> continentLoading = {};

  List<Timeinfo> favorites = [];

  RxBool showLoading = false.obs;
  RxBool showFavouritesLoading = false.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // Generic fetcher for continents
  Future<void> fetchContinentTime(String regionKey, String url) async {
    try {
      continentLoading[regionKey] = true;
      update(); // Update UI

      final headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept-Language': 'en-US,en;q=0.9',
      };

      Uri dataLink = Uri.parse(url);
      debugPrint("Fetching $regionKey: $dataLink");
      final response = await http.get(dataLink, headers: headers);

      if (response.statusCode == 200) {
        List<Timeinfo> extracted =
            _parseTimeAndDateHtml(response.body, regionKey);
        continentData[regionKey] = extracted;

        // Sync with favorites
        _syncFavoritesWithList(extracted);
      } else {
        debugPrint("Failed to load $regionKey: ${response.statusCode}");
      }

      continentLoading[regionKey] = false;

      // Ensure timer is running if it was stopped or not started
      if (_timer == null || !_timer!.isActive) {
        _startTimer();
      }

      update();
    } catch (e) {
      debugPrint("Error fetching $regionKey: $e");
      continentLoading[regionKey] = false;
      update();
    }
  }

  Future<void> fetchTime() async {
    try {
      showLoading.value = true;
      usaTimeInfo = [];
      update();

      // Actually let's just use the helper method logic but keep this dedicated function as it was "USA" specific
      // or we can refactor this to use the _parseTimeAndDateHtml helper.

      // Re-implementing using the helper for consistency but keeping specific usaTimeInfo variable
      // fetch for USA
      Uri dataLink = Uri.parse("https://www.timeanddate.com/worldclock/usa");
      final response = await http.get(dataLink, headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      });

      if (response.statusCode == 200) {
        usaTimeInfo = _parseTimeAndDateHtml(response.body, 'USA');
        _syncFavoritesWithList(usaTimeInfo);
      }

      _startTimer();
      showLoading.value = false;
      update();
    } catch (e) {
      debugPrint("Error scraping time: $e");
      showLoading.value = false;
      update();
    }
  }

  // Refactored parsing logic to be reusable
  List<Timeinfo> _parseTimeAndDateHtml(String htmlBody, String regionName) {
    List<Timeinfo> results = [];
    dom.Document html = dom.Document.html(htmlBody);

    // Find table
    dom.Element? table;
    var tables = html.getElementsByTagName("table");
    for (var t in tables) {
      if (t.attributes['class'] != null &&
          t.attributes['class']!.contains('tb-wc')) {
        table = t;
        break;
      }
    }
    if (table == null && tables.isNotEmpty) table = tables[0];

    if (table != null) {
      var rows = table.getElementsByTagName("tr");
      for (var row in rows) {
        var cells = row.getElementsByTagName("td");
        // Loop pairs
        for (int i = 0; i < cells.length; i += 2) {
          if (i + 1 < cells.length) {
            var nameCell = cells[i];
            var timeCell = cells[i + 1];

            String name = nameCell.text.trim();
            // Simple dedup check within this fetch
            if (results.any((item) => item.city == name)) continue;

            var timeStrRaw = timeCell.text.trim();
            final timeRegex = RegExp(r'(\d{1,2})[:.](\d{2})');
            final match = timeRegex.firstMatch(timeStrRaw);
            String timeStr =
                match != null ? match.group(0)! : timeStrRaw.split(" ").last;

            if (name.isNotEmpty && timeStr.isNotEmpty) {
              DateTime? parsedTime;
              try {
                String normalizedTimeStr = timeStr.replaceAll('.', ':');
                List<String> parts = normalizedTimeStr.split(":");
                if (parts.length >= 2) {
                  int hour = int.parse(parts[0]);
                  int minute = int.parse(parts[1]);
                  DateTime now = DateTime.now();
                  parsedTime =
                      DateTime(now.year, now.month, now.day, hour, minute);
                }
              } catch (e) {/* ignore */}

              results.add(Timeinfo(
                city: name,
                country: regionName, // Use passed region name
                time: timeStr,
                timerCurrentTime: parsedTime,
              ));
            }
          }
        }
      }
    }
    return results;
  }

  void _syncFavoritesWithList(List<Timeinfo> freshData) {
    for (var fav in favorites) {
      for (var fresh in freshData) {
        if (fav.city == fresh.city) {
          fav.timerCurrentTime = fresh.timerCurrentTime;
          fav.time = fresh.time;
          break;
        }
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Increment logic for USA
      for (var item in usaTimeInfo) {
        _tickItem(item);
      }

      // Increment logic for Continents
      continentData.forEach((_, list) {
        for (var item in list) {
          _tickItem(item);
        }
      });

      // Increment favorites
      for (var item in favorites) {
        _tickItem(item);
      }
      update();
    });
  }

  void _tickItem(Timeinfo item) {
    if (item.timerCurrentTime != null) {
      item.timerCurrentTime =
          item.timerCurrentTime!.add(const Duration(seconds: 1));
    }
  }

  // --- Favorites Logic ---

  Future<void> loadFavorites() async {
    try {
      showFavouritesLoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString('favorites');

      if (favoritesJson != null) {
        favorites = timeinfoFromJson(favoritesJson);
        // Sync with available data
        _syncFavoritesWithList(usaTimeInfo);
        continentData.forEach((_, list) => _syncFavoritesWithList(list));
      }

      showFavouritesLoading.value = false;
      update();
    } catch (e) {
      debugPrint("Error loading favorites: $e");
    }
  }

  Future<void> saveFavorites({required Timeinfo info}) async {
    try {
      int index = favorites
          .indexWhere((e) => e.city.toLowerCase() == info.city.toLowerCase());
      if (index >= 0) {
        favorites.removeAt(index);
      } else {
        favorites.add(Timeinfo(
          city: info.city,
          country: info.country,
          time: info.time.split(" ").last,
          timerCurrentTime: info.timerCurrentTime,
        ));
      }
      final prefs = await SharedPreferences.getInstance();
      String jsonString = timeinfoToJson(favorites);
      await prefs.setString('favorites', jsonString);
      update();
    } catch (e) {
      debugPrint("Error saving favorites: $e");
    }
  }

  // Fetch location-specific data from timeanddate.com
  Future<List<LocationData>> fetchLocationData(String stateOrCity) async {
    try {
      // Convert state/city name to URL format (lowercase, replace spaces with hyphens)
      String urlPath = stateOrCity.toLowerCase().replaceAll(' ', '-');
      String url = 'https://www.timeanddate.com/worldclock/usa/$urlPath';

      debugPrint("Fetching location data from: $url");

      final headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept-Language': 'en-US,en;q=0.9',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return _parseLocationHtml(response.body);
      } else {
        debugPrint("Failed to load location data: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching location data: $e");
      return [];
    }
  }

  // Parse HTML to extract location data
  List<LocationData> _parseLocationHtml(String htmlBody) {
    List<LocationData> locations = [];
    dom.Document html = dom.Document.html(htmlBody);

    // Find the table with class 'zebra fw tb-wc'
    dom.Element? table;
    var tables = html.getElementsByTagName("table");

    for (var t in tables) {
      if (t.attributes['class'] != null &&
          t.attributes['class']!.contains('tb-wc')) {
        table = t;
        break;
      }
    }

    if (table != null) {
      var rows = table.getElementsByTagName("tr");

      for (var row in rows) {
        var cells = row.getElementsByTagName("td");

        // Process cells in pairs (city name, time)
        for (int i = 0; i < cells.length; i += 2) {
          if (i + 1 < cells.length) {
            var nameCell = cells[i];
            var timeCell = cells[i + 1];

            // Extract city name from anchor tag
            var anchor = nameCell.getElementsByTagName("a");
            String cityName = anchor.isNotEmpty
                ? anchor.first.text.trim()
                : nameCell.text.trim();

            // Extract time
            String currentTime = timeCell.text.trim();

            if (cityName.isNotEmpty && currentTime.isNotEmpty) {
              locations.add(LocationData(
                cityName: cityName,
                currentTime: currentTime,
              ));
            }
          }
        }
      }
    }

    debugPrint("Parsed ${locations.length} locations");
    return locations;
  }

  // Fetch weather data from timeanddate.com
  Future<List<WeatherData>> fetchWeatherData(String stateOrCity) async {
    try {
      // Convert state/city name to URL format (lowercase, replace spaces with hyphens)
      String urlPath = stateOrCity.toLowerCase().replaceAll(' ', '-');
      String url = 'https://www.timeanddate.com/weather/usa/$urlPath';

      debugPrint("Fetching weather data from: $url");

      final headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept-Language': 'en-US,en;q=0.9',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return _parseWeatherHtml(response.body);
      } else {
        debugPrint("Failed to load weather data: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching weather data: $e");
      return [];
    }
  }

  // Parse HTML to extract weather data
  List<WeatherData> _parseWeatherHtml(String htmlBody) {
    List<WeatherData> weatherList = [];
    dom.Document html = dom.Document.html(htmlBody);

    // Find the table with class 'zebra fw tb-wt'
    dom.Element? table;
    var tables = html.getElementsByTagName("table");

    for (var t in tables) {
      if (t.attributes['class'] != null &&
          t.attributes['class']!.contains('tb-wt')) {
        table = t;
        break;
      }
    }

    if (table != null) {
      var rows = table.getElementsByTagName("tr");

      for (var row in rows) {
        var cells = row.getElementsByTagName("td");

        // Process cells in groups of 4 (city name, time, weather icon, temperature)
        for (int i = 0; i < cells.length; i += 4) {
          if (i + 3 < cells.length) {
            var nameCell = cells[i];
            var timeCell = cells[i + 1];
            var iconCell = cells[i + 2];
            var tempCell = cells[i + 3];

            // Extract city name from anchor tag
            var anchor = nameCell.getElementsByTagName("a");
            String cityName = anchor.isNotEmpty
                ? anchor.first.text.trim()
                : nameCell.text.trim();

            // Extract time
            String time = timeCell.text.trim();

            // Extract weather icon and description
            var img = iconCell.getElementsByTagName("img");
            String weatherIcon = '';
            String weatherDescription = '';

            if (img.isNotEmpty) {
              var imgSrc = img.first.attributes['src'] ?? '';
              // Make sure to use full URL
              if (imgSrc.startsWith('//')) {
                weatherIcon = 'https:$imgSrc';
              } else if (imgSrc.startsWith('/')) {
                weatherIcon = 'https://www.timeanddate.com$imgSrc';
              } else {
                weatherIcon = imgSrc;
              }
              weatherDescription = img.first.attributes['alt'] ?? '';
            }

            // Extract temperature
            String temperature = tempCell.text.trim();

            if (cityName.isNotEmpty) {
              weatherList.add(WeatherData(
                cityName: cityName,
                time: time,
                weatherIcon: weatherIcon,
                weatherDescription: weatherDescription,
                temperature: temperature,
              ));
            }
          }
        }
      }
    }

    debugPrint("Parsed ${weatherList.length} weather entries");
    return weatherList;
  }

  // Fetch astronomy data (sunrise/sunset) from timeanddate.com
  Future<List<AstronomyData>> fetchAstronomyData(String stateOrCity) async {
    try {
      // Convert state/city name to URL format (lowercase, replace spaces with hyphens)
      String urlPath = stateOrCity.toLowerCase().replaceAll(' ', '-');
      String url = 'https://www.timeanddate.com/astronomy/usa/$urlPath';

      debugPrint("Fetching astronomy data from: $url");

      final headers = {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept-Language': 'en-US,en;q=0.9',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return _parseAstronomyHtml(response.body);
      } else {
        debugPrint("Failed to load astronomy data: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching astronomy data: $e");
      return [];
    }
  }

  // Parse HTML to extract astronomy data
  List<AstronomyData> _parseAstronomyHtml(String htmlBody) {
    List<AstronomyData> astronomyList = [];
    dom.Document html = dom.Document.html(htmlBody);

    // Find the table with class 'zebra fw tb-sm'
    dom.Element? table;
    var tables = html.getElementsByTagName("table");

    for (var t in tables) {
      if (t.attributes['class'] != null &&
          t.attributes['class']!.contains('tb-sm')) {
        table = t;
        break;
      }
    }

    if (table != null) {
      var rows = table.getElementsByTagName("tr");

      for (var row in rows) {
        var cells = row.getElementsByTagName("td");

        // Process cells in groups of 3 (city name, sunrise, sunset)
        for (int i = 0; i < cells.length; i += 3) {
          if (i + 2 < cells.length) {
            var nameCell = cells[i];
            var sunriseCell = cells[i + 1];
            var sunsetCell = cells[i + 2];

            // Extract city name from anchor tag
            var anchor = nameCell.getElementsByTagName("a");
            String cityName = anchor.isNotEmpty
                ? anchor.first.text.trim()
                : nameCell.text.trim();

            // Extract sunrise time (remove the ↑ arrow)
            String sunrise = sunriseCell.text.trim().replaceAll('↑', '').trim();

            // Extract sunset time (remove the ↓ arrow)
            String sunset = sunsetCell.text.trim().replaceAll('↓', '').trim();

            if (cityName.isNotEmpty &&
                sunrise.isNotEmpty &&
                sunset.isNotEmpty) {
              astronomyList.add(AstronomyData(
                cityName: cityName,
                sunrise: sunrise,
                sunset: sunset,
              ));
            }
          }
        }
      }
    }

    debugPrint("Parsed ${astronomyList.length} astronomy entries");
    return astronomyList;
  }
}
