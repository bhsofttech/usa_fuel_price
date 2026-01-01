// To parse this JSON data, do
//
//     final flightInfo = flightInfoFromJson(jsonString);

import 'dart:convert';

FlightInfo flightInfoFromJson(String str) =>
    FlightInfo.fromJson(json.decode(str));

String flightInfoToJson(FlightInfo data) => json.encode(data.toJson());

class FlightInfo {
  String airlineName;
  String flightNumber;
  String logoUrl;
  String originCode;
  String destinationCode;
  String departureAt;
  String arrivalAt;

  FlightInfo({
    this.airlineName = "",
    this.flightNumber = "",
    this.logoUrl = "",
    this.originCode = "",
    this.destinationCode = "",


    this.departureAt = "",
    this.arrivalAt = "",
  });

  factory FlightInfo.fromJson(Map<String, dynamic> json) => FlightInfo(
    airlineName: json["airlineName"] ?? "",
    flightNumber: json["flightNumber"] ?? "",
    logoUrl: json["logoUrl"] ?? "",
    originCode: json["originCode"] ?? "",
    destinationCode: json["destinationCode"] ?? "",


    departureAt: json["departureAt"] ?? "",
    arrivalAt: json["arrivalAt"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "airlineName": airlineName,
    "flightNumber": flightNumber,
    "logoUrl": logoUrl,
    "originCode": originCode,
    "destinationCode": destinationCode,
    "departureAt": departureAt,
    "arrivalAt": arrivalAt,
  };
}
