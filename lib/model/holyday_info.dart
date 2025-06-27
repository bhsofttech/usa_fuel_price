// To parse this JSON data, do
//
//     final holidayInfo = holidayInfoFromJson(jsonString);

import 'dart:convert';

List<HolidayInfo> holidayInfoFromJson(String str) => List<HolidayInfo>.from(
    json.decode(str).map((x) => HolidayInfo.fromJson(x)));

String holidayInfoToJson(List<HolidayInfo> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class HolidayInfo {
  String day;
  String date;
  String name;
  String type;
  String comment;

  HolidayInfo({
    this.day = "",
    this.date = "",
    this.name = "",
    this.type = "",
    this.comment = "",
  });

  factory HolidayInfo.fromJson(Map<String, dynamic> json) => HolidayInfo(
        day: json["day"] ?? "",
        date: json["date"] ?? "",
        name: json["name"] ?? "",
        type: json["type"] ?? "",
        comment: json["comment"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "day": day,
        "date": date,
        "name": name,
        "type": type,
        "comment": comment,
      };
}
