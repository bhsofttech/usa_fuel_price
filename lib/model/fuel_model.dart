// To parse this JSON data, do
//
//     final fuelInfo = fuelInfoFromJson(jsonString);

import 'dart:convert';

List<EUFuelInfo> fuelInfoFromJson(String str) =>
    List<EUFuelInfo>.from(json.decode(str).map((x) => EUFuelInfo.fromJson(x)));

String fuelInfoToJson(List<EUFuelInfo> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EUFuelInfo {
  String country;
  String flag;
  String gasoline;
  String diesel;
  String lpg;

  EUFuelInfo(
      {this.country = "",
      this.flag = "",
      this.gasoline = "",
      this.lpg = "",
      this.diesel = "",});

  factory EUFuelInfo.fromJson(Map<String, dynamic> json) => EUFuelInfo(
      country: json["country"] ?? "",
      flag: json["flag"] ?? "",
      gasoline: json["gasoline"] ?? "",
      lpg: json["lpg"]??"",
      diesel: json["diesel"] ?? '');

  Map<String, dynamic> toJson() => {
        "country": country,
        "flag": flag,
        "gasolinePrice": gasoline,
        "diesel": diesel,
        "lpg" : lpg
        
      };
}
