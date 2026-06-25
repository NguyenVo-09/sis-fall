import 'package:flutter_bloc/flutter_bloc.dart';
import 'device_state.dart';
import '../../../services/device_repository.dart';
import '../../../models/device_data.dart';
// import 'package:flutter/services.dart'; // Uncomment when using HapticFeedback

class DeviceCubit extends Cubit<DeviceState> {
  final DeviceRepository _repo;

  DeviceCubit(this._repo) : super(DeviceState.loading()) {
    _repo.deviceStream.listen((data) {
      emit(state.copyWith(
        status: DeviceFetchStatus.success,
        deviceData: data,
      ));
      
      if (data.fallDetected && !state.activeFallAlert) {
        _triggerFallAlert(data);
      }
    });
  }

  void _triggerFallAlert(DeviceData data) {
    // HapticFeedback.vibrate();
    emit(state.copyWith(activeFallAlert: true));
  }

  void dismissAlert() {
    emit(state.copyWith(activeFallAlert: false));
  }
}
