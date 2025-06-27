import 'package:usa_gas_price/model/gas_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;

class GasController extends GetxController {
  List<Gasinfo> gasInfo = [];

  List<Gasinfo> get getGasInfo => gasInfo;
  Rx showGasLoading = false.obs;
  Future<void> fetchGasPrice({
    required String endPoint,
  }) async {
    try {
      gasInfo = [];
      showGasLoading.value = true;
      Uri dataLink = Uri.parse("https://gasprices.aaa.com$endPoint");
      final responce = await http.get(dataLink);
      dom.Document html = dom.Document.html(responce.body);
      var cell = html.getElementsByTagName("tr");

      final loopLength = endPoint.isEmpty ? 6 : cell.length;
      for (int i = 1; i < loopLength; i++) {
        Gasinfo _info = Gasinfo(
          link: endPoint == "/state-gas-price-averages/"
              ? cell[i]
                  .children[0]
                  .getElementsByTagName("a")
                  .first
                  .attributes["href"]
                  .toString()
              : "",
          city: cell[i].children[0].text.trim(),
          regular: cell[i].children[1].text.trim(),
          midGrade: cell[i].children[2].text.trim(),
          premium: endPoint == "/ev-charging-prices/"
              ? ""
              : cell[i].children[3].text.trim(),
          diesel: endPoint == "/ev-charging-prices/"
              ? ""
              : cell[i].children[4].text.trim(),
        );
        gasInfo.add(_info);
      }
      showGasLoading.value = false;
    } catch (e) {
      showGasLoading.value = false;

      debugPrint(e.toString());
    }
  }

  List<Gasinfo> gasInfoAvg = [];
  List<Gasinfo> get getGasInfoAvg => gasInfoAvg;
  Rx showGasLoadingAvg = false.obs;
  Future<void> fetchGasPriceAvg({
    required String endPoint,
  }) async {
    try {
      gasInfoAvg = [];
      showGasLoadingAvg.value = true;
      Uri dataLink = Uri.parse("https://gasprices.aaa.com$endPoint");
      final responce = await http.get(dataLink);
      dom.Document html = dom.Document.html(responce.body);
      var cell = html.getElementsByTagName("tr");

      final loopLength = endPoint.isEmpty ? 6 : cell.length;
      for (int i = 1; i < loopLength; i++) {
        Gasinfo _info = Gasinfo(
          link: endPoint == "/state-gas-price-averages/"
              ? cell[i]
                  .children[0]
                  .getElementsByTagName("a")
                  .first
                  .attributes["href"]
                  .toString()
              : "",
          city: cell[i].children[0].text.trim(),
          regular: cell[i].children[1].text.trim(),
          midGrade: cell[i].children[2].text.trim(),
          premium: endPoint == "/ev-charging-prices/"
              ? ""
              : cell[i].children[3].text.trim(),
          diesel: endPoint == "/ev-charging-prices/"
              ? ""
              : cell[i].children[4].text.trim(),
        );
        gasInfoAvg.add(_info);
      }
      showGasLoadingAvg.value = false;
    } catch (e) {
      showGasLoadingAvg.value = false;

      debugPrint(e.toString());
    }
  }

  List<Gasinfo> _gasDetails = [];

  List<Gasinfo> get getGasDetails => _gasDetails;
  Rx showGasDetailLoading = false.obs;
  Future<void> fetchGasDetailsPrice({
    required String endPoint,
  }) async {
    try {
      _gasDetails = [];
      showGasDetailLoading.value = true;
      Uri dataLink = Uri.parse(endPoint);
      final responce = await http.get(dataLink);
      dom.Document html = dom.Document.html(responce.body);
      var cell = html.getElementsByTagName("tr");

      for (int i = 1; i < 6; i++) {
        Gasinfo _info = Gasinfo(
          link: "",
          city: cell[i].children[0].text.trim(),
          regular: cell[i].children[1].text.trim(),
          midGrade: cell[i].children[2].text.trim(),
          premium: cell[i].children[3].text.trim(),
          diesel: cell[i].children[4].text.trim(),
        );
        _gasDetails.add(_info);
      }
      showGasDetailLoading.value = false;
    } catch (e) {
      showGasDetailLoading.value = false;

      debugPrint(e.toString());
    }
  }
}
