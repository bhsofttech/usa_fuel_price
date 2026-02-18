class AppRegion {
  final String name;
  final List<AppLocation> locations;

  AppRegion({
    required this.name,
    required this.locations,
  });
}

class AppLocation {
  final String name; // Display name e.g. "New York"
  final String timezoneId; // IANA ID e.g. "America/New_York"

  AppLocation({
    required this.name,
    required this.timezoneId,
  });

  @override
  String toString() => name;
}
