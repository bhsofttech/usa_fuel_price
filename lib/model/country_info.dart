// To parse this JSON data, do
//
//     final countryInfo = countryInfoFromJson(jsonString);

import 'dart:convert';

List<CountryInfo> countryInfoFromJson(String str) => List<CountryInfo>.from(
    json.decode(str).map((x) => CountryInfo.fromJson(x)));

String countryInfoToJson(List<CountryInfo> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CountryInfo {
  String link;
  String country;
  String image;

  CountryInfo({this.link = "", this.country = "", this.image = ""});

  factory CountryInfo.fromJson(Map<String, dynamic> json) => CountryInfo(
        link: json["link"] ?? "",
        country: json["country"] ?? "",
        image: json["image"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "link": link,
        "country": country,
        "image": image,
      };
}
