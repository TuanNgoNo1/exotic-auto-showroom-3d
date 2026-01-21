import 'package:flutter/material.dart';

class Car {
  final String id;
  final String name;
  final String brand;
  final String price;
  final String imageUrl;
  final String description;
  final Map<String, String> specs;
  final List<Color> colors;
  
  // ===== 3D MODEL FIELDS =====
  final String? model3DExteriorUrl;
  final String? model3DInteriorUrl;
  final double? modelFileSizeMB;
  final bool modelOptimized;
  
  // ===== PANORAMA 360 FIELDS =====
  final String? panoramaInteriorUrl; // URL cho ảnh panorama 360° của nội thất
  
  // ===== INTERIOR GALLERY =====
  final List<String> interiorImages; // Danh sách URL ảnh nội thất
  
  // ===== MATERIAL FOR COLOR CHANGE =====
  final String? bodyMaterialName; // Tên material của phần thân xe trong model 3D

  const Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.specs,
    required this.colors,
    this.model3DExteriorUrl,
    this.model3DInteriorUrl,
    this.modelFileSizeMB,
    this.modelOptimized = false,
    this.panoramaInteriorUrl,
    this.interiorImages = const [],
    this.bodyMaterialName,
  });

  // ====== JSON SERIALIZATION ======
  
  /// Tạo Car object từ JSON data của Supabase
  /// Note: specs và colors sẽ được load riêng từ related tables
  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand_name'] as String? ?? json['brand'] as String? ?? '',
      price: _formatPrice(json['price']),
      imageUrl: json['image_url'] as String? ?? '',
      description: json['description'] as String? ?? '',
      specs: {}, // Sẽ được load riêng qua _loadCarDetails
      colors: [], // Sẽ được load riêng qua _loadCarDetails
      model3DExteriorUrl: json['model_3d_exterior_url'] as String?,
      model3DInteriorUrl: json['model_3d_interior_url'] as String?,
      modelFileSizeMB: json['model_file_size_mb'] != null 
          ? (json['model_file_size_mb'] as num).toDouble()
          : null,
      modelOptimized: json['model_optimized'] as bool? ?? false,
      panoramaInteriorUrl: json['panorama_interior_url'] as String?,
      interiorImages: [], // Sẽ được load riêng từ car_interior_images table
      bodyMaterialName: json['body_material_name'] as String?,
    );
  }

  /// Convert price từ database (decimal) sang String format
  static String _formatPrice(dynamic price) {
    if (price == null) return '\$0';
    
    final numPrice = price is num ? price : double.tryParse(price.toString()) ?? 0;
    
    // Format: $83,000
    return '\$${numPrice.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  /// Convert Car object sang JSON (để gửi lên Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'price': double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0,
      'image_url': imageUrl,
      'description': description,
      'model_3d_exterior_url': model3DExteriorUrl,
      'model_3d_interior_url': model3DInteriorUrl,
      'model_file_size_mb': modelFileSizeMB,
      'model_optimized': modelOptimized,
      'panorama_interior_url': panoramaInteriorUrl,
      'body_material_name': bodyMaterialName,
    };
  }

  // Helper methods
  bool get has3DModel => model3DExteriorUrl != null && model3DExteriorUrl!.isNotEmpty;
  bool get hasInteriorModel => model3DInteriorUrl != null && model3DInteriorUrl!.isNotEmpty;
  bool get hasPanorama => panoramaInteriorUrl != null && panoramaInteriorUrl!.isNotEmpty;
  bool get hasInteriorImages => interiorImages.isNotEmpty;
  bool get canChangeColor => bodyMaterialName != null && bodyMaterialName!.isNotEmpty;
  
  String get modelSizeText {
    if (modelFileSizeMB == null) return '';
    return '${modelFileSizeMB!.toStringAsFixed(1)} MB';
  }

  // Copy with method for updating
  Car copyWith({
    String? id,
    String? name,
    String? brand,
    String? price,
    String? imageUrl,
    String? description,
    Map<String, String>? specs,
    List<Color>? colors,
    String? model3DExteriorUrl,
    String? model3DInteriorUrl,
    double? modelFileSizeMB,
    bool? modelOptimized,
    String? panoramaInteriorUrl,
    List<String>? interiorImages,
    String? bodyMaterialName,
  }) {
    return Car(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      specs: specs ?? this.specs,
      colors: colors ?? this.colors,
      model3DExteriorUrl: model3DExteriorUrl ?? this.model3DExteriorUrl,
      model3DInteriorUrl: model3DInteriorUrl ?? this.model3DInteriorUrl,
      modelFileSizeMB: modelFileSizeMB ?? this.modelFileSizeMB,
      modelOptimized: modelOptimized ?? this.modelOptimized,
      panoramaInteriorUrl: panoramaInteriorUrl ?? this.panoramaInteriorUrl,
      interiorImages: interiorImages ?? this.interiorImages,
      bodyMaterialName: bodyMaterialName ?? this.bodyMaterialName,
    );
  }
}
