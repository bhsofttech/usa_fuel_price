// To parse this JSON data, do
//
//     final timeinfo = timeinfoFromJson(jsonString);


class WeatherInfo {
  String city;
  String time;
  String country;
  String temp;
  String image;

  WeatherInfo({
    this.city = "",
    this.time = "",
    this.country = "",
    this.temp = "",
    this.image = "",
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) => WeatherInfo(
      city: json["city"],
      time: json["time"],
      country: json["country"],
      temp: json["temp"],
      image: json["image"]);

  Map<String, dynamic> toJson() => {
        "city": city,
        "time": time,
        "country": country,
        "temp": temp,
        "image": image
      };
}
