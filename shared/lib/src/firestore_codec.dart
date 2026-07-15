/// Firestore's Dart SDK returns `Timestamp` objects (with a `.toDate()`
/// method) when reading date fields, but this package stays free of a
/// `cloud_firestore` dependency so it can be used from tooling that isn't
/// Flutter. Ducktyping `.toDate()` here avoids that dependency while still
/// round-tripping real Firestore documents correctly. Writes don't need
/// the reverse direction — Firestore's SDK accepts a plain [DateTime]
/// directly and converts it to a Timestamp on write.
DateTime parseTimestamp(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.parse(value);
  if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
  final dynamic v = value;
  return v.toDate() as DateTime;
}

DateTime? parseTimestampOrNull(dynamic value) {
  if (value == null) return null;
  return parseTimestamp(value);
}
