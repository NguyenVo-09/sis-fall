import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class BatteryIndicator extends StatelessWidget {
  final int percent;

  const BatteryIndicator({Key? key, required this.percent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color color;

    if (percent > 60) {
      iconData = Icons.battery_full;
      color = AppColors.success;
    } else if (percent >= 20) {
      iconData = Icons.battery_4_bar; // Tạm dùng battery_4_bar thay vì battery_3_bar
      color = AppColors.warning;
    } else {
      iconData = Icons.battery_alert;
      color = AppColors.danger;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconData, color: color, size: 20),
        const SizedBox(width: 4),
        Text(
          '$percent%',
          style: AppTypography.data.copyWith(color: color),
        ),
      ],
    );
  }
}
