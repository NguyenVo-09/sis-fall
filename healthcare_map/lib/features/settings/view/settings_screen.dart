import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _fallAlertEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _autoPinEsp = true;
  double _batteryThreshold = 20.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('THIẾT BỊ'),
          _buildCard([
            ListTile(
              title: const Text('ID thiết bị'),
              trailing: Text('ESP32_001', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Cơ sở dữ liệu'),
              trailing: Text('Cloud Firestore', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Kết nối lại'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('THÔNG BÁO'),
          _buildCard([
            SwitchListTile(
              title: const Text('Cảnh báo té ngã'),
              value: _fallAlertEnabled,
              onChanged: (val) => setState(() => _fallAlertEnabled = val),
              activeColor: AppColors.primary,
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('Âm thanh cảnh báo'),
              value: _soundEnabled,
              onChanged: (val) => setState(() => _soundEnabled = val),
              activeColor: AppColors.primary,
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('Rung thiết bị'),
              value: _vibrationEnabled,
              onChanged: (val) => setState(() => _vibrationEnabled = val),
              activeColor: AppColors.primary,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('BẢN ĐỒ'),
          _buildCard([
            ListTile(
              title: const Text('Chế độ mặc định'),
              trailing: const Text('Bản đồ'),
              onTap: () {},
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('Tự ghim ESP32 khi mở'),
              value: _autoPinEsp,
              onChanged: (val) => setState(() => _autoPinEsp = val),
              activeColor: AppColors.primary,
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('PIN CẢNH BÁO'),
          _buildCard([
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ngưỡng cảnh báo thấp'),
                      Text('${_batteryThreshold.toInt()}%', style: AppTypography.data),
                    ],
                  ),
                  Slider(
                    value: _batteryThreshold,
                    min: 10,
                    max: 50,
                    divisions: 8,
                    activeColor: AppColors.danger,
                    onChanged: (val) => setState(() => _batteryThreshold = val),
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('THÔNG TIN'),
          _buildCard([
            ListTile(
              title: const Text('Phiên bản app'),
              trailing: Text('1.0.0', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Xóa cache bản đồ'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Xóa lịch sử té ngã', style: TextStyle(color: AppColors.danger)),
              trailing: const Icon(Icons.chevron_right, color: AppColors.danger),
              onTap: () {
                _showDeleteDialog(context);
              },
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(title, style: AppTypography.caption),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      child: Column(
        children: children,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa lịch sử?'),
        content: const Text('Toàn bộ dữ liệu té ngã sẽ bị xóa vĩnh viễn.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(context);
              // Handle delete
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
