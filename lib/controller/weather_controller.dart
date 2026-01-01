import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:usa_gas_price/model/weather_indo.dart';

class WeatherController extends GetxController {
  List<WeatherInfo> weather = [];

  List<WeatherInfo> get getWeather => weather;
  Rx showLoading = false.obs;

  Future<void> fetchWeather() async {
    try {
      showLoading.value = true;
      weather = [];
      Uri dataLink = Uri.parse("https://www.timeanddate.com/weather/?low=4");

      final responce = await http.get(dataLink);
      dom.Document html = dom.Document.html(responce.body);
      var cell = html.getElementsByTagName("tr");
      List<WeatherInfo> tempList = [];

      for (int i = 1; i < cell.length; i++) {
        WeatherInfo _info = WeatherInfo(
          city: cell[i].children[0].text,
          time: cell[i].children[1].text.split(" ").last,
          image: cell[i]
              .children[2]
              .getElementsByTagName("img")
              .first
              .attributes["src"]
              .toString(),
          temp: cell[i].children[3].text.split(" ").last,
        );
        tempList.add(_info);
      }

      for (int i = 1; i < cell.length; i++) {
        WeatherInfo _info = WeatherInfo(
          city: cell[i].children[4].text,
          time: cell[i].children[5].text.split(" ").last,
          image: cell[i]
              .children[2]
              .getElementsByTagName("img")
              .first
              .attributes["src"]
              .toString(),
          temp: cell[i].children[3].text.split(" ").last,
        );
        tempList.add(_info);
      }

      weather = tempList;
      update();
      showLoading.value = false;
    } catch (e) {
      debugPrint(e.toString());
      showLoading.value = false;
    }
  }
}
