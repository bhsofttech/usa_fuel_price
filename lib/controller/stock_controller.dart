import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:usa_gas_price/main.dart';
import 'package:usa_gas_price/model/stock_data.dart';

class StockController extends GetxController {
  List<StockData> stocks = [];
  List<StockData> get getStocks => stocks;
  RxBool fechStockLoading = false.obs;
  Future<void> fetchStocks(String url) async {
    try {
      fechStockLoading.value = true;
      stocks = [];
      Uri dataLink = Uri.parse(url);
      final responce = await http.get(dataLink);
      dom.Document html = dom.Document.html(responce.body);
      var cell = html.getElementsByTagName("table")[0];
      var tr = cell.getElementsByTagName("tr");

      for (int i = 0; i < tr.length; i++) {
        StockData tempStock = StockData(
          image: i == 0 || tr[i].children[0].getElementsByTagName("img").isEmpty
              ? ""
              : tr[i]
                  .children[0]
                  .getElementsByTagName("img")
                  .first
                  .attributes["src"]
                  .toString(),
          url: i == 0 || tr[i].children[0].getElementsByTagName("a").isEmpty
              ? ""
              : tr[i]
                  .children[0]
                  .getElementsByTagName("a")
                  .first
                  .attributes["href"]
                  .toString(),
          shortName:
              i == 0 || tr[i].children[0].getElementsByTagName("a").isEmpty
                  ? ""
                  : tr[i]
                      .children[0]
                      .getElementsByTagName("a")
                      .first
                      .text
                      .toString()
                      .trim(),
          symbol: () {
            String shortName =
                i == 0 || tr[i].children[0].getElementsByTagName("a").isEmpty
                    ? ""
                    : tr[i]
                        .children[0]
                        .getElementsByTagName("a")
                        .first
                        .text
                        .toString()
                        .trim();
            String rawSymbol = tr[i].children[0].text.toString().trim();
            int charsToRemove = shortName.length;
            return rawSymbol.length >= charsToRemove
                ? rawSymbol.substring(charsToRemove).trim()
                : rawSymbol;
          }(),
          price: tr[i].children[1].text.toString().trim(),
          changePercent: tr[i].children[2].text.toString().trim(),
          volume: tr[i].children[3].text.toString().trim(),
          relativeVolume: tr[i].children[4].text.toString().trim(),
          marketCap: tr[i].children[5].text.toString().trim(),
          peRatio: tr[i].children[6].text.toString().trim(),
          epsDilTTM: tr[i].children[7].text.toString().trim(),
          epsDilGrowthYoY: tr[i].children[8].text.toString().trim(),
          dividendYield: tr[i].children[9].text.toString().trim(),
          sector: tr[i].children[10].text.toString().trim(),
        );
        stocks.add(tempStock);
      }
      fechStockLoading.value = false;
    } catch (e) {
      fechStockLoading.value = false;
    }
  }

//============================================================================//
  List<StockData> indices = [];
  Rx<Future<List<StockData>>> indicesFuture =
      Future<List<StockData>>(() => []).obs;

  Future<List<StockData>> fetchIndices(String url) async {
    try {
      indices = [];
      Uri dataLink = Uri.parse(url);
      final response = await http.get(dataLink);
      dom.Document html = dom.Document.html(response.body);
      var cell = html.getElementsByTagName("table")[0];
      var tr = cell.getElementsByTagName("tr");

      for (int i = 0; i < tr.length; i++) {
        StockData tempStock = StockData(
          image: i == 0 || tr[i].children[0].getElementsByTagName("img").isEmpty
              ? ""
              : tr[i]
                  .children[0]
                  .getElementsByTagName("img")
                  .first
                  .attributes["src"]
                  .toString(),
          url: i == 0 || tr[i].children[0].getElementsByTagName("a").isEmpty
              ? ""
              : tr[i]
                  .children[0]
                  .getElementsByTagName("a")
                  .first
                  .attributes["href"]
                  .toString(),
          shortName:
              i == 0 || tr[i].children[0].getElementsByTagName("a").isEmpty
                  ? ""
                  : tr[i]
                      .children[0]
                      .getElementsByTagName("a")
                      .first
                      .text
                      .toString()
                      .trim(),
          symbol: () {
            String shortName =
                i == 0 || tr[i].children[0].getElementsByTagName("a").isEmpty
                    ? ""
                    : tr[i]
                        .children[0]
                        .getElementsByTagName("a")
                        .first
                        .text
                        .toString()
                        .trim();
            String rawSymbol = tr[i].children[0].text.toString().trim();
            int charsToRemove = shortName.length;
            return rawSymbol.length >= charsToRemove
                ? rawSymbol.substring(charsToRemove).trim()
                : rawSymbol;
          }(),
          price: tr[i].children[1].text.toString().trim(),
          changePercent: tr[i].children[2].text.toString().trim(),
          volume: tr[i].children[3].text.toString().trim(),
          relativeVolume: tr[i].children[4].text.toString().trim(),
          marketCap: tr[i].children[5].text.toString().trim(),
          peRatio: "",
          epsDilTTM: "",
          epsDilGrowthYoY: "",
          dividendYield: "",
          sector: "",
        );
        indices.add(tempStock);
      }
      return indices;
    } catch (e) {
      rethrow;
    }
  }

