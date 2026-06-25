class FallEvent {
  final String id;
  final DateTime timestamp;
  final double lat;
  final double lng;
  final int batteryAtEvent;

  const FallEvent({
    required this.id,
    required this.timestamp,
    required this.lat,
    required this.lng,
    required this.batteryAtEvent,
  });

  /// Factory để tạo FallEvent từ Firestore document
  factory FallEvent.fromFirestore(String docId, Map<String, dynamic> data) {
    final ts = (data['timestamp'] as num?)?.toInt() ?? 0;
    return FallEvent(
      id: docId,
      timestamp: DateTime.fromMillisecondsSinceEpoch(ts * 1000),
      lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0.0,
      batteryAtEvent: (data['battery_at_event'] as num?)?.toInt() ?? 0,
    );
  }
}

