import 'dart:async';
import '../models/device_data.dart';
import '../models/fall_event.dart';

abstract class DeviceRepository {
  Stream<DeviceData> get deviceStream;
  Future<List<FallEvent>> getFallHistory();
}
