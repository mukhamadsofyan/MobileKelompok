class FetchRecord {
  final String endpoint;
  final int lastMs;
  final int averageMs;
  final String mode; // HTTP / DIO

  FetchRecord({
    required this.endpoint,
    required this.lastMs,
    required this.averageMs,
    required this.mode,
  });
}
