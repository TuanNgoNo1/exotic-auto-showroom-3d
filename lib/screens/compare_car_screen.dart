import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../models/car_model.dart';
import '../providers/car_provider.dart';
import 'home_screen.dart';

class CompareCarScreen extends ConsumerStatefulWidget {
  final Car? initialCar1;
  final Car? initialCar2;

  const CompareCarScreen({super.key, this.initialCar1, this.initialCar2});

  @override
  ConsumerState<CompareCarScreen> createState() => _CompareCarScreenState();
}

class _CompareCarScreenState extends ConsumerState<CompareCarScreen> {
  Car? car1;
  Car? car2;

  @override
  void initState() {
    super.initState();
    car1 = widget.initialCar1;
    car2 = widget.initialCar2;
  }

  void _selectCar(int slotIndex) {
    final carsAsync = ref.read(carsProvider);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chọn xe để so sánh',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: carsAsync.when(
                  data: (cars) => ListView.builder(
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      final car = cars[index];
                      // Don't show currently selected car in other slot
                      if (car.id == car1?.id || car.id == car2?.id) {
                        return const SizedBox.shrink();
                      }

                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            car.imageUrl, 
                            width: 50, 
                            height: 50, 
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[800],
                              child: const Icon(Icons.car_repair, color: Colors.white54, size: 24),
                            ),
                          ),
                        ),
                        title: Text(car.name, style: const TextStyle(color: Colors.white)),
                        subtitle: Text(car.brand, style: const TextStyle(color: Colors.grey)),
                        onTap: () {
                          setState(() {
                            if (slotIndex == 1) {
                              car1 = car;
                            } else {
                              car2 = car;
                            }
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Text('Lỗi: $error', style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'So sánh xe',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Car Selection Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: _buildCarSelector(car1, 1)),
                const SizedBox(width: 16),
                Container(width: 1, height: 100, color: Colors.white24),
                const SizedBox(width: 16),
                Expanded(child: _buildCarSelector(car2, 2)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Comparison Rows - Động cơ & Hiệu suất
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Section Header: Động cơ & Hiệu suất
                  _buildSectionHeader('Động cơ & Hiệu suất'),
                  const SizedBox(height: 16),
                  
                  // Động cơ
                  _buildTextComparisonRow('Động cơ', 'engine'),
                  const SizedBox(height: 20),
                  
                  // Công suất
                  _buildComparisonRow('Công suất', 'power', 'hp'),
                  const SizedBox(height: 20),
                  
                  // Mô-men xoắn
                  _buildComparisonRow('Mô-men xoắn', 'torque', 'Nm'),
                  const SizedBox(height: 20),
                  
                  // Tốc độ tối đa
                  _buildComparisonRow('Tốc độ tối đa', 'maxSpeed', 'km/h'),
                  const SizedBox(height: 20),
                  
                  // Tăng tốc 0-100km/h
                  _buildComparisonRow('Tăng tốc 0-100km/h', 'acceleration', 's', lowerIsBetter: true),
                  const SizedBox(height: 20),
                  
                  // Hộp số
                  _buildTextComparisonRow('Hộp số', 'transmission'),
                  const SizedBox(height: 20),
                  
                  // Hệ dẫn động
                  _buildTextComparisonRow('Hệ dẫn động', 'drive'),
                  const SizedBox(height: 20),
                  
                  // Loại nhiên liệu
                  _buildTextComparisonRow('Loại nhiên liệu', 'fuelType'),
                  const SizedBox(height: 20),
                  
                  // Mức tiêu thụ nhiên liệu
                  _buildComparisonRow('Mức tiêu thụ', 'fuelConsumption', 'L/100km', lowerIsBetter: true),
                  const SizedBox(height: 20),
                  
                  // Dung lượng pin (cho xe điện)
                  _buildComparisonRow('Dung lượng pin', 'battery', 'kWh'),
                  const SizedBox(height: 20),
                  
                  // Quãng đường di chuyển
                  _buildComparisonRow('Quãng đường', 'range', 'km'),
                  const SizedBox(height: 24),
                  
                  // Giá
                  _buildPriceComparison(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarSelector(Car? car, int slotIndex) {
    if (car == null) {
      return GestureDetector(
        onTap: () => _selectCar(slotIndex),
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle_outline, color: Colors.grey, size: 40),
              const SizedBox(height: 8),
              Text(
                'Chọn xe',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Image.network(
            car.imageUrl,
            height: 80,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.car_repair, size: 50, color: Colors.white24),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SizedBox(
              height: 48, // Fixed height for 2 lines of text
              child: Center(
                child: Text(
                  car.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => _selectCar(slotIndex),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              minimumSize: const Size(80, 30),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Thay đổi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 2,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonRow(String label, String specKey, String unit, {bool lowerIsBetter = false}) {
    final val1Str = car1?.specs[specKey] ?? '';
    final val2Str = car2?.specs[specKey] ?? '';

    // Nếu cả 2 xe đều không có thông số này, không hiển thị
    if (val1Str.isEmpty && val2Str.isEmpty) {
      return const SizedBox.shrink();
    }

    double val1 = _parseValue(val1Str);
    double val2 = _parseValue(val2Str);
    double maxVal = (val1 > val2 ? val1 : val2) * 1.2;
    if (maxVal == 0) maxVal = 1;

    // Xác định xe nào tốt hơn
    bool car1Better = lowerIsBetter ? (val1 < val2 && val1 > 0) : (val1 > val2);
    bool car2Better = lowerIsBetter ? (val2 < val1 && val2 > 0) : (val2 > val1);
    if (val1 == 0) car1Better = false;
    if (val2 == 0) car2Better = false;

    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar(val1, maxVal, isRightAligned: true, isWinner: car1Better),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (car1Better)
                        const Icon(Icons.emoji_events, color: AppColors.primary, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          val1Str.isNotEmpty ? val1Str : '---',
                          style: TextStyle(
                            color: car1Better ? AppColors.primary : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _getIconForSpec(specKey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBar(val2, maxVal, isRightAligned: false, isWinner: car2Better),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          val2Str.isNotEmpty ? val2Str : '---',
                          style: TextStyle(
                            color: car2Better ? AppColors.primary : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (car2Better)
                        const Icon(Icons.emoji_events, color: AppColors.primary, size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextComparisonRow(String label, String specKey) {
    final val1Str = car1?.specs[specKey] ?? '';
    final val2Str = car2?.specs[specKey] ?? '';

    // Nếu cả 2 xe đều không có thông số này, không hiển thị
    if (val1Str.isEmpty && val2Str.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                val1Str.isNotEmpty ? val1Str : '---',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            _getIconForSpec(specKey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                val2Str.isNotEmpty ? val2Str : '---',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _getIconForSpec(String specKey) {
    IconData icon;
    switch (specKey) {
      case 'engine':
        icon = Icons.engineering;
        break;
      case 'power':
        icon = Icons.flash_on;
        break;
      case 'torque':
        icon = Icons.rotate_right;
        break;
      case 'maxSpeed':
        icon = Icons.speed;
        break;
      case 'acceleration':
        icon = Icons.timer;
        break;
      case 'transmission':
        icon = Icons.settings;
        break;
      case 'drive':
        icon = Icons.all_inclusive;
        break;
      case 'fuelType':
        icon = Icons.local_gas_station;
        break;
      case 'fuelConsumption':
        icon = Icons.water_drop;
        break;
      case 'battery':
        icon = Icons.battery_charging_full;
        break;
      case 'range':
        icon = Icons.route;
        break;
      default:
        icon = Icons.info_outline;
    }
    return Icon(icon, color: Colors.grey, size: 24);
  }

  Widget _buildBar(double value, double max, {required bool isRightAligned, bool isWinner = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (value / max) * constraints.maxWidth;
        return Align(
          alignment: isRightAligned ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: width > 0 ? width : 4,
            height: 8,
            decoration: BoxDecoration(
              color: isWinner ? AppColors.primary : AppColors.primary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
              boxShadow: isWinner
                  ? [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)]
                  : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceComparison() {
    return Column(
      children: [
        const Text('Giá khởi điểm', style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                car1?.price ?? '---',
                textAlign: TextAlign.right,
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.local_offer, color: Colors.white, size: 24),
            ),
            Expanded(
              child: Text(
                car2?.price ?? '---',
                textAlign: TextAlign.left,
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _parseValue(String input) {
    // Extract numbers from string (e.g., "308 km/h" -> 308.0)
    final RegExp regex = RegExp(r'(\d+(\.\d+)?)');
    final match = regex.firstMatch(input);
    if (match != null) {
      return double.tryParse(match.group(0)!) ?? 0.0;
    }
    return 0.0;
  }
}
