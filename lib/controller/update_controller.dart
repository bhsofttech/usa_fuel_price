import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:usa_gas_price/model/data_info.dart';


class UpdateController extends GetxController {



  List<DataInfo> _data = [];
  List<DataInfo> get getdata => _data;
  RxBool showDataLoading = false.obs;

  Future<void> getData(String endPoint) async {
    try {
      showDataLoading.value = true;
      _data.clear();
      Uri dataLink = Uri.parse(endPoint);

      //https://finance.yahoo.com/markets/mutualfunds/gainers/?start=0&count=100
      final responce = await http.get(dataLink);

      dom.Document html = dom.Document.html(responce.body);
      // var table = html.getElementsByTagName("table")[4];
      // print(table.length);
      var data = html.getElementsByTagName("tr");

      if (endPoint.contains("crypto") || endPoint.contains("commodities")) {
        for (int i = 0; i < data.length; i++) {
          DataInfo dataInfo = DataInfo(
            one: data[i].children[0].text.trim(),
            two: data[i].children[1].text.trim(),
            three: data[i].children[2].text.trim(),
            four: data[i].children[3].text.trim(),
            five: data[i].children[4].text.trim(),
            six: data[i].children[5].text.trim(),
          );
          _data.add(dataInfo);
        }
      } else if (endPoint.contains("exports-by-country") ||
          endPoint.contains("exports-by-category") ||
          endPoint.contains("imports-by-country") ||
          endPoint.contains("imports-by-category")) {
        for (int i = 0; i < data.length; i++) {
          DataInfo dataInfo = DataInfo(
            one: data[i].children[0].text.trim(),
            two: data[i].children[1].text.trim(),
            three: data[i].children[2].text.trim(),
          );
          _data.add(dataInfo);
        }
      } else if (endPoint.contains("gdp-growth-rate") ||
          endPoint.contains("unemployment-rate")) {
        for (int i = 0; i < data.length; i++) {
          DataInfo dataInfo = DataInfo(
            one: data[i].children[0].text.trim(),
            two: data[i].children[1].text.trim(),
            three: data[i].children[2].text.trim(),
            four: data[i].children[3].text.trim(),
            five: data[i].children[4].text.trim(),
          );
          _data.add(dataInfo);
        }
      } else if (endPoint.contains("central-bank-balance-sheet") ||
          endPoint.contains("foreign-exchange-reserves") ||
          endPoint.contains("crude-oil-production") ||
          endPoint.contains("gold-reserves") ||
          endPoint.contains("gdp-per-capita") ||
          endPoint.contains("gdp-per-capita-ppp") ||
          endPoint.contains("military-expenditure") ||
          endPoint.contains("corporate-tax-rate") ||
          endPoint.contains("personal-income-tax-rate") ||
          endPoint.contains('hospitals') ||
          endPoint.contains("icu-beds") ||
          endPoint.contains("medical-doctors") ||
          endPoint.contains("nurses") ||
          endPoint.contains("co2-emissions") ||
          endPoint.contains("natural-gas-stocks-capacity") ||
          endPoint.contains("employment-rate") ||
          endPoint.contains("minimum-wages")) {
        for (int i = 0; i < data.length; i++) {
          DataInfo dataInfo = DataInfo(
            one: data[i].children[0].text.trim(),
            two: data[i].children[1].text.trim(),
            three: data[i].children[2].text.trim(),
            four: data[i].children[3].text.trim(),
            five: data[i].children[4].text.trim(),
            ////// six: data[i].children[6].text.trim(),
          );
          _data.add(dataInfo);
        }
      } else if (endPoint.contains("List_of_busiest_airports_in_India")) {
        for (int i = 0; i < data.length; i++) {
          DataInfo dataInfo = DataInfo(
            one: data[i].children[1].text.trim(),
            two: data[i].children[2].text.trim(),
            // three: data[i].children[3].text.trim(),
            // four: data[i].children[4].text.trim(),
            // five: data[i].children[5].text.trim(),
            // six: data[i].children[6].text.trim(),
          );
          _data.add(dataInfo);
        }
      } else {
        for (int i = 0; i < data.length; i++) {
          DataInfo dataInfo = DataInfo(
            one: data[i].children[1].text.trim(),
            two: data[i].children[2].text.trim(),
            three: data[i].children[3].text.trim(),
            four: data[i].children[4].text.trim(),
            five: data[i].children[5].text.trim(),
            six: data[i].children[6].text.trim(),
          );
          _data.add(dataInfo);
        }
      }

      showDataLoading.value = false;
    } catch (e) {
      showDataLoading.value = false;
    }
  }
}
