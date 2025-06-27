import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usa_gas_price/model/born_info.dart';
import 'package:usa_gas_price/model/country_info.dart';
import 'package:usa_gas_price/model/history_info.dart';
import 'package:usa_gas_price/model/holyday_info.dart';
import 'package:usa_gas_price/model/time_info.dart';


class TimeController extends GetxController {
  List<Timeinfo> timeInfo = [];

  List<Timeinfo> get getTimeInfo => timeInfo;
  Rx showLoading = false.obs;
  List<Timeinfo> favorites = [];
  RxBool showFavouritesoading = false.obs;

  List<Timeinfo> usaTimeInfo = [];
  List<Timeinfo> europeTimeInfo = [];
  List<Timeinfo> asiaTimeInfo = [];

  Future<void> fetchTime() async {
    try {
      showLoading.value = true;
      usaTimeInfo = [];
      europeTimeInfo = [];
      asiaTimeInfo = [];
      // Uri dataLink =
      //     Uri.parse("https://www.timeanddate.com/worldclock/?sort=1&low=4");

      Uri dataLink = Uri.parse(
          "https://time.astro-seek.com/current-local-time-in-major-cities-around-the-world");

      final responce = await http.get(dataLink);
      dom.Document html = dom.Document.html(responce.body);
      var cell = html.getElementsByTagName("tr");
      List<Timeinfo> tempList = [];

      for (int i = 1; i < cell.length; i++) {
        Timeinfo _info = Timeinfo(
            city: cell[i].children[2].text,
            country: cell[i].children[4].text,
            timerCurrentTime:
                DateFormat("HH:mm").parse(cell[i].children[1].text).toUtc(),
            dateTime:
                DateFormat("HH:mm").parse(cell[i].children[1].text).toUtc());

        tempList.add(_info);
        if (_info.city.toLowerCase() == "new york city") {
          usaTimeInfo.add(_info);
        }
        if (_info.city.toLowerCase() == "los angeles") {
          usaTimeInfo.add(_info);
        }
        if (_info.city.toLowerCase() == "washington dc") {
          usaTimeInfo.add(_info);
        }

        if (_info.city.toLowerCase() == "london") {
          europeTimeInfo.add(_info);
        }
        if (_info.city.toLowerCase() == "berlin") {
          europeTimeInfo.add(_info);
        }
        if (_info.city.toLowerCase() == "paris") {
          europeTimeInfo.add(_info);
        }
        if (_info.city.toLowerCase() == "tokyo") {
          asiaTimeInfo.add(_info);
        }
        if (_info.city.toLowerCase() == "new delhi") {
          asiaTimeInfo.add(_info);
        }
        if (_info.city.toLowerCase() == "hong kong") {
          asiaTimeInfo.add(_info);
        }
      }
      timeInfo = tempList;
      for (var e in timeInfo) {
        for (var f in favorites) {
          if (e.city.toLowerCase() == f.city.toLowerCase()) {
            e.isFavourit = true;
          }
        }
      }
      update();
      showLoading.value = false;
    } catch (e) {
      debugPrint(e.toString());
      showLoading.value = false;
    }
  }

