import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service để cache data locally cho offline mode
class CacheService {
  static const String _carsKey = 'cached_cars';
  static const String _brandsKey = 'cached_brands';
  static const String _cacheTimeKey = 'cache_time';
  static const Duration _cacheExpiry = Duration(hours: 24);

  /// Lưu danh sách xe vào cache
  Future<void> cacheCars(List<Map<String, dynamic>> cars) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_carsKey, jsonEncode(cars));
    await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Lấy danh sách xe từ cache
  Future<List<Map<String, dynamic>>?> getCachedCars() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Kiểm tra cache có hết hạn chưa
    final cacheTime = prefs.getInt(_cacheTimeKey);
    if (cacheTime != null) {
      final cachedAt = DateTime.fromMillisecondsSinceEpoch(cacheTime);
      if (DateTime.now().difference(cachedAt) > _cacheExpiry) {
        // Cache đã hết hạn
        return null;
      }
    }

    final carsJson = prefs.getString(_carsKey);
    if (carsJson == null) return null;

    try {
      final List<dynamic> decoded = jsonDecode(carsJson);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return null;
    }
  }

  /// Lưu danh sách brands vào cache
  Future<void> cacheBrands(List<String> brands) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_brandsKey, brands);
  }

  /// Lấy danh sách brands từ cache
  Future<List<String>?> getCachedBrands() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_brandsKey);
  }

  /// Xóa toàn bộ cache
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_carsKey);
    await prefs.remove(_brandsKey);
    await prefs.remove(_cacheTimeKey);
  }

  /// Kiểm tra có cache không
  Future<bool> hasCache() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_carsKey);
  }

  /// Kiểm tra cache có hết hạn chưa
  Future<bool> isCacheExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheTime = prefs.getInt(_cacheTimeKey);
    if (cacheTime == null) return true;
    
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(cacheTime);
    return DateTime.now().difference(cachedAt) > _cacheExpiry;
  }
}
