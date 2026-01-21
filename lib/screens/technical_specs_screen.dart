import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_theme.dart';
import '../models/car_model.dart';

class TechnicalSpecsScreen extends StatelessWidget {
  final Car car;

  const TechnicalSpecsScreen({super.key, required this.car});

  // Mapping spec_key từ database sang tên hiển thị tiếng Việt
  static const Map<String, String> _specLabels = {
    'power': 'Công suất',
    'torque': 'Mô-men xoắn',
    'acceleration': 'Tăng tốc 0-100km/h',
    'range': 'Quãng đường di chuyển',
    'maxSpeed': 'Tốc độ tối đa',
    'dimensions': 'D x R x C',
    'wheelbase': 'Trục cơ sở',
    'groundClearance': 'Khoảng sáng gầm',
    'weight': 'Trọng lượng',
    'adas': 'Trợ lái ADAS',
    'screen': 'Màn hình',
    'sound': 'Âm thanh',
    'seats': 'Số chỗ ngồi',
    'battery': 'Dung lượng pin',
    'fuelType': 'Loại nhiên liệu',
    'drive': 'Hệ dẫn động',
    'transmission': 'Hộp số',
    'engine': 'Động cơ',
    'doors': 'Số cửa',
    'length': 'Chiều dài',
    'width': 'Chiều rộng',
    'height': 'Chiều cao',
    'fuelConsumption': 'Mức tiêu thụ',
    'trunkCapacity': 'Dung tích cốp',
  };

  // Nhóm specs theo category
  Map<String, Map<String, String>> _groupSpecs() {
    final performance = <String, String>{};
    final dimensions = <String, String>{};
    final features = <String, String>{};

    final performanceKeys = ['power', 'torque', 'acceleration', 'range', 'maxSpeed', 'battery', 'fuelType'];
    final dimensionKeys = ['dimensions', 'wheelbase', 'groundClearance', 'weight', 'seats'];

    for (final entry in car.specs.entries) {
      final label = _specLabels[entry.key] ?? entry.key;
      if (performanceKeys.contains(entry.key)) {
        performance[label] = entry.value;
      } else if (dimensionKeys.contains(entry.key)) {
        dimensions[label] = entry.value;
      } else {
        features[label] = entry.value;
      }
    }

    return {
      'Động cơ & Hiệu suất': performance,
      'Kích thước & Trọng lượng': dimensions,
      'An toàn & Tiện nghi': features,
    };
  }

  @override
  Widget build(BuildContext context) {
    final groupedSpecs = _groupSpecs();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.background,
                    const Color(0xFF1C1F26),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Quay lại',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        car.name.toUpperCase(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontSize: 20,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'THÔNG SỐ KỸ THUẬT',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 28,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: car.specs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline, size: 64, color: Colors.grey[600]),
                              const SizedBox(height: 16),
                              Text(
                                'Chưa có thông số kỹ thuật',
                                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(20),
                          children: [
                            // Hiển thị từng nhóm specs
                            for (final group in groupedSpecs.entries)
                              if (group.value.isNotEmpty) ...[
                                _buildSectionTitle(context, group.key),
                                for (final spec in group.value.entries)
                                  _buildSpecRow(context, spec.key, spec.value),
                                const SizedBox(height: 24),
                              ],
                          ]
                          .animate(interval: 50.ms)
                          .fadeIn()
                          .slideX(),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          const Divider(color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildSpecRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