  Future<void> loadFavorites() async {
    try {
      await fetchTime();
      showFavouritesoading.value = true;
      final prefs = await SharedPreferences.getInstance();
      final String? favoritesJson = prefs.getString('favorites');
      if (favoritesJson != null) {
        List<Timeinfo> temp = timeinfoFromJson(favoritesJson);

        // Clear existing favorites before adding new ones
        favorites.clear();

        // For each saved favorite, find matching current time info
        for (var savedItem in temp) {
          var matchingItem = getTimeInfo.firstWhere(
            (current) =>
                current.city.toLowerCase() == savedItem.city.toLowerCase(),
            orElse: () => savedItem,
          );
          favorites.add(matchingItem);
        }
      }
      showFavouritesoading.value = false;
      update();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> saveFavorites({required Timeinfo info}) async {
    try {
      int index = favorites
          .indexWhere((e) => e.city.toLowerCase() == info.city.toLowerCase());
      if (index < 0) {
        favorites.add(info);
      } else {
        favorites.removeAt(index);
      }
      final prefs = await SharedPreferences.getInstance();
      // Convert the list to JSON
      String jsonString = timeinfoToJson(favorites);
      // Save the JSON string
      await prefs.setString('favorites', jsonString);
      await loadFavorites();
      update();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<HolidayInfo> _holiDays = [];
  List<HolidayInfo> get getHoliDays => _holiDays;
  RxBool showHolyDayLoading = false.obs;
  Future<void> fetchHoliDay({required String link}) async {
    try {
      showHolyDayLoading.value = true;
      _holiDays = [];
      Uri dataLink = Uri.parse(link);

      final responce = await http.get(dataLink);
      dom.Document html = dom.Document.html(responce.body);
      var holyDay = html.getElementsByTagName("tr");

      for (int i = 1; i < holyDay.length; i++) {
        HolidayInfo _temp = HolidayInfo(
          day: holyDay[i].children[0].text,
          date: holyDay[i].children[1].text,
          name: holyDay[i].children[2].text,
          type: holyDay[i].children[3].text,
          comment: holyDay[i].children[4].text,
        );
        _holiDays.add(_temp);
      }

      showHolyDayLoading.value = false;
    } catch (e) {
      debugPrint(e.toString());
      showHolyDayLoading.value = false;
    }
  }

  List<CountryInfo> _countryList = [];
  List<CountryInfo> get getCountrys => _countryList;
  RxBool showCountryLoading = false.obs;
  Future<void> fetchCountry() async {
    try {
      _countryList = [];
      showCountryLoading.value = true;
      Uri dataLink = Uri.parse("https://www.officeholidays.com/countries");

      final responce = await http.get(dataLink);
      dom.Document html = dom.Document.html(responce.body);
      var colums = html.getElementsByClassName("four omega columns");
      for (int k = 0; k < colums.length; k++) {
        var two = colums[k].getElementsByTagName("li");
        for (int i = 0; i < two.length; i++) {
          CountryInfo _temp = CountryInfo(
              country: two[i].children.first.text,
              link: two[i]
                  .getElementsByTagName("a")
                  .first
                  .attributes["href"]
                  .toString());
          _countryList.add(_temp);
        }
      }
      showCountryLoading.value = false;
    } catch (e) {
      debugPrint(e.toString());
      showCountryLoading.value = false;
    }
  }

  String calImage = "";
  String get getCalImage => calImage;
  RxBool showCalanderLoading = false.obs;
  Future<void> fetchCalander() async {
    try {
      calImage = "";
      showCalanderLoading.value = true;
      Uri dataLink = Uri.parse(
          "https://www.wincalendar.com/EU-Calendar/Printable-Calendar-May-2025");

      final responce = await http.get(dataLink);
      dom.Document html = dom.Document.html(responce.body);
      var colums = html.querySelectorAll("img");
      for (int k = 0; k < colums.length; k++) {
        calImage = colums[k]
            .attributes["src"]
            .toString()
            .replaceAll("//", "")
            .replaceAll('"', "");

        print(calImage);
      }

      showCalanderLoading.value = false;
    } catch (e) {
      debugPrint(e.toString());
      showCalanderLoading.value = false;
    }
  }

  List<HistoryInfo> history = [];
  List<HistoryInfo> get getHistory => history;
  RxBool showHistoryLoading = false.obs;
  Future<void> fetchHistory({
    required String month,
    required String date,
  }) async {
    try {
      history = [];
      showHistoryLoading.value = true;
      Uri dataLink = Uri.parse(
        "https://www.timeanddate.com/on-this-day/$month/$date",
      );

      final responce = await http.get(dataLink);
      dom.Document html = dom.Document.html(responce.body);
      var colums = html.getElementsByClassName("otd-row otd-detail");
      var li = colums[0].getElementsByTagName("li");

      for (int k = 0; k < li.length; k++) {
        HistoryInfo temp = HistoryInfo(
          title: li[k].children[0].text,
          subTitle: li[k].children[1].text,
        );
        history.add(temp);
      }

      showHistoryLoading.value = false;
    } catch (e) {
      debugPrint(e.toString());
      showHistoryLoading.value = false;
    }
  }

  List<TodaysBorn> _todaysBorn = [];
  List<TodaysBorn> get getTodaysBorn => _todaysBorn;
  RxBool showTodaysBornLoading = false.obs;
  Future<void> fetchBornToday() async {
    try {
      _todaysBorn = [];
      showTodaysBornLoading.value = true;
      Uri dataLink = Uri.parse(
        "https://famouspeople.astro-seek.com/famous-birthdays/24-may",
      );

      final responce = await http.get(dataLink);
      dom.Document html = dom.Document.html(responce.body);
      var colums = html.getElementsByTagName("tr");

      for (int k = 0; k < colums.length; k++) {
        if (colums[k].children[0].children[0].text.isNotEmpty) {
          TodaysBorn born = TodaysBorn(
            name: colums[k].children[0].children[0].text,
            date: colums[k].children[0].children[1].text,
            type: colums[k].children[1].text,
            // flagLink: colums[k]
            //     .children[1]
            //     .getElementsByTagName("img")
            //     .first
            //     .attributes["src"]
            //     .toString(),
            country: colums[k].children[3].text,
          );
          _todaysBorn.add(born);
        }
      }

      showTodaysBornLoading.value = false;
    } catch (e) {
      debugPrint(e.toString());
      showTodaysBornLoading.value = false;
    }
  }

  RxBool showAILoading = false.obs;
  Future<void> fetchAIList() async {
    try {
      showAILoading.value = true;
      Uri dataLink = Uri.parse(
        "https://www.aixploria.com/en/ultimate-list-ai/",
      );

      final responce = await http.get(dataLink);
      dom.Document html = dom.Document.html(responce.body);
      var colums = html.getElementsByClassName("grid-item");

      for (int k = 0; k < colums.length; k++) {
        TodaysBorn born = TodaysBorn(
          name: colums[k].children[0].text,

          // flagLink: colums[k]
          //     .children[1]
          //     .getElementsByTagName("img")
          //     .first
          //     .attributes["src"]
          //     .toString(),
          //country: colums[k].children[3].text,
        );
        _todaysBorn.add(born);
        print(born.name);
      }

      showAILoading.value = false;
    } catch (e) {
      debugPrint(e.toString());
      showAILoading.value = false;
    }
  }
}
