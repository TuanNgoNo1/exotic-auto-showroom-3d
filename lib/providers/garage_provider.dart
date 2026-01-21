import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/car_model.dart';
import '../services/garage_service.dart';

/// Provider cho GarageService
final garageServiceProvider = Provider((ref) => GarageService());

/// Garage state using AsyncValue để handle loading/error states
/// Hỗ trợ cả local storage (khi chưa login) và Supabase (khi đã login)
final garageProvider = StateNotifierProvider<GarageNotifier, AsyncValue<List<Car>>>((ref) {
  return GarageNotifier(ref.watch(garageServiceProvider));
});

/// Notifier để quản lý garage state
/// - Nếu user đã login: sync với Supabase
/// - Nếu chưa login: lưu local trong memory
class GarageNotifier extends StateNotifier<AsyncValue<List<Car>>> {
  final GarageService _garageService;
  
  // Local garage cho guest users
  final List<Car> _localGarage = [];

  GarageNotifier(this._garageService) : super(const AsyncValue.loading()) {
    loadGarage();
  }

  bool get _isLoggedIn => Supabase.instance.client.auth.currentUser != null;

  /// Load garage - từ Supabase nếu đã login, từ local nếu chưa
  Future<void> loadGarage() async {
    state = const AsyncValue.loading();
    try {
      if (_isLoggedIn) {
        final cars = await _garageService.getUserGarage();
        state = AsyncValue.data(cars);
      } else {
        // Guest mode - dùng local garage
        state = AsyncValue.data(List.from(_localGarage));
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Thêm xe vào garage
  Future<void> addCar(Car car, {String? colorId}) async {
    try {
      if (_isLoggedIn) {
        await _garageService.addToGarage(car.id, colorId: colorId);
        await loadGarage();
      } else {
        // Guest mode - thêm vào local
        if (!_localGarage.any((c) => c.id == car.id)) {
          _localGarage.add(car);
          state = AsyncValue.data(List.from(_localGarage));
        }
      }
    } catch (error) {
      rethrow;
    }
  }

  /// Xóa xe khỏi garage
  Future<void> removeCar(String carId) async {
    try {
      if (_isLoggedIn) {
        await _garageService.removeFromGarage(carId);
        await loadGarage();
      } else {
        // Guest mode - xóa khỏi local
        _localGarage.removeWhere((c) => c.id == carId);
        state = AsyncValue.data(List.from(_localGarage));
      }
    } catch (error) {
      rethrow;
    }
  }

  /// Kiểm tra xe có trong garage không
  bool isInGarage(String carId) {
    return state.maybeWhen(
      data: (cars) => cars.any((c) => c.id == carId),
      orElse: () => false,
    );
  }

  /// Xóa toàn bộ garage
  Future<void> clearGarage() async {
    try {
      if (_isLoggedIn) {
        await _garageService.clearGarage();
        await loadGarage();
      } else {
        _localGarage.clear();
        state = const AsyncValue.data([]);
      }
    } catch (error) {
      rethrow;
    }
  }

  /// Sync local garage lên Supabase sau khi login
  Future<void> syncLocalToSupabase() async {
    if (!_isLoggedIn || _localGarage.isEmpty) return;
    
    for (final car in _localGarage) {
      try {
        await _garageService.addToGarage(car.id);
      } catch (_) {
        // Ignore errors (car might already exist)
      }
    }
    _localGarage.clear();
    await loadGarage();
  }
}
