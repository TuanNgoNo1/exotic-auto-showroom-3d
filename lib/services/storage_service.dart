import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service để quản lý Storage (upload/download files) từ Supabase
/// 
/// Chức năng chính:
/// - Upload avatar của user
/// - Delete avatar cũ
/// - Lấy URL của hình ảnh xe
/// - Upload/download 3D models (GLB files)
class StorageService {
  final _supabase = Supabase.instance.client;

  // ==========================================
  // USER AVATARS
  // ==========================================

  /// Upload avatar của user lên Supabase Storage
  /// 
  /// [imageFile]: File ảnh từ ImagePicker
  /// [userId]: ID của user (từ auth.currentUser.id)
  /// 
  /// Returns: Public URL của avatar đã upload
  Future<String> uploadAvatar(File imageFile, String userId) async {
    try {
      // Tạo tên file unique bằng timestamp
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '$userId/$fileName';

      // Upload file lên bucket 'user-avatars'
      await _supabase.storage
          .from('user-avatars')
          .upload(path, imageFile);

      // Lấy public URL của file vừa upload
      final url = _supabase.storage
          .from('user-avatars')
          .getPublicUrl(path);

      return url;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  /// Xóa avatar cũ của user
  /// 
  /// [filePath]: Path của file cần xóa (format: 'userId/avatar_xxx.jpg')
  Future<void> deleteAvatar(String filePath) async {
    try {
      await _supabase.storage
          .from('user-avatars')
          .remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete avatar: $e');
    }
  }

  // ==========================================
  // CAR IMAGES
  // ==========================================

  /// Lấy public URL của hình ảnh xe
  /// 
  /// [imagePath]: Path trong bucket 'car-images' 
  /// Ví dụ: 'vinfast/vf8.jpg'
  /// 
  /// Returns: Full public URL để dùng trong Image.network()
  String getCarImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    
    return _supabase.storage
        .from('car-images')
        .getPublicUrl(imagePath);
  }

  /// Upload hình ảnh xe (CHỈ DÙNG TRONG ADMIN PANEL)
  /// ⚠️ KHÔNG gọi function này từ client app
  /// 
  /// [imageFile]: File hình ảnh
  /// [path]: Path để lưu (ví dụ: 'vinfast/vf8_front.jpg')
  Future<String> uploadCarImage(File imageFile, String path) async {
    try {
      await _supabase.storage
          .from('car-images')
          .upload(path, imageFile);

      return getCarImageUrl(path);
    } catch (e) {
      throw Exception('Failed to upload car image: $e');
    }
  }

  // ==========================================
  // 3D MODELS (GLB FILES)
  // ==========================================

  /// Lấy full URL cho 3D model exterior
  /// 
  /// [modelPath]: Path trong bucket '3d-models'
  /// Ví dụ: 'vinfast/vf9_exterior.glb'
  String get3DModelUrl(String? modelPath) {
    if (modelPath == null || modelPath.isEmpty) {
      return '';
    }
    
    return _supabase.storage
        .from('3d-models')
        .getPublicUrl(modelPath);
  }

  /// Lấy full URL cho 3D model interior
  String getInterior3DModelUrl(String? modelPath) {
    if (modelPath == null || modelPath.isEmpty) {
      return '';
    }
    
    return _supabase.storage
        .from('3d-models')
        .getPublicUrl(modelPath);
  }

  /// Upload 3D model (Admin only - requires service_role key)
  /// ⚠️ Chỉ dùng trong admin panel, KHÔNG gọi từ client app
  /// 
  /// [modelFile]: File GLB
  /// [brandName]: Tên hãng xe (để tổ chức folder)
  /// [modelName]: Tên model (vd: 'vf8')
  /// [isInterior]: true nếu là interior, false nếu là exterior
  Future<String> upload3DModel({
    required File modelFile,
    required String brandName,
    required String modelName,
    required bool isInterior,
  }) async {
    try {
      final fileName = '${modelName}_${isInterior ? 'interior' : 'exterior'}.glb';
      final path = '${brandName.toLowerCase()}/$fileName';

      await _supabase.storage
          .from('3d-models')
          .upload(path, modelFile);

      return path;
    } catch (e) {
      throw Exception('Failed to upload 3D model: $e');
    }
  }

  /// Kiểm tra xem 3D model có tồn tại không
  Future<bool> model3DExists(String modelPath) async {
    try {
      final response = await _supabase.storage
          .from('3d-models')
          .list(path: modelPath);
      
      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Download 3D model để cache locally (optional)
  /// 
  /// Returns: Bytes của file GLB
  Future<List<int>> download3DModel(String modelPath) async {
    try {
      final bytes = await _supabase.storage
          .from('3d-models')
          .download(modelPath);
      
      return bytes;
    } catch (e) {
      throw Exception('Failed to download 3D model: $e');
    }
  }

  // ==========================================
  // HELPER METHODS
  // ==========================================

  /// Lấy thông tin file (size, created_at, etc.)
  Future<FileObject?> getFileMetadata({
    required String bucket,
    required String path,
  }) async {
    try {
      final files = await _supabase.storage.from(bucket).list(path: path);
      return files.isNotEmpty ? files.first : null;
    } catch (e) {
      return null;
    }
  }

  /// Xóa nhiều files cùng lúc
  Future<void> deleteMultipleFiles({
    required String bucket,
    required List<String> paths,
  }) async {
    try {
      await _supabase.storage.from(bucket).remove(paths);
    } catch (e) {
      throw Exception('Failed to delete files: $e');
    }
  }

  /// List tất cả files trong một folder
  Future<List<FileObject>> listFiles({
    required String bucket,
    String? folder,
  }) async {
    try {
      return await _supabase.storage.from(bucket).list(path: folder);
    } catch (e) {
      throw Exception('Failed to list files: $e');
    }
  }
}
