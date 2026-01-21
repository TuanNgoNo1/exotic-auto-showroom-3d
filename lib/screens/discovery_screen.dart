import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/car_provider.dart';
import '../models/car_model.dart';
import 'car_detail_screen.dart';

// Provider cho search query local
final _searchQueryProvider = StateProvider<String>((ref) => '');

// Provider cho brand filter
final _selectedBrandProvider = StateProvider<String?>((ref) => null);

// Provider cho filtered cars - kết hợp search và brand filter
final _filteredCarsProvider = Provider<AsyncValue<List<Car>>>((ref) {
  final carsAsync = ref.watch(carsProvider);
  final searchQuery = ref.watch(_searchQueryProvider).toLowerCase();
  final selectedBrand = ref.watch(_selectedBrandProvider);

  return carsAsync.whenData((cars) {
    var filtered = cars;

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((car) {
        return car.name.toLowerCase().contains(searchQuery) ||
            car.brand.toLowerCase().contains(searchQuery) ||
            car.description.toLowerCase().contains(searchQuery);
      }).toList();
    }

    // Filter by brand
    if (selectedBrand != null && selectedBrand.isNotEmpty) {
      filtered = filtered.where((car) => car.brand == selectedBrand).toList();
    }

    return filtered;
  });
});

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  final _searchController = TextEditingController();

  // Format 3 thông số chính: power, acceleration, maxSpeed
  String _formatSpecs(Car car) {
    final specs = <String>[];
    if (car.specs['power'] != null) specs.add(car.specs['power']!);
    if (car.specs['acceleration'] != null) {
      final accel = car.specs['acceleration']!;
      final regex = RegExp(r'(\d+\.?\d*)\s*s');
      final match = regex.firstMatch(accel);
      specs.add(match != null ? '${match.group(1)}s' : accel);
    }
    if (car.specs['maxSpeed'] != null) specs.add(car.specs['maxSpeed']!);
    return specs.take(3).join('  |  ');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCarsAsync = ref.watch(_filteredCarsProvider);
    final brandsAsync = ref.watch(brandsProvider);
    final selectedBrand = ref.watch(_selectedBrandProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Khám phá',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Tìm kiếm xe...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        ref.read(_searchQueryProvider.notifier).state = value;
                      },
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        ref.read(_searchQueryProvider.notifier).state = '';
                      },
                      child: const Icon(Icons.close, color: Colors.grey, size: 20),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Filter Chips - Brand filter từ Supabase
          SizedBox(
            height: 40,
            child: brandsAsync.when(
              data: (brands) => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // "Tất cả" chip
                  _buildFilterChip(
                    context,
                    'Tất cả',
                    isSelected: selectedBrand == null,
                    onTap: () {
                      ref.read(_selectedBrandProvider.notifier).state = null;
                    },
                  ),
                  // Brand chips từ database
                  ...brands.map((brand) => _buildFilterChip(
                    context,
                    brand,
                    isSelected: selectedBrand == brand,
                    onTap: () {
                      ref.read(_selectedBrandProvider.notifier).state = brand;
                    },
                  )),
                ],
              ),
              loading: () => const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          const SizedBox(height: 16),

          // Car List - Filtered results
          Expanded(
            child: filteredCarsAsync.when(
              data: (cars) => cars.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'Không tìm thấy xe nào',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              ref.read(_searchQueryProvider.notifier).state = '';
                              ref.read(_selectedBrandProvider.notifier).state = null;
                            },
                            child: const Text('Xóa bộ lọc', style: TextStyle(color: AppColors.primary)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: cars.length,
                      itemBuilder: (context, index) {
                        return _buildCarCard(context, cars[index])
                            .animate()
                            .fadeIn(delay: (100 * index).ms)
                            .slideY(begin: 0.1, end: 0);
                      },
                    ),
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Lỗi: $error', style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(carsProvider),
                      child: const Text('Thử lại', style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, {bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarCard(BuildContext context, Car car) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            car.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatSpecs(car),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Text(
                        'Xem chi tiết',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      car.price,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Brand badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        car.brand,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
