import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/car_model.dart';

/// Provider để lưu danh sách xe đã xem gần đây
final recentlyViewedProvider = StateNotifierProvider<RecentlyViewedNotifier, List<Car>>((ref) {
  return RecentlyViewedNotifier();
});

class RecentlyViewedNotifier extends StateNotifier<List<Car>> {
  static const int maxItems = 10;

  RecentlyViewedNotifier() : super([]);

  /// Thêm xe vào danh sách đã xem
  void addCar(Car car) {
    // Xóa nếu đã tồn tại (để đưa lên đầu)
    final newList = state.where((c) => c.id != car.id).toList();
    
    // Thêm vào đầu danh sách
    newList.insert(0, car);
    
    // Giới hạn số lượng
    if (newList.length > maxItems) {
      newList.removeLast();
    }
    
    state = newList;
  }

  /// Xóa xe khỏi danh sách
  void removeCar(String carId) {
    state = state.where((c) => c.id != carId).toList();
  }

  /// Xóa tất cả
  void clear() {
    state = [];
  }

  /// Lấy số lượng xe đã xem
  int get count => state.length;
}
