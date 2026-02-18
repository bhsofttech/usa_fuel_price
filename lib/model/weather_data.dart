class WeatherData {
  final String cityName;
  final String time;
  final String weatherIcon;
  final String weatherDescription;
  final String temperature;

  WeatherData({
    required this.cityName,
    required this.time,
    required this.weatherIcon,
    required this.weatherDescription,
    required this.temperature,
  });

  factory WeatherData.fromMap(Map<String, String> map) {
    return WeatherData(
      cityName: map['cityName'] ?? '',
      time: map['time'] ?? '',
      weatherIcon: map['weatherIcon'] ?? '',
      weatherDescription: map['weatherDescription'] ?? '',
      temperature: map['temperature'] ?? '',
    );
  }

  Map<String, String> toMap() {
    return {
      'cityName': cityName,
      'time': time,
      'weatherIcon': weatherIcon,
      'weatherDescription': weatherDescription,
      'temperature': temperature,
    };
  }
}
