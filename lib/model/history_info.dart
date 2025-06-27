// To parse this JSON data, do
//
//     final historyInfo = historyInfoFromJson(jsonString);

import 'dart:convert';

List<HistoryInfo> historyInfoFromJson(String str) => List<HistoryInfo>.from(
    json.decode(str).map((x) => HistoryInfo.fromJson(x)));

String historyInfoToJson(List<HistoryInfo> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class HistoryInfo {
  String title;
  String subTitle;

  HistoryInfo({
    this.title = "",
    this.subTitle = "",
  });

  factory HistoryInfo.fromJson(Map<String, dynamic> json) => HistoryInfo(
        title: json["title"] ?? "",
        subTitle: json["sub_title"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "sub_title": subTitle,
      };
}
