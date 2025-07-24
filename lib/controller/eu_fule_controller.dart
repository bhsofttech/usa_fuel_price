import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:usa_gas_price/model/fuel_model.dart';

class EUFuelController extends GetxController {
  List<EUFuelInfo> fuelInfo = [];

  List<EUFuelInfo> get getFuelInfo => fuelInfo;
  Rx showFuelLoading = false.obs;
  Future<void> fetchFuelPrice({
    required String endPoint,
  }) async {
    try {
      fuelInfo = [];
      showFuelLoading.value = true;
      Uri dataLink = Uri.parse("https://fuelo.eu/?convertto=eur");
      final responce = await http.get(dataLink);
      dom.Document html = dom.Document.html(responce.body);
      var cell = html.getElementsByTagName("tr");

      for (int i = 2; i < cell.length; i++) {
        EUFuelInfo _info = EUFuelInfo(
            flag: "",
            //  endPoint == "/state-gas-price-averages/"
            //       ? cell[i]
            //           .children[0]
            //           .getElementsByTagName("a")
            //           .first
            //           .attributes["href"]
            //           .toString()
            //       : "",
            country: cell[i].children[0].text.toString().trim(),
            gasoline:
                "${cell[i].children[1].text.toString().trim().substring(0, 5).replaceAll(",", ".")}",
            diesel:
                "${cell[i].children[5].text.toString().trim().substring(0, 5).replaceAll(",", ".")}",
            lpg:
                "${cell[i].children[9].text.toString().trim().substring(0, 5).replaceAll(",", ".")}");
        fuelInfo.add(_info);
      }
      showFuelLoading.value = false;
    } catch (e) {
      showFuelLoading.value = false;

      debugPrint(e.toString());
    }
  }

  List<EUFuelInfo> moreFuelInfo = [];
  List<EUFuelInfo> get getMoreFuelInfo => moreFuelInfo;
  Rx showMoreFuelLoading = false.obs;

  Future<void> fetchMoreFuelPrice({
    required String endPoint,
  }) async {
    try {
      moreFuelInfo = [];
      showMoreFuelLoading.value = true;
      Uri dataLink = Uri.parse("https://ba.fuelo.net/?lang=en");
      final responce = await http.get(dataLink);
      dom.Document html = dom.Document.html(responce.body);
      var cell = html.getElementsByClassName("box col-sm-6 col-md-4");

      for (int i = 0; i < cell.length; i++) {
        EUFuelInfo _info = EUFuelInfo(
          flag: "",
          country: cell[i].children[0].text.toString().trim(),
          gasoline: cell[i].children[1].children[0].text.toString().trim(),
        
        );
        moreFuelInfo.add(_info);
      }
      showMoreFuelLoading.value = false;
    } catch (e) {
      showMoreFuelLoading.value = false;

      debugPrint(e.toString());
    }
  }
}
