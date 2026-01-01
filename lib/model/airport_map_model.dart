// To parse this JSON data for map screen
//
//     final airportMap = airportMapFromJson(jsonString);

import 'dart:convert';

List<AirportMap> airportMapListFromJson(String str) =>
    List<AirportMap>.from(json.decode(str).map((x) => AirportMap.fromJson(x)));

String airportMapListToJson(List<AirportMap> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AirportMap {
  String iata;
  String icao;
  String time;
  String countryCode;
  String continent;
  String airport;
  double latitude;
  double longitude;
  int elevationFt;
  String type;
  String scheduledService;
  String wikipedia;
  String website;
  int runwayLength;
  String flightradar24Url;
  String radarboxUrl;
  String flightawareUrl;

  AirportMap({
    this.iata = "",
    this.icao = "",
    this.time = "",
    this.countryCode = "",
    this.continent = "",
    this.airport = "",
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.elevationFt = 0,
    this.type = "",
    this.scheduledService = "",
    this.wikipedia = "",
    this.website = "",
    this.runwayLength = 0,
    this.flightradar24Url = "",
    this.radarboxUrl = "",
    this.flightawareUrl = "",
  });

  factory AirportMap.fromJson(Map<String, dynamic> json) => AirportMap(
    iata: json["iata"] ?? "",
    icao: _parseStringValue(json["icao"]),
    time: json["time"] ?? "",
    countryCode: json["country_code"] ?? "",
    continent: json["continent"] ?? "",
    airport: json["airport"] ?? "",
    latitude: (json["latitude"] ?? 0.0).toDouble(),
    longitude: (json["longitude"] ?? 0.0).toDouble(),
    elevationFt: _parseIntValue(json["elevation_ft"]),
    type: json["type"] ?? "",
    scheduledService: json["scheduled_service"] ?? "",
    wikipedia: json["wikipedia"] ?? "",
    website: json["website"] ?? "",
    runwayLength: _parseIntValue(json["runway_length"]),
    flightradar24Url: json["flightradar24_url"] ?? "",
    radarboxUrl: json["radarbox_url"] ?? "",
    flightawareUrl: json["flightaware_url"] ?? "",
  );

  static String _parseStringValue(dynamic value) {
    if (value == null) return "";
    if (value is String) return value;
    return value.toString();
  }

  static int _parseIntValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      if (value.isEmpty) return 0;
      return int.tryParse(value) ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
  }

  Map<String, dynamic> toJson() => {
    "iata": iata,
    "icao": icao,
    "time": time,
    "country_code": countryCode,
    "continent": continent,
    "airport": airport,
    "latitude": latitude,
    "longitude": longitude,
    "elevation_ft": elevationFt,
    "type": type,
    "scheduled_service": scheduledService,
    "wikipedia": wikipedia,
    "website": website,
    "runway_length": runwayLength,
    "flightradar24_url": flightradar24Url,
    "radarbox_url": radarboxUrl,
    "flightaware_url": flightawareUrl,
  };
}
