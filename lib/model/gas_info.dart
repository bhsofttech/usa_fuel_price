// To parse this JSON data, do
//
//     final gasinfo = gasinfoFromJson(jsonString);

import 'dart:convert';

List<Gasinfo> gasinfoFromJson(String str) =>
    List<Gasinfo>.from(json.decode(str).map((x) => Gasinfo.fromJson(x)));

String gasinfoToJson(List<Gasinfo> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Gasinfo {
  String city;
  String regular;
  String midGrade;
  String premium;
  String diesel;
  String link;

  Gasinfo({
    this.city = "",
    this.regular = "",
    this.midGrade = "",
    this.premium = "",
    this.diesel = "",
    this.link = "",
  });

  factory Gasinfo.fromJson(Map<String, dynamic> json) => Gasinfo(
      city: json["city"] ?? '',
      regular: json["regular"] ?? '',
      midGrade: json["mid_grade"] ?? '',
      premium: json["premium"] ?? '',
      diesel: json["diesel"] ?? '',
      link: json["link"] ?? "");

  Map<String, dynamic> toJson() => {
        "city": city,
        "regular": regular,
        "mid_grade": midGrade,
        "premium": premium,
        "diesel": diesel,
        "link": link
      };
}
