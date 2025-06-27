// To parse this JSON data, do
//
//     final timeinfo = timeinfoFromJson(jsonString);

import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';

List<Timeinfo> timeinfoFromJson(String str) =>
    List<Timeinfo>.from(json.decode(str).map((x) => Timeinfo.fromJson(x)));

String timeinfoToJson(List<Timeinfo> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Timeinfo {
  String city;
  String time;
  String country;
  DateTime? dateTime;
  DateTime? timerCurrentTime;
  Timer? timer;
  bool isFavourit;

  Timeinfo({
    this.city = "",
    this.time = "",
    this.country = "",
    this.timerCurrentTime,
    this.dateTime,
    this.timer,
    this.isFavourit = false,
  });

  factory Timeinfo.fromJson(Map<String, dynamic> json) => Timeinfo(
        city: json["city"],
        time: json["time"],
        country: json["country"],
        //dateTime: DateTime.parse(json["date-time"]),
        // timerCurrentTime: DateTime.parse(json["current_time"]),
        // timer: json["timer"],
      );

  Map<String, dynamic> toJson() => {
        "city": city,
        "time": time,
        "country": country,
        // "date-time": dateTime?.toIso8601String(),
        //// "current_time": timerCurrentTime?.toIso8601String(),
        "timer": timer
      };
}