  void loadIndices(String url) async {
    indicesFuture.value = fetchIndices(url);
    cachedbIndicesFuture = await indicesFuture.value;
    update();
  }

//============================================================================//
  List<StockData> futures = [];
  Rx<Future<List<StockData>>> futuresFuture =
      Future<List<StockData>>(() => []).obs;

  Future<List<StockData>> fetchFutures(String url) async {
    try {
      futures = [];
      Uri dataLink = Uri.parse(url);
      final response = await http.get(dataLink);
      dom.Document html = dom.Document.html(response.body);
      var cell = html.getElementsByTagName("table")[0];
      var tr = cell.getElementsByTagName("tr");

      for (int i = 0; i < tr.length; i++) {
        StockData tempStock = StockData(
          image: i == 0 || tr[i].children[0].getElementsByTagName("img").isEmpty
              ? ""
              : tr[i]
                  .children[0]
                  .getElementsByTagName("img")
                  .first
                  .attributes["src"]
                  .toString(),
          url: i == 0 || tr[i].children[0].getElementsByTagName("a").isEmpty
              ? ""
              : tr[i]
                  .children[0]
                  .getElementsByTagName("a")
                  .first
                  .attributes["href"]
                  .toString(),
          shortName:
              i == 0 || tr[i].children[0].getElementsByTagName("a").isEmpty
                  ? ""
                  : tr[i]
                      .children[0]
                      .getElementsByTagName("a")
                      .first
                      .text
                      .toString()
                      .trim(),
          symbol: () {
            String shortName =
                i == 0 || tr[i].children[0].getElementsByTagName("a").isEmpty
                    ? ""
                    : tr[i]
                        .children[0]
                        .getElementsByTagName("a")
                        .first
                        .text
                        .toString()
                        .trim();
            String rawSymbol = tr[i].children[0].text.toString().trim();
            int charsToRemove = shortName.length;
            return rawSymbol.length >= charsToRemove
                ? rawSymbol.substring(charsToRemove).trim()
                : rawSymbol;
          }(),
          price: tr[i].children[1].text.toString().trim(),
          changePercent: tr[i].children[2].text.toString().trim(),
          volume: tr[i].children[3].text.toString().trim(),
          relativeVolume: tr[i].children[4].text.toString().trim(),
          marketCap: tr[i].children[5].text.toString().trim(),
          peRatio: "",
          epsDilTTM: "",
          epsDilGrowthYoY: "",
          dividendYield: "",
          sector: "",
        );
        futures.add(tempStock);
      }
      return futures;
    } catch (e) {
      rethrow;
    }
  }

  void loadFutures(String url) async {
    futuresFuture.value = fetchFutures(url);
    cachedbfuturesFuture = await futuresFuture.value;
    update();
  }

//============================================================================//
  List<StockData> bonds = [];
  List<StockData> get getBonds => bonds;
  RxBool fechBondsLoading = false.obs;
  Future<void> fetchBonds(String url) async {
    try {
      fechBondsLoading.value = true;
      bonds = [];
      Uri dataLink = Uri.parse(url);
      final responce = await http.get(dataLink);
      dom.Document html = dom.Document.html(responce.body);
      var cell = html.getElementsByTagName("table")[0];
      var tr = cell.getElementsByTagName("tr");

      for (int i = 0; i < tr.length; i++) {
        StockData tempStock = StockData(
          image: i == 0 || tr[i].children[0].getElementsByTagName("img").isEmpty
              ? ""
              : tr[i]
                  .children[0]
                  .getElementsByTagName("img")
                  .first
                  .attributes["src"]
                  .toString(),
          shortName:
              i == 0 || tr[i].children[0].getElementsByTagName("a").isEmpty
                  ? ""
                  : tr[i]
                      .children[0]
                      .getElementsByTagName("a")
                      .first
                      .text
                      .toString()
                      .trim(),
          symbol: () {
            String shortName =
                i == 0 || tr[i].children[0].getElementsByTagName("a").isEmpty
                    ? ""
                    : tr[i]
                        .children[0]
                        .getElementsByTagName("a")
                        .first
                        .text
                        .toString()
                        .trim();
            String rawSymbol = tr[i].children[0].text.toString().trim();
            int charsToRemove = shortName.length;
            return rawSymbol.length >= charsToRemove
                ? rawSymbol.substring(charsToRemove).trim()
                : rawSymbol;
          }(),
          price: tr[i].children[1].text.toString().trim(),
          changePercent: tr[i].children[2].text.toString().trim(),
          volume: tr[i].children[3].text.toString().trim(),
          relativeVolume: tr[i].children[4].text.toString().trim(),
          marketCap: tr[i].children[5].text.toString().trim(),
          peRatio: tr[i].children[6].text.toString().trim(),
          epsDilTTM: tr[i].children[7].text.toString().trim(),
          // epsDilGrowthYoY: tr[i].children[8].text.toString().trim(),
          // dividendYield: tr[i].children[9].text.toString().trim(),
          //sector: tr[i].children[10].text.toString().trim(),
        );
        bonds.add(tempStock);
      }

      fechBondsLoading.value = false;
    } catch (e) {
      fechBondsLoading.value = false;
    }
  }
//============================================================================//

