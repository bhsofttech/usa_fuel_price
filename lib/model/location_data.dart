class LocationData {
  final String cityName;
  final String currentTime;

  LocationData({
    required this.cityName,
    required this.currentTime,
  });

  factory LocationData.fromMap(Map<String, String> map) {
    return LocationData(
      cityName: map['cityName'] ?? '',
      currentTime: map['currentTime'] ?? '',
    );
  }

  Map<String, String> toMap() {
    return {
      'cityName': cityName,
      'currentTime': currentTime,
    };
  }
}
