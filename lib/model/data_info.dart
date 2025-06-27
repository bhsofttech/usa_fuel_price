// To parse this JSON data, do
//
//     final dataInfo = dataInfoFromJson(jsonString);

import 'dart:convert';

List<DataInfo> dataInfoFromJson(String str) =>
    List<DataInfo>.from(json.decode(str).map((x) => DataInfo.fromJson(x)));

String dataInfoToJson(List<DataInfo> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DataInfo {
  String one;
  String two;
  String three;
  String four;
  String five;
  String six;

  DataInfo({
    this.one = "",
    this.two = "",
    this.three = "",
    this.four = "",
    this.five = "",
    this.six = "",
  });

  factory DataInfo.fromJson(Map<String, dynamic> json) => DataInfo(
        one: json["one"] ?? "",
        two: json["two"] ?? "",
        three: json["three"] ?? "",
        four: json["four"] ?? "",
        five: json["five"] ?? "",
        six: json["six"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "one": one,
        "two": two,
        "three": three,
        "four": four,
        "five": five,
        "six": six,
      };
}
