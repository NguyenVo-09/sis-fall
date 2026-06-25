import 'package:flutter/material.dart';
import '../../../models/device_data.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/status_badge.dart';
import 'battery_indicator.dart';

class DeviceStatusCard extends StatelessWidget {
  final DeviceData device;

  const DeviceStatusCard({Key? key, required this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isFall = device.status == DeviceStatus.fall;
    final isOffline = device.status == DeviceStatus.offline;

    return Card(
      color: isOffline ? AppColors.surfaceCard.withOpacity(0.7) : AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isFall ? AppColors.danger : AppColors.border,
          width: isFall ? 2 : 1,
        ),
      ),
      elevation: isFall ? 4 : 0,
      shadowColor: isFall ? AppColors.danger.withOpacity(0.3) : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StatusBadge(status: device.status),
                const Spacer(),
                BatteryIndicator(percent: device.batteryPct),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              device.deviceId,
              style: AppTypography.heading,
            ),
            const SizedBox(height: 4),
            Text(
              'Cập nhật: ${DateFormatter.formatTime(device.timestamp)}',
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}
