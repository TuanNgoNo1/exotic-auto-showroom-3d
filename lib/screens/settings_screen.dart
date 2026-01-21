import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Cài đặt',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Giao diện
          _buildSectionTitle(context, 'Giao diện'),
          _buildSettingItem(
            context,
            icon: Icons.dark_mode,
            title: 'Chế độ tối',
            subtitle: 'Đang bật',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement theme toggle
              },
              activeColor: AppColors.primary,
            ),
          ),
          _buildSettingItem(
            context,
            icon: Icons.language,
            title: 'Ngôn ngữ',
            subtitle: 'Tiếng Việt',
            onTap: () => _showLanguageDialog(context),
          ),

          const SizedBox(height: 24),

          // Thông báo
          _buildSectionTitle(context, 'Thông báo'),
          _buildSettingItem(
            context,
            icon: Icons.notifications,
            title: 'Thông báo đẩy',
            subtitle: 'Nhận thông báo về xe mới',
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement notification toggle
              },
              activeColor: AppColors.primary,
            ),
          ),
          _buildSettingItem(
            context,
            icon: Icons.email,
            title: 'Email thông báo',
            subtitle: 'Nhận email về khuyến mãi',
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // TODO: Implement email notification toggle
              },
              activeColor: AppColors.primary,
            ),
          ),

          const SizedBox(height: 24),

          // Bảo mật
          _buildSectionTitle(context, 'Bảo mật'),
          _buildSettingItem(
            context,
            icon: Icons.lock,
            title: 'Đổi mật khẩu',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
            },
          ),

          const SizedBox(height: 24),

          // Khác
          _buildSectionTitle(context, 'Khác'),
          _buildSettingItem(
            context,
            icon: Icons.storage,
            title: 'Xóa bộ nhớ cache',
            subtitle: 'Giải phóng dung lượng',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa cache')),
              );
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.info,
            title: 'Phiên bản ứng dụng',
            subtitle: '1.0.0',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.grey),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: subtitle != null
            ? Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12))
            : null,
        trailing: trailing ?? (onTap != null
            ? const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16)
            : null),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Chọn ngôn ngữ', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇻🇳', style: TextStyle(fontSize: 24)),
              title: const Text('Tiếng Việt', style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.check, color: AppColors.primary),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              title: const Text('English', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang phát triển')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
