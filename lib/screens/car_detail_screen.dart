import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../models/car_model.dart';
import '../providers/garage_provider.dart';
import '../providers/recently_viewed_provider.dart';
import '../widgets/car_3d_viewer.dart';
import 'interior_360_screen.dart';
import 'interior_gallery_screen.dart';
import 'technical_specs_screen.dart';
import 'compare_car_screen.dart';

class CarDetailScreen extends ConsumerStatefulWidget {
  final Car car;

  const CarDetailScreen({super.key, required this.car});

  @override
  ConsumerState<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends ConsumerState<CarDetailScreen> {
  int _selectedColorIndex = 0;
  
  @override
  void initState() {
    super.initState();
    // Track xe đã xem
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recentlyViewedProvider.notifier).addCar(widget.car);
    });
  }
  
  Color? get _selectedColor {
    if (widget.car.colors.isEmpty) return null;
    return widget.car.colors[_selectedColorIndex];
  }

  @override
  Widget build(BuildContext context) {
    final garageAsync = ref.watch(garageProvider);
    final isInGarage = garageAsync.maybeWhen(
      data: (cars) => cars.any((c) => c.id == widget.car.id),
      orElse: () => false,
    );
    
    final car = widget.car;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image (Blurred) - với gaplessPlayback để không bị mất khi rebuild
          Positioned.fill(
            child: Image.network(
              car.imageUrl,
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.8),
              colorBlendMode: BlendMode.darken,
              gaplessPlayback: true, // Giữ ảnh cũ trong khi load ảnh mới
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: frame != null ? child : Container(color: Colors.black),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - với background đen để đồng nhất với 3D viewer
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
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
                      Flexible(
                        child: Text(
                          car.name.toUpperCase(),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 60), // Balance spacing
                    ],
                  ),
                ),

                // 3D Model OR Image
                Expanded(
                  flex: 4,
                  child: Container(
                    color: Colors.black, // Background đen phủ hết area
                    child: car.has3DModel
                        ? Car3DViewer(car: car, selectedColor: _selectedColor)
                        : Stack(
                            children: [
                              Center(
                                child: Image.network(
                                  car.imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => 
                                      const Icon(Icons.car_repair, size: 100, color: Colors.white24),
                                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                              ),
                              Positioned(
                                bottom: 10,
                                left: 20,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.camera_alt, color: Colors.white70, size: 14),
                                      SizedBox(width: 4),
                                      Text('AR Ready', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                // Info Panel
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Car Name & Specs
                                _buildGlassInfoCard(context),
                                
                                // Description
                                if (car.description.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Text(
                                      car.description,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white60,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                
                                const SizedBox(height: 24),
                                
                                // Exterior Colors
                                Text(
                                  'MÀU NGOẠI THẤT',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.primary, // Màu vàng nổi bật
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.0,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Màu sắc cân đều ra hết màn hình
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: car.colors.asMap().entries.map((entry) {
                                    final isSelected = entry.key == _selectedColorIndex;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedColorIndex = entry.key;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: isSelected 
                                            ? Border.all(color: AppColors.primary, width: 2) 
                                            : Border.all(color: Colors.transparent, width: 2),
                                        ),
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: entry.value,
                                            shape: BoxShape.circle,
                                            // Viền để phân biệt màu đen với nền
                                            border: Border.all(
                                              color: Colors.white.withValues(alpha: 0.3),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.3),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),

                                const SizedBox(height: 24),

                                // New Action Cards (Interior & Specs)
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildActionCard(
                                        context,
                                        title: 'Nội thất',
                                        icon: Icons.airline_seat_legroom_extra,
                                        onTap: () => _showInteriorOptions(context, car),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildActionCard(
                                        context,
                                        title: 'Thông số kỹ thuật',
                                        icon: Icons.settings_outlined,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => TechnicalSpecsScreen(car: car)),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),

                        // Bottom Actions
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: isInGarage
                                      ? null
                                      : () async {
                                          try {
                                            await ref.read(garageProvider.notifier).addCar(car);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('${car.name} đã được thêm vào Garage'),
                                                  backgroundColor: AppColors.primary,
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Lỗi: $e'),
                                                  backgroundColor: Colors.red,
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 8,
                                    shadowColor: AppColors.primary.withValues(alpha: 0.4),
                                  ).copyWith(
                                    backgroundColor: WidgetStateProperty.all(Colors.transparent),
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: isInGarage
                                          ? LinearGradient(
                                              colors: [Colors.grey[700]!, Colors.grey[600]!],
                                            )
                                          : const LinearGradient(
                                              colors: [
                                                Color(0xFFB8860B),
                                                AppColors.primary,
                                                Color(0xFFB8860B),
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        isInGarage ? 'ĐÃ CÓ TRONG GARAGE' : 'THÊM VÀO GARAGE',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isInGarage ? Colors.white54 : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                                color: Colors.transparent,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.balance, color: AppColors.primary),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CompareCarScreen(initialCar1: car),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInteriorOptions(BuildContext context, Car car) {
    // Nếu có cả hai -> hiện bottom sheet cho user chọn
    if (car.hasPanorama && car.hasInteriorImages) {
      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Xem nội thất',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.threesixty, color: AppColors.primary),
                title: const Text('Xem 360°', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Trải nghiệm nội thất toàn cảnh', style: TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => Interior360Screen(car: car)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Xem ảnh chi tiết', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Bộ sưu tập ảnh nội thất', style: TextStyle(color: Colors.grey)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InteriorGalleryScreen(car: car, interiorImages: car.interiorImages),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    } 
    // Chỉ có panorama -> mở 360
    else if (car.hasPanorama) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Interior360Screen(car: car)),
      );
    } 
    // Chỉ có ảnh gallery -> mở gallery
    else if (car.hasInteriorImages) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InteriorGalleryScreen(car: car, interiorImages: car.interiorImages),
        ),
      );
    } 
    // Không có gì
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ảnh nội thất đang được cập nhật'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildGlassInfoCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1F26).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)), // Gold border
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.02),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.car.name.toUpperCase(),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 24,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.white10),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Power
                  Expanded(
                    child: _buildSpecItem(
                      context,
                      'Công suất',
                      widget.car.specs['power'] ?? 'N/A',
                    ),
                  ),
                  // Acceleration
                  Expanded(
                    child: _buildSpecItem(
                      context,
                      'Tăng tốc',
                      widget.car.specs['acceleration'] ?? 'N/A',
                    ),
                  ),
                  // Max Speed
                  Expanded(
                    child: _buildSpecItem(
                      context,
                      'Tốc độ',
                      widget.car.specs['maxSpeed'] ?? 'N/A',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideX();
  }

  Widget _buildSpecItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white54,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, {required String title, String? image, IconData? icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2A2D35),
              Color(0xFF1C1F26),
            ],
          ),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon ?? Icons.photo_library_outlined,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).scale();
  }
}
