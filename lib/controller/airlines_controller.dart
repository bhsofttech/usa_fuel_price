import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:usa_gas_price/model/fligh_depart_info.dart';
import 'package:usa_gas_price/model/flight_models.dart';

class AirlinesController extends GetxController {
  List<FlightInfo> flights = [];
  RxBool isLoading = false.obs;
  List<FlightInfo> get getFlights => flights;

  // Cache for IATA codes
  List<Map<String, dynamic>>? _iataCodes;

  // Load IATA codes from JSON file
  Future<List<Map<String, dynamic>>> _loadIataCodes() async {
    if (_iataCodes != null) {
      return _iataCodes!;
    }

    try {
      final String response = await rootBundle.loadString(
        'lib/data/iata_code.json',
      );
      final List<dynamic> data = json.decode(response);
      _iataCodes = data.cast<Map<String, dynamic>>();
      return _iataCodes!;
    } catch (e) {
      print("Error loading IATA codes: $e");
      return [];
    }
  }

  // Get IATA code by airline name
  Future<String> getIataCodeByAirlineName(String airlineName) async {
    final iataCodes = await _loadIataCodes();

    // Try exact match first
    for (var entry in iataCodes) {
      final entryName = entry["Airline Name"]?.toString().trim() ?? "";
      if (entryName.toLowerCase() == airlineName.toLowerCase()) {
        return entry["IATA"]?.toString() ?? "";
      }
    }

    // Try partial match (contains)
    for (var entry in iataCodes) {
      final entryName = entry["Airline Name"]?.toString().trim() ?? "";
      if (entryName.toLowerCase().contains(airlineName.toLowerCase()) ||
          airlineName.toLowerCase().contains(entryName.toLowerCase())) {
        return entry["IATA"]?.toString() ?? "";
      }
    }

    return "";
  }

  Future<void> fetchFlights({required String url}) async {
    isLoading.value = true;
    try {
      flights = [];
      print("URL: $url");
      Uri dataLink = Uri.parse(url);
      final responce = await http.get(dataLink);
      dom.Document html = dom.Document.html(responce.body);
      var table = html.getElementsByClassName("j9Jl-item j9Jl-row");

      for (int i = 0; i < table.length; i++) {
        FlightInfo info = FlightInfo(
          airlineName: table[i].children[0].text.toString().split(",").first,
          logoUrl: table[i].children[0].getElementsByTagName("img").toString(),

          flightNumber: table[i].children[0].text.toString().split(",").last,
          originCode: table[i].children[1].children[0].text
              .toString()
              .split(" → ")
              .first,
          destinationCode: table[i].children[1].children[0].text
              .toString()
              .split(" → ")
              .last,
          departureAt: table[i].children[1].children[1].text
              .toString()
              .split("→")
              .first,
          arrivalAt: table[i].children[1].children[1].text
              .toString()
              .split("→")
              .last,
        );

        flights.add(info);
      }
      if (flights.isNotEmpty) {
        debugPrint("Fetched ${flights.length} flights");
        debugPrint(flights.first.toJson().toString());
        isLoading.value = false;
      } else {
        debugPrint("No flights found");
      }
      isLoading.value = false;
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  //==========================================================================//
  Rx<DepartureModel> departure = DepartureModel().obs;
  Rx<ArrivalModel> arrival = ArrivalModel().obs;
  RxBool isDetailLoading = false.obs;
  Future<void> flightDetails({
    required String flightNumber,
    required String airLianceName,
    required String date,
  }) async {
    isDetailLoading.value = true;
    try {
      departure.value = DepartureModel();
      arrival.value = ArrivalModel();
      // Get IATA code from JSON file based on airline name
      String iataCode = await getIataCodeByAirlineName(airLianceName);

      if (iataCode.isEmpty) {
        return;
      }

      Uri dataLink = Uri.parse(
        "https://www.kayak.com/tracker/$iataCode-$flightNumber/$date",
      );
      final responce = await http.get(dataLink);
      dom.Document html = dom.Document.html(responce.body);
      //tqcb-details
      var table1 = html.getElementsByClassName("tqcb-details");

      DepartureModel departureModel = DepartureModel(
        airportName: table1[0].children[1].children[1].text,
        departureDate: table1[0].children[2].children[1].text,
        scheduledDeparture: table1[0].children[3].children[1].text,
        actualDeparture: table1[0].children[4].children[1].text,
        terminal: table1[0].children[5].children[1].text,
        gate: table1[0].children[6].children[1].text,
      );
      departure.value = departureModel;
      debugPrint(departureModel.toJson().toString());

      ArrivalModel arrivalModel = ArrivalModel(
        airportName: table1[1].children[1].children[1].text,
        arrivalDate: table1[1].children[2].children[1].text,
        scheduledArrival: table1[1].children[3].children[1].text,
        estimatedArrival: table1[1].children[4].children[1].text,
        terminal: table1[1].children[5].children[1].text,
        gate: table1[1].children[6].children[1].text,
      );

      arrival.value = arrivalModel;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> getFlightDetailsFromMap() async {
    Uri dataLink = Uri.parse("https://www.flightaware.com/live/flight/FDX6030");
    final responce = await http.get(dataLink);
    dom.Document html = dom.Document.html(responce.body);
    var table = html.getElementsByClassName("flightPageSummary ");

    print(table.length);
  }
}
