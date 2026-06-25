enum DeviceStatus { online, offline, fall }

class DeviceData {
  final String deviceId;
  final int timestamp;
  final bool fallDetected;
  final double lat;
  final double lng;
  final double gpsAccuracy;
  final int batteryPct;
  final int rssi;

  const DeviceData({
    required this.deviceId,
    required this.timestamp,
    required this.fallDetected,
    required this.lat,
    required this.lng,
    required this.gpsAccuracy,
    required this.batteryPct,
    required this.rssi,
  });

  /// Factory để tạo DeviceData từ Firestore document
  factory DeviceData.fromFirestore(Map<String, dynamic> data) {
    return DeviceData(
      deviceId: data['device_id'] as String? ?? 'ESP32_FALL_001',
      timestamp: (data['timestamp'] as num?)?.toInt() ??
          (DateTime.now().millisecondsSinceEpoch ~/ 1000),
      fallDetected: data['fall_detected'] as bool? ?? false,
      lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0.0,
      gpsAccuracy: (data['gps_accuracy'] as num?)?.toDouble() ?? 0.0,
      batteryPct: (data['battery_pct'] as num?)?.toInt() ?? 0,
      rssi: (data['rssi'] as num?)?.toInt() ?? 0,
    );
  }

  DeviceStatus get status {
    final age = DateTime.now().millisecondsSinceEpoch ~/ 1000 - timestamp;
    if (age > 60) return DeviceStatus.offline;
    if (fallDetected) return DeviceStatus.fall;
    return DeviceStatus.online;
  }
}

