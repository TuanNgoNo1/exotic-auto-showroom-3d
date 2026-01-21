import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/car_model.dart';

/// Service để giao tiếp với Supabase cho Car operations
/// 
/// Chức năng:
/// - Lấy danh sách xe từ database
/// - Lấy chi tiết 1 xe (bao gồm specs và colors)
/// - Search xe
/// - Filter xe theo brand, featured, etc.
class CarService {
  final _supabase = Supabase.instance.client;

  /// Lấy tất cả xe (có thể filter)
  /// 
  /// [isFeatured]: Lọc xe nổi bật
  /// [brandName]: Lọc theo hãng xe
  /// [limit]: Giới hạn số lượng kết quả
  Future<List<Car>> getCars({
    bool? isFeatured,
    String? brandName,
    int limit = 50,
  }) async {
    try {
      var query = _supabase
          .from('cars')
          .select('''
            *,
            brands!inner(name)
          ''');

      // Apply filters
      if (isFeatured != null) {
        query = query.eq('is_featured', isFeatured);
      }

      if (brandName != null && brandName.isNotEmpty) {
        query = query.eq('brands.name', brandName);
      }

      // Execute query with limit
      final response = await query.eq('is_available', true).limit(limit);

      // Parse JSON thành Car objects
      final List<Car> cars = [];
      for (final json in response as List) {
        // Thêm brand_name vào JSON để Car.fromJson có thể đọc
        final carJson = Map<String, dynamic>.from(json);
        if (json['brands'] != null) {
          carJson['brand_name'] = json['brands']['name'];
        }
        
        final car = Car.fromJson(carJson);
        
        // Load specs và colors cho xe này
        final carWithDetails = await _loadCarDetails(car);
        cars.add(carWithDetails);
      }

      return cars;
    } catch (e) {
      throw Exception('Failed to get cars: $e');
    }
  }

  /// Lấy chi tiết 1 xe by ID
  Future<Car> getCarById(String carId) async {
    try {
      final response = await _supabase
          .from('cars')
          .select('''
            *,
            brands!inner(name)
          ''')
          .eq('id', carId)
          .single();

      // Add brand_name
      final carJson = Map<String, dynamic>.from(response);
      if (response['brands'] != null) {
        carJson['brand_name'] = response['brands']['name'];
      }

      final car = Car.fromJson(carJson);
      return await _loadCarDetails(car);
    } catch (e) {
      throw Exception('Failed to get car by id: $e');
    }
  }

  /// Load specs và colors cho 1 xe
  Future<Car> _loadCarDetails(Car car) async {
    try {
      // Load specs
      final specsResponse = await _supabase
          .from('car_specs')
          .select()
          .eq('car_id', car.id)
          .order('display_order');

      final Map<String, String> specs = {};
      for (final specJson in specsResponse as List) {
        specs[specJson['spec_key']] = specJson['spec_value'];
      }

      // Load colors
      final colorsResponse = await _supabase
          .from('car_colors')
          .select()
          .eq('car_id', car.id);

      final List<Color> colors = [];
      for (final colorJson in colorsResponse as List) {
        final hexColor = (colorJson['color_hex'] as String).replaceAll('#', '');
        final color = Color(int.parse('FF$hexColor', radix: 16));
        colors.add(color);
      }

      // Load interior images
      List<String> interiorImages = [];
      try {
        final imagesResponse = await _supabase
            .from('car_interior_images')
            .select('image_url')
            .eq('car_id', car.id)
            .order('display_order');
        
        interiorImages = (imagesResponse as List)
            .map((img) => img['image_url'] as String)
            .toList();
      } catch (e) {
        // Table might not exist yet, ignore error
      }

      // Return car với specs, colors và interior images
      return car.copyWith(
        specs: specs.isNotEmpty ? specs : car.specs,
        colors: colors.isNotEmpty ? colors : car.colors,
        interiorImages: interiorImages.isNotEmpty ? interiorImages : car.interiorImages,
      );
    } catch (e) {
      // Nếu lỗi khi load details, vẫn return car gốc
      // Failed to load car details: $e
      return car;
    }
  }

  /// Search cars by name or description
  Future<List<Car>> searchCars(String query) async {
    try {
      if (query.isEmpty) return [];

      final response = await _supabase
          .from('cars')
          .select('''
            *,
            brands!inner(name)
          ''')
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .eq('is_available', true)
          .limit(20);

      final List<Car> cars = [];
      for (final json in response as List) {
        final carJson = Map<String, dynamic>.from(json);
        if (json['brands'] != null) {
          carJson['brand_name'] = json['brands']['name'];
        }
        
        final car = Car.fromJson(carJson);
        final carWithDetails = await _loadCarDetails(car);
        cars.add(carWithDetails);
      }

      return cars;
    } catch (e) {
      throw Exception('Failed to search cars: $e');
    }
  }

  /// Lấy xe featured (nổi bật) random
  Future<Car?> getFeaturedCar() async {
    try {
      // 1. Thử lấy danh sách xe featured (limit 10 để random)
      // Lưu ý: Không cần lấy hết, chỉ cần 1 số lượng nhỏ để hiển thị random
      final featuredCars = await getCars(isFeatured: true, limit: 10);
      
      if (featuredCars.isNotEmpty) {
        // Random 1 xe từ list
        return featuredCars[DateTime.now().second % featuredCars.length];
      }

      // 2. Nếu không có xe featured, lấy random từ danh sách xe mới nhất (limit 5)
      final anyCars = await getCars(limit: 5);
      if (anyCars.isNotEmpty) {
         return anyCars[DateTime.now().second % anyCars.length];
      }
      
      return null;
    } catch (e) {
      // Failed to get featured car: $e
      return null;
    }
  }

  /// Lấy danh sách brands
  Future<List<String>> getBrands() async {
    try {
      final response = await _supabase
          .from('brands')
          .select('name')
          .order('name');

      return (response as List).map((b) => b['name'] as String).toList();
    } catch (e) {
      throw Exception('Failed to get brands: $e');
    }
  }

  /// Count số lượng xe
  Future<int> getCarCount() async {
    try {
      final response = await _supabase
          .from('cars')
          .select('id')
          .eq('is_available', true);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }
}