  List<StockData> etf = [];
  Rx<Future<List<StockData>>> etfFuture = Future<List<StockData>>(() => []).obs;
  Future<List<StockData>> fetchETF(String url) async {
    try {
      etf = [];
      Uri dataLink = Uri.parse(url);
      final response = await http.get(dataLink);
      dom.Document html = dom.Document.html(response.body);
      var cell = html.getElementsByTagName("table")[0];
      var tr = cell.getElementsByTagName("tr");

      for (int i = 0; i < tr.length; i++) {
        StockData tempStock = StockData(
          image: i == 0 || tr[i].children[0].getElementsByTagName("img").isEmpty
              ? ""
              : tr[i]
                  .children[0]
                  .getElementsByTagName("img")
                  .first
                  .attributes["src"]
                  .toString(),
          url: i == 0 || tr[i].children[0].getElementsByTagName("a").isEmpty
              ? ""
              : tr[i]
                  .children[0]
                  .getElementsByTagName("a")
                  .first
                  .attributes["href"]
                  .toString(),
          shortName:
              i == 0 || tr[i].children[0].getElementsByTagName("a").isEmpty
                  ? ""
                  : tr[i]
                      .children[0]
                      .getElementsByTagName("a")
                      .first
                      .text
                      .toString()
                      .trim(),
          symbol: () {
            String shortName =
                i == 0 || tr[i].children[0].getElementsByTagName("a").isEmpty
                    ? ""
                    : tr[i]
                        .children[0]
                        .getElementsByTagName("a")
                        .first
                        .text
                        .toString()
                        .trim();
            String rawSymbol = tr[i].children[0].text.toString().trim();
            int charsToRemove = shortName.length;
            return rawSymbol.length >= charsToRemove
                ? rawSymbol.substring(charsToRemove).trim()
                : rawSymbol;
          }(),
          price: tr[i].children[1].text.toString().trim(),
          changePercent: tr[i].children[2].text.toString().trim(),
          volume: tr[i].children[3].text.toString().trim(),
          relativeVolume: tr[i].children[4].text.toString().trim(),
          marketCap: tr[i].children[5].text.toString().trim(),
          peRatio: tr[i].children[6].text.toString().trim(),
          epsDilTTM: tr[i].children[7].text.toString().trim(),
          epsDilGrowthYoY: tr[i].children[8].text.toString().trim(),
          dividendYield: tr[i].children[9].text.toString().trim(),
          sector: "",
        );
        etf.add(tempStock);
      }
      return etf;
    } catch (e) {
      rethrow;
    }
  }

  void loadETF(String url) async {
    etfFuture.value = fetchETF(url);
    cachedbETFFuture = await etfFuture.value;
    update();
  }

