class LocationLog {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;
  final double? distanceFromPrev; // meter (nullable untuk row pertama)
  final String mode; // "GPS" atau "Network"

  LocationLog({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
    required this.mode,
    this.distanceFromPrev,
  });
}
