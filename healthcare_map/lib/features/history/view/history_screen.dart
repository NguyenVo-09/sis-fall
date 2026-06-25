import 'package:flutter/material.dart';
import '../widgets/fall_event_tile.dart';
import '../../../models/fall_event.dart';
import '../../../services/device_repository.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import 'package:get_it/get_it.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<FallEvent> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = GetIt.I<DeviceRepository>();
    final data = await repo.getFallHistory();
    if (mounted) {
      setState(() {
        _events = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử té ngã 🔍'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (index == 0 ||
                            DateFormatter.formatDateOnly(event.timestamp) !=
                                DateFormatter.formatDateOnly(_events[index - 1].timestamp))
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              '── ${DateFormatter.formatDateOnly(event.timestamp)} ──',
                              style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        FallEventTile(
                          event: event,
                          onMapTapped: () {
                            // Navigate to map and focus on this event
                          },
                        ),
                      ],
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield_outlined, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text('Chưa có sự kiện', style: AppTypography.heading),
          const SizedBox(height: 8),
          Text(
            'Không có té ngã nào được ghi nhận\ntrong khoảng thời gian đã chọn.',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
