class AstronomyData {
  final String cityName;
  final String sunrise;
  final String sunset;

  AstronomyData({
    required this.cityName,
    required this.sunrise,
    required this.sunset,
  });

  factory AstronomyData.fromMap(Map<String, String> map) {
    return AstronomyData(
      cityName: map['cityName'] ?? '',
      sunrise: map['sunrise'] ?? '',
      sunset: map['sunset'] ?? '',
    );
  }

  Map<String, String> toMap() {
    return {
      'cityName': cityName,
      'sunrise': sunrise,
      'sunset': sunset,
    };
  }
}
