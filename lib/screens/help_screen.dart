import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

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
          'Trợ giúp & Hỗ trợ',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Liên hệ
          _buildSectionTitle(context, 'Liên hệ với chúng tôi'),
          _buildContactItem(
            context,
            icon: Icons.email,
            title: 'Email hỗ trợ',
            subtitle: 'support@autoshowroom3d.com',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã copy email vào clipboard')),
              );
            },
          ),
          _buildContactItem(
            context,
            icon: Icons.phone,
            title: 'Hotline',
            subtitle: '1900 1080',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang gọi...')),
              );
            },
          ),
          _buildContactItem(
            context,
            icon: Icons.chat,
            title: 'Chat trực tuyến',
            subtitle: 'Hỗ trợ 24/7',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng đang phát triển')),
              );
            },
          ),

          const SizedBox(height: 24),

          // FAQ
          _buildSectionTitle(context, 'Câu hỏi thường gặp'),
          _buildFAQItem(
            context,
            question: 'Làm sao để xem xe 3D?',
            answer: 'Bạn chỉ cần chọn một xe từ danh sách, sau đó nhấn "Xem Chi Tiết". Bạn có thể xoay, zoom để xem xe từ mọi góc độ.',
          ),
          _buildFAQItem(
            context,
            question: 'Garage là gì?',
            answer: 'Garage là nơi bạn lưu các xe yêu thích. Bạn có thể thêm xe vào Garage từ trang chi tiết xe và so sánh các xe với nhau.',
          ),
          _buildFAQItem(
            context,
            question: 'Làm sao để so sánh xe?',
            answer: 'Vào Garage, nhấn giữ một xe để vào chế độ chọn, sau đó chọn 2 xe và nhấn "So sánh ngay".',
          ),
          _buildFAQItem(
            context,
            question: 'Tôi có thể đổi màu xe không?',
            answer: 'Có! Trong trang chi tiết xe, bạn có thể chọn các màu ngoại thất khác nhau để xem xe với màu đó.',
          ),
          _buildFAQItem(
            context,
            question: 'Dữ liệu của tôi có được bảo mật không?',
            answer: 'Chúng tôi sử dụng Supabase với mã hóa end-to-end. Dữ liệu của bạn được bảo vệ an toàn.',
          ),

          const SizedBox(height: 24),

          // Về ứng dụng
          _buildSectionTitle(context, 'Về ứng dụng'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // App icon từ assets
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/icons/app_icon.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.directions_car, color: Colors.black, size: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Exotic Auto Showroom 3D',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Phiên bản 1.0.0',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ứng dụng showroom xe 3D cho phép bạn khám phá các mẫu xe cao cấp với công nghệ 3D tiên tiến. Xem xe từ mọi góc độ, đổi màu, xem nội thất 360° và so sánh các mẫu xe.',
                  style: TextStyle(color: Colors.grey, height: 1.5),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildSocialButton(Icons.language, 'Website'),
                    const SizedBox(width: 8),
                    _buildSocialButton(Icons.facebook, 'Facebook'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Pháp lý
          _buildSectionTitle(context, 'Pháp lý'),
          _buildContactItem(
            context,
            icon: Icons.description,
            title: 'Điều khoản sử dụng',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang mở điều khoản sử dụng...')),
              );
            },
          ),
          _buildContactItem(
            context,
            icon: Icons.privacy_tip,
            title: 'Chính sách bảo mật',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang mở chính sách bảo mật...')),
              );
            },
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: subtitle != null
            ? Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12))
            : null,
        trailing: onTap != null
            ? const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16)
            : null,
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, {required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor: AppColors.primary,
        collapsedIconColor: Colors.grey,
        title: Text(
          question,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        children: [
          Text(
            answer,
            style: TextStyle(color: Colors.grey[400], height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey, size: 18),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
