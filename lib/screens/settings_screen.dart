import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../utils/app_utils.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          _buildSection(context, 'Giao diện'),
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
                      context,
                      icon: Icons.brightness_auto,
                      title: 'Theo hệ thống',
                      subtitle: 'Tự động theo cài đặt thiết bị',
                      mode: ThemeMode.system,
                      currentMode: theme.themeMode,
                      onTap: () => theme.setTheme(ThemeMode.system),
                    ),
                    Divider(height: 1, color: AppColors.border(context)),
                    _themeOption(
                      context,
                      icon: Icons.light_mode,
                      title: 'Chế độ sáng',
                      subtitle: 'Giao diện sáng',
                      mode: ThemeMode.light,
                      currentMode: theme.themeMode,
                      onTap: () => theme.setTheme(ThemeMode.light),
                    ),
                    Divider(height: 1, color: AppColors.border(context)),
                    _themeOption(
                      context,
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
          _buildSection(context, 'Thông tin'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppColors.primary),
                  title: Text('Phiên bản',
                      style: TextStyle(color: AppColors.textPrimary(context))),
                  trailing: Text('1.0.0',
                      style: TextStyle(color: AppColors.textSecondary(context))),
                ),
                Divider(height: 1, color: AppColors.border(context)),
                ListTile(
                  leading: const Icon(Icons.code, color: AppColors.primary),
                  title: Text('Tác giả',
                      style: TextStyle(color: AppColors.textPrimary(context))),
                  trailing: Text('Đồ án môn học',
                      style: TextStyle(color: AppColors.textSecondary(context))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title) {
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

  Widget _themeOption(
    BuildContext context, {
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
          color: isSelected ? AppColors.primary : AppColors.textSecondary(context)),
      title: Text(title,
          style: TextStyle(color: AppColors.textPrimary(context))),
      subtitle: Text(subtitle,
          style: TextStyle(
              color: AppColors.textSecondary(context), fontSize: 12)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}