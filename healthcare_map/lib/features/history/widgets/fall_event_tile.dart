import 'package:flutter/material.dart';
import '../../../models/fall_event.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';

class FallEventTile extends StatelessWidget {
  final FallEvent event;
  final VoidCallback onMapTapped;

  const FallEventTile({
    Key? key,
    required this.event,
    required this.onMapTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.danger.withOpacity(0.3)),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.danger.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
        ),
        title: Text('Té ngã phát hiện', style: AppTypography.heading),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(DateFormatter.formatTime(event.timestamp.millisecondsSinceEpoch ~/ 1000), style: AppTypography.caption),
            const SizedBox(height: 4),
            Text('${event.lat}°N, ${event.lng}°E', style: AppTypography.data),
          ],
        ),
        trailing: TextButton.icon(
          icon: const Icon(Icons.map_outlined, size: 16),
          label: const Text('Bản đồ'),
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          onPressed: onMapTapped,
        ),
      ),
    );
  }
}