  //============================================================================//
  List<StockData> forex = [];
  Rx<Future<List<StockData>>> forexFuture =
      Future<List<StockData>>(() => []).obs;
  Future<List<StockData>> fetchForex(String url) async {
    try {
      forex = [];
      Uri dataLink = Uri.parse(url);
      final response = await http.get(dataLink);
      dom.Document html = dom.Document.html(response.body);
      var cell = html.getElementsByTagName("table")[0];
      var tr = cell.getElementsByTagName("tr");

      for (int i = 0; i < tr.length; i++) {
        StockData tempStock = StockData(
          image: i == 0 || tr[i].children[0].getElementsByTagName("img").isEmpty
              ? ""
              : tr[i]
                  .children[0]
                  .getElementsByTagName("img")
                  .first
                  .attributes["src"]
                  .toString(),
          url: i == 0 || tr[i].children[0].getElementsByTagName("a").isEmpty
              ? ""
              : tr[i]
                  .children[0]
                  .getElementsByTagName("a")
                  .first
                  .attributes["href"]
                  .toString(),
          shortName:
              i == 0 || tr[i].children[0].getElementsByTagName("a").isEmpty
                  ? ""
                  : tr[i]
                      .children[0]
                      .getElementsByTagName("a")
                      .first
                      .text
                      .toString()
                      .trim(),
          symbol: () {
            String shortName =
                i == 0 || tr[i].children[0].getElementsByTagName("a").isEmpty
                    ? ""
                    : tr[i]
                        .children[0]
                        .getElementsByTagName("a")
                        .first
                        .text
                        .toString()
                        .trim();
            String rawSymbol = tr[i].children[0].text.toString().trim();
            int charsToRemove = shortName.length;
            return rawSymbol.length >= charsToRemove
                ? rawSymbol.substring(charsToRemove).trim()
                : rawSymbol;
          }(),
          price: tr[i].children[1].text.toString().trim(),
          changePercent: tr[i].children[2].text.toString().trim(),
          volume: tr[i].children[3].text.toString().trim(),
          relativeVolume: tr[i].children[4].text.toString().trim(),
          marketCap: tr[i].children[5].text.toString().trim(),
          peRatio: tr[i].children[6].text.toString().trim(),
          epsDilTTM: tr[i].children[7].text.toString().trim(),
          // epsDilGrowthYoY: tr[i].children[8].text.toString().trim(),
          // dividendYield: tr[i].children[9].text.toString().trim(),
          // sector: "",
        );
        forex.add(tempStock);
      }
      return forex;
    } catch (e) {
      rethrow;
    }
  }

  void loadForex(String url) async {
    forexFuture.value = fetchForex(url);
    cachedbForexFuture = await forexFuture.value;
    update();
  }

  //============================================================================//

  List<StockData> economy = [];
  Rx<Future<List<StockData>>> economyFuture =
      Future<List<StockData>>(() => []).obs;
  Future<List<StockData>> fetchEconomy(String url) async {
    try {
      economy = [];
      Uri dataLink = Uri.parse(url);
      final response = await http.get(dataLink);
      dom.Document html = dom.Document.html(response.body);
      var cell = html.getElementsByTagName("table")[0];
      var tr = cell.getElementsByTagName("tr");

      for (int i = 0; i < tr.length; i++) {
        StockData tempStock = StockData(
          image: i == 0 || tr[i].children[0].getElementsByTagName("img").isEmpty
              ? ""
              : tr[i]
                  .children[0]
                  .getElementsByTagName("img")
                  .first
                  .attributes["src"]
                  .toString(),
          url: i == 0 || tr[i].children[0].getElementsByTagName("a").isEmpty
              ? ""
              : tr[i]
                  .children[0]
                  .getElementsByTagName("a")
                  .first
                  .attributes["href"]
                  .toString(),
          shortName:
              i == 0 || tr[i].children[0].getElementsByTagName("a").isEmpty
                  ? ""
                  : tr[i]
                      .children[0]
                      .getElementsByTagName("a")
                      .first
                      .text
                      .toString()
                      .trim(),
          symbol: () {
            String shortName =
                i == 0 || tr[i].children[0].getElementsByTagName("a").isEmpty
                    ? ""
                    : tr[i]
                        .children[0]
                        .getElementsByTagName("a")
                        .first
                        .text
                        .toString()
                        .trim();
            String rawSymbol = tr[i].children[0].text.toString().trim();
            int charsToRemove = shortName.length;
            return rawSymbol.length >= charsToRemove
                ? rawSymbol.substring(charsToRemove).trim()
                : rawSymbol;
          }(),
          price: tr[i].children[1].text.toString().trim(),
          changePercent: tr[i].children[2].text.toString().trim(),
          volume: tr[i].children[3].text.toString().trim(),
          relativeVolume: tr[i].children[4].text.toString().trim(),
          // marketCap: tr[i].children[5].text.toString().trim(),
          // peRatio: tr[i].children[6].text.toString().trim(),
          // epsDilTTM: tr[i].children[7].text.toString().trim(),
        );
        economy.add(tempStock);
      }
      return economy;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  void loadEconomy(String url) async {
    economyFuture.value = fetchEconomy(url);
    update();
  }
}
