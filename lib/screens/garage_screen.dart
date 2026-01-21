import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../models/car_model.dart';
import '../providers/garage_provider.dart';
import 'compare_car_screen.dart';
import 'car_detail_screen.dart';
import 'home_screen.dart';

class GarageScreen extends ConsumerStatefulWidget {
  const GarageScreen({super.key});

  @override
  ConsumerState<GarageScreen> createState() => _GarageScreenState();
}

class _GarageScreenState extends ConsumerState<GarageScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedCarIds = {};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedCarIds.clear();
    });
  }

  void _toggleCarSelection(String carId) {
    setState(() {
      if (_selectedCarIds.contains(carId)) {
        _selectedCarIds.remove(carId);
      } else {
        if (_selectedCarIds.length < 2) {
          _selectedCarIds.add(carId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chỉ được chọn tối đa 2 xe để so sánh')),
          );
        }
      }
    });
  }

  void _navigateToCompare(List<Car> garageCars) {
    if (_selectedCarIds.length != 2) return;

    final selectedCars = garageCars.where((c) => _selectedCarIds.contains(c.id)).toList();
    if (selectedCars.length == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompareCarScreen(
            initialCar1: selectedCars[0],
            initialCar2: selectedCars[1],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final garageAsync = ref.watch(garageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        // Nút so sánh bên trái
        leading: garageAsync.when(
          data: (cars) => cars.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    _isSelectionMode ? Icons.close : Icons.balance,
                    color: AppColors.primary,
                  ),
                  onPressed: _toggleSelectionMode,
                )
              : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => const SizedBox.shrink(),
        ),
        title: Text(
          'Garage của tôi',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Nút thêm xe mới bên phải
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 28),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(initialIndex: 1),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: garageAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                'Không thể tải dữ liệu garage',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.refresh(garageProvider),
                child: const Text('Thử lại', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        ),
        data: (garageCars) => Column(
          children: [
            Expanded(
              child: garageCars.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.garage_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'Garage trống',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cấu hình đã lưu (${garageCars.length})',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...garageCars.map((car) => _buildGarageItem(context, car)),
                        ],
                      ),
                    ),
            ),
            
            // Bottom Action Button - So sánh (chỉ hiện khi chọn đủ 2 xe)
            if (_isSelectionMode && _selectedCarIds.length == 2)
               Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _navigateToCompare(garageCars),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    child: Text(
                      'So sánh ngay',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ).animate().fadeIn().slideY(begin: 0.2, end: 0),
              ),
            // Bottom padding cho nav bar
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildGarageItem(BuildContext context, Car car) {
    final isSelected = _selectedCarIds.contains(car.id);

    return GestureDetector(
      onLongPress: _toggleSelectionMode,
      onTap: _isSelectionMode ? () => _toggleCarSelection(car.id) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: _isSelectionMode && isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Car Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    car.imageUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.grey[900],
                      child: const Icon(Icons.car_repair, color: Colors.white54, size: 50),
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        car.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        car.price,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Actions (Hide in selection mode)
                      if (!_isSelectionMode)
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Navigate to Car Detail Screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CarDetailScreen(car: car),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: const Text(
                                  'Xem cấu hình',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            TextButton.icon(
                              onPressed: () {
                                ref.read(garageProvider.notifier).removeCar(car.id);
                              },
                              icon: Icon(Icons.delete_outline, color: Colors.grey[400], size: 20),
                              label: Text(
                                'Xóa',
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Checkbox Overlay
            if (_isSelectionMode)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.black54,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: isSelected ? Colors.black : Colors.transparent,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ).animate().fadeIn().slideX(),
    );
  }
}
