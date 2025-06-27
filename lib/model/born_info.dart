// To parse this JSON data, do
//
//     final todaysBorn = todaysBornFromJson(jsonString);

import 'dart:convert';

List<TodaysBorn> todaysBornFromJson(String str) =>
    List<TodaysBorn>.from(json.decode(str).map((x) => TodaysBorn.fromJson(x)));

String todaysBornToJson(List<TodaysBorn> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TodaysBorn {
  String name;
  String date;
  String type;
  String image;
  String flagLink;
  String country;

  TodaysBorn({
    this.name = "",
    this.date = "",
    this.type = "",
    this.image = "",
    this.flagLink = "",
    this.country = "",
  });

  factory TodaysBorn.fromJson(Map<String, dynamic> json) => TodaysBorn(
        name: json["name"] ?? "",
        date: json["date"] ?? "",
        type: json["type"] ?? "",
        image: json["image"] ?? "",
        flagLink: json["flag_link"] ?? "",
        country: json["country"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "date": date,
        "type": type,
        "image": image,
        "flag_link": flagLink,
        "country": country,
      };
}
