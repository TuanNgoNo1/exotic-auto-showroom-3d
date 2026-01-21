import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/car_model.dart';

class GlassSpecsPanel extends StatelessWidget {
  final Car car;

  const GlassSpecsPanel({super.key, required this.car});

  // Format acceleration để chỉ hiện giá trị ngắn gọn (vd: "2.9s" thay vì "0-100km/h trong 2.9s")
  String _formatAcceleration(String? value) {
    if (value == null) return 'N/A';
    // Tìm số giây trong chuỗi
    final regex = RegExp(r'(\d+\.?\d*)\s*s');
    final match = regex.firstMatch(value);
    if (match != null) {
      return '${match.group(1)}s';
    }
    return value;
  }

  Widget _buildSpecItem(BuildContext context, {required String label, required String value}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white54,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              // Power
              Expanded(
                child: _buildSpecItem(
                  context,
                  label: 'Công suất',
                  value: car.specs['power'] ?? 'N/A',
                ),
              ),
              // Acceleration
              Expanded(
                child: _buildSpecItem(
                  context,
                  label: 'Tăng tốc',
                  value: _formatAcceleration(car.specs['acceleration']),
                ),
              ),
              // Max Speed
              Expanded(
                child: _buildSpecItem(
                  context,
                  label: 'Tốc độ',
                  value: car.specs['maxSpeed'] ?? 'N/A',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
