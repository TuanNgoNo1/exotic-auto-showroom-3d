import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/car_model.dart';
import 'car_service.dart';

/// Service để quản lý Garage của user trên Supabase
/// 
/// Chức năng:
/// - Lấy danh sách xe trong garage của user hiện tại
/// - Thêm xe vào garage
/// - Xóa xe khỏi garage
/// - Kiểm tra xe có trong garage chưa
class GarageService {
  final _supabase = Supabase.instance.client;
  final _carService = CarService();

  /// Lấy garage của user hiện tại
  /// Returns empty list nếu user chưa đăng nhập
  Future<List<Car>> getUserGarage() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        // Warning: User not authenticated, returning empty garage
        return [];
      }

      // Lấy danh sách car_id từ user_garage
      final response = await _supabase
          .from('user_garage')
          .select('car_id')
          .eq('user_id', userId);

      final carIds = (response as List)
          .map((item) => item['car_id'] as String)
          .toList();

      if (carIds.isEmpty) return [];

      // Load full car details cho từng xe
      final List<Car> cars = [];
      for (final carId in carIds) {
        try {
          final car = await _carService.getCarById(carId);
          cars.add(car);
        } catch (e) {
          // Warning: Failed to load car $carId: $e
          // Continue loading other cars
        }
      }

      return cars;
    } catch (e) {
      throw Exception('Failed to get user garage: $e');
    }
  }

  /// Thêm xe vào garage
  /// 
  /// [carId]: ID của xe cần thêm
  /// [colorId]: (Optional) ID của màu xe được chọn
  Future<void> addToGarage(String carId, {String? colorId}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Check xem đã có trong garage chưa
      final existing = await _supabase
          .from('user_garage')
          .select('id')
          .eq('user_id', userId)
          .eq('car_id', carId);

      if ((existing as List).isNotEmpty) {
        throw Exception('Car already in garage');
      }

      // Thêm vào garage
      await _supabase.from('user_garage').insert({
        'user_id': userId,
        'car_id': carId,
        'selected_color_id': colorId,
      });
    } catch (e) {
      throw Exception('Failed to add to garage: $e');
    }
  }

  /// Xóa xe khỏi garage
  Future<void> removeFromGarage(String carId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('user_garage')
          .delete()
          .eq('user_id', userId)
          .eq('car_id', carId);
    } catch (e) {
      throw Exception('Failed to remove from garage: $e');
    }
  }

  /// Kiểm tra xe đã có trong garage chưa
  Future<bool> isInGarage(String carId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('user_garage')
          .select('id')
          .eq('user_id', userId)
          .eq('car_id', carId);

      return (response as List).isNotEmpty;
    } catch (e) {
      // Warning: Failed to check if car in garage: $e
      return false;
    }
  }

  /// Xóa tất cả xe khỏi garage (clear garage)
  Future<void> clearGarage() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('user_garage')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to clear garage: $e');
    }
  }

  /// Đếm số xe trong garage
  Future<int> getGarageCount() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return 0;

      final response = await _supabase
          .from('user_garage')
          .select('id')
          .eq('user_id', userId);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }
}
