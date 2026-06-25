import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/device_cubit.dart';
import '../cubit/device_state.dart';
import '../widgets/device_status_card.dart';
import '../widgets/fall_alert_banner.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  void _showFallDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 32),
                const SizedBox(width: 12),
                Text('TÉ NGÃ PHÁT HIỆN', style: AppTypography.display.copyWith(color: AppColors.danger)),
              ],
            ),
            const SizedBox(height: 24),
            Text('Vui lòng kiểm tra ứng dụng Bản Đồ để biết vị trí chi tiết.', style: AppTypography.body),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<DeviceCubit>().dismissAlert();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Đã hiểu & Đóng cảnh báo', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceCubit, DeviceState>(
      builder: (context, state) {
        final device = state.deviceData;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Fall Detection 🔔'),
          ),
          body: Column(
            children: [
              FallAlertBanner(
                isVisible: state.activeFallAlert,
                deviceData: device,
                onViewDetails: () => _showFallDetails(context),
              ),
              Expanded(
                child: state.status == DeviceFetchStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : device == null
                        ? const Center(child: Text('Không có dữ liệu'))
                        : RefreshIndicator(
                            onRefresh: () async {},
                            child: ListView(
                              padding: const EdgeInsets.all(16.0),
                              children: [
                                DeviceStatusCard(device: device),
                                const SizedBox(height: 16),
                                _buildQuickInfoRow(device),
                                const SizedBox(height: 16),
                                _buildMiniMapPlaceholder(),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickInfoRow(device) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('VỊ TRÍ ESP32', style: AppTypography.caption),
                  const SizedBox(height: 8),
                  Text('${device.lat}°N', style: AppTypography.data),
                  Text('${device.lng}°E', style: AppTypography.data),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TÉ NGÃ HÔM NAY', style: AppTypography.caption),
                  const SizedBox(height: 8),
                  Text('2 lần', style: AppTypography.heading),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniMapPlaceholder() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('📍 BẢN ĐỒ NHANH', style: AppTypography.heading),
          ),
          Container(
            height: 200,
            color: AppColors.border,
            child: const Center(
              child: Text('Map Placeholder\n(See Map Tab)'),
            ),
          ),
        ],
      ),
    );
  }
}
