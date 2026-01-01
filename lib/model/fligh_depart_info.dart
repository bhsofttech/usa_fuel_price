// To parse this JSON data, do
//
//     final departureModel = departureModelFromJson(jsonString);

import 'dart:convert';

DepartureModel departureModelFromJson(String str) =>
    DepartureModel.fromJson(json.decode(str));

String departureModelToJson(DepartureModel data) => json.encode(data.toJson());

class DepartureModel {
  String airportName;
  String departureDate;
  String scheduledDeparture;
  String actualDeparture;
  String terminal;
  String gate;

  DepartureModel({
    this.airportName = "",
    this.departureDate = "",
    this.scheduledDeparture = "",
    this.actualDeparture = "",
    this.terminal = "",
    this.gate = "",
  });

  factory DepartureModel.fromJson(Map<String, dynamic> json) => DepartureModel(
    airportName: json["airportName"] ?? "",
    departureDate: json["departureDate"] ?? "",
    scheduledDeparture: json["scheduledDeparture"] ?? "",
    actualDeparture: json["actualDeparture"] ?? "",
    terminal: json["terminal"] ?? "",
    gate: json["gate"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "airportName": airportName,
    "departureDate": departureDate,
    "scheduledDeparture": scheduledDeparture,
    "actualDeparture": actualDeparture,
    "terminal": terminal,
    "gate": gate,
  };
}

ArrivalModel arrivalModelFromJson(String str) =>
    ArrivalModel.fromJson(json.decode(str));

String arrivalModelToJson(ArrivalModel data) => json.encode(data.toJson());

class ArrivalModel {
  String airportName;
  String arrivalDate;
  String scheduledArrival;
  String estimatedArrival;
  String terminal;
  String gate;

  ArrivalModel({
    this.airportName = "",
    this.arrivalDate = "",
    this.scheduledArrival = "",
    this.estimatedArrival = "",
    this.terminal = "",
    this.gate = "",
  });

  factory ArrivalModel.fromJson(Map<String, dynamic> json) => ArrivalModel(
    airportName: json["airportName"] ?? "",
    arrivalDate: json["arrivalDate"] ?? "",
    scheduledArrival: json["scheduledArrival"] ?? "",
    estimatedArrival: json["estimatedArrival"] ?? "",
    terminal: json["terminal"] ?? "",
    gate: json["gate"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "airportName": airportName,
    "arrivalDate": arrivalDate,
    "scheduledArrival": scheduledArrival,
    "estimatedArrival": estimatedArrival,
    "terminal": terminal,
    "gate": gate,
  };
}
