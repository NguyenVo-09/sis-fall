import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/device_data.dart';
import '../models/fall_event.dart';

import 'device_repository.dart';

/// Repository kết nối thực tế với Cloud Firestore.
/// Lắng nghe real-time document /devices/ESP32_FALL_001
/// và đọc lịch sử từ collection /fall_events.
class FirebaseDeviceRepository implements DeviceRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _deviceId = 'ESP32_FALL_001';

  @override
  Stream<DeviceData> get deviceStream {
    return _db
        .collection('devices')
        .doc(_deviceId)
        .snapshots()
        .map((snap) {
          if (!snap.exists || snap.data() == null) {
            // Nếu Firebase chưa có dữ liệu (ESP32 chưa gửi bao giờ), 
            // trả về trạng thái offline mặc định
            return const DeviceData(
              deviceId: _deviceId,
              timestamp: 0,
              fallDetected: false,
              lat: 0.0,
              lng: 0.0,
              gpsAccuracy: 0.0,
              batteryPct: 0,
              rssi: 0,
            );
          }
          return DeviceData.fromFirestore(snap.data()!);
        });
  }

  @override
  Future<List<FallEvent>> getFallHistory() async {
    try {
      final snap = await _db
          .collection('fall_events')
          .where('device_id', isEqualTo: _deviceId)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();
      return snap.docs
          .map((doc) => FallEvent.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
