import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';
import '../utils/app_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  bool _notifEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Refresh trạng thái khi user quay lại từ Settings hệ thống
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    final enabled =
        await NotificationService.instance.hasNotificationPermission();
    if (mounted) setState(() => _notifEnabled = enabled);
  }

  Future<void> _requestPermission() async {
    final granted = await NotificationService.instance.requestPermissions();
    if (!mounted) return;
    setState(() => _notifEnabled = granted);
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng vào Cài đặt hệ thống → App → Thông báo để bật'),
          duration: Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã bật thông báo!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection('Thông báo'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                _notifEnabled
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: _notifEnabled
                    ? AppColors.primary
                    : AppColors.textSecondary(context),
              ),
              title: Text('Quyền thông báo',
                  style: TextStyle(color: AppColors.textPrimary(context))),
              subtitle: Text(
                _notifEnabled ? 'Đã bật' : 'Chưa bật — nhấn để cấp quyền',
                style: TextStyle(
                  color: _notifEnabled ? AppColors.success : AppColors.danger,
                  fontSize: 12,
                ),
              ),
              trailing: _notifEnabled
                  ? const Icon(Icons.check_circle, color: AppColors.success)
                  : TextButton(
                      onPressed: _requestPermission,
                      child: const Text('Bật'),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSection('Giao diện'),
          Consumer<ThemeService>(
            builder: (context, theme, _) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _themeOption(
                      icon: Icons.brightness_auto,
                      title: 'Theo hệ thống',
                      subtitle: 'Tự động theo cài đặt thiết bị',
                      mode: ThemeMode.system,
                      currentMode: theme.themeMode,
                      onTap: () => theme.setTheme(ThemeMode.system),
                    ),
                    Divider(height: 1, color: AppColors.border(context)),
                    _themeOption(
                      icon: Icons.light_mode,
                      title: 'Chế độ sáng',
                      subtitle: 'Giao diện sáng',
                      mode: ThemeMode.light,
                      currentMode: theme.themeMode,
                      onTap: () => theme.setTheme(ThemeMode.light),
                    ),
                    Divider(height: 1, color: AppColors.border(context)),
                    _themeOption(
                      icon: Icons.dark_mode,
                      title: 'Chế độ tối',
                      subtitle: 'Giao diện tối, đỡ mỏi mắt',
                      mode: ThemeMode.dark,
                      currentMode: theme.themeMode,
                      onTap: () => theme.setTheme(ThemeMode.dark),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSection('Thông tin'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.info_outline, color: AppColors.primary),
                  title: Text('Phiên bản',
                      style: TextStyle(color: AppColors.textPrimary(context))),
                  trailing: Text('1.0.0',
                      style:
                          TextStyle(color: AppColors.textSecondary(context))),
                ),
                Divider(height: 1, color: AppColors.border(context)),
                ListTile(
                  leading: const Icon(Icons.group, color: AppColors.primary),
                  title: Text('Tác giả',
                      style: TextStyle(color: AppColors.textPrimary(context))),
                  subtitle: Text(
                    'Trần Đinh Hải Nguyên\nNguyễn Viết An Bình\nPhạm Huy Trung',
                    style: TextStyle(
                        color: AppColors.textSecondary(context), fontSize: 12, height: 1.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary(context),
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _themeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required VoidCallback onTap,
  }) {
    final isSelected = mode == currentMode;
    return ListTile(
      leading: Icon(icon,
          color: isSelected
              ? AppColors.primary
              : AppColors.textSecondary(context)),
      title:
          Text(title, style: TextStyle(color: AppColors.textPrimary(context))),
      subtitle: Text(subtitle,
          style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}
