import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../models/car_model.dart';
import '../services/storage_service.dart';

/// Widget để hiển thị 3D model của xe
/// 
/// Features:
/// - Auto-rotate
/// - Camera controls (zoom, pan, rotate)
/// - AR mode support
/// - Loading state
/// - Error handling with fallback UI
/// - **Realtime color change**
class Car3DViewer extends StatefulWidget {
  final Car car;
  final bool showInterior;
  final Color? selectedColor;

  const Car3DViewer({
    super.key,
    required this.car,
    this.showInterior = false,
    this.selectedColor,
  });

  @override
  State<Car3DViewer> createState() => Car3DViewerState();
}

class Car3DViewerState extends State<Car3DViewer> {
  final _storageService = StorageService();
  bool _isLoading = true;
  String? _modelUrl;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  @override
  void didUpdateWidget(Car3DViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload model nếu car hoặc showInterior thay đổi
    if (oldWidget.car.id != widget.car.id || 
        oldWidget.showInterior != widget.showInterior) {
      _loadModel();
    }
  }

  void _loadModel() {
    setState(() {
      _isLoading = true;
    });

    // Lấy path của model từ car data
    final modelPath = widget.showInterior
        ? widget.car.model3DInteriorUrl
        : widget.car.model3DExteriorUrl;

    if (modelPath != null && modelPath.isNotEmpty) {
      // Nếu đã là full URL (bắt đầu bằng http) thì dùng trực tiếp
      if (modelPath.startsWith('http')) {
        _modelUrl = modelPath;
      } else {
        // Nếu chỉ là path thì lấy full URL từ StorageService
        _modelUrl = _storageService.get3DModelUrl(modelPath);
      }
    } else {
      _modelUrl = null;
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// Tạo JavaScript để thay đổi màu material
  String _generateColorChangeScript() {
    if (widget.selectedColor == null) {
      return '';
    }

    // Nếu có tên material cụ thể thì dùng, không thì dùng heuristic
    final materialName = widget.car.bodyMaterialName ?? '';
    final color = widget.selectedColor!;
    
    // Chuyển đổi màu sang giá trị 0-1 cho WebGL
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;
    
    return '''
      (function() {
        function applyColor() {
          const modelViewer = document.querySelector('model-viewer');
          if (!modelViewer || !modelViewer.model) return false;
          
          const materials = modelViewer.model.materials;
          let applied = false;
          
          for (let i = 0; i < materials.length; i++) {
            const mat = materials[i];
            const matName = mat.name.toLowerCase();
            
            // Logic tìm material:
            // 1. Theo tên chính xác (nếu có config)
            // 2. Theo các từ khóa thông dụng
            if ((mat.name === '$materialName' && '$materialName' !== '') || 
                matName.includes('body') ||
                matName.includes('paint') ||
                matName.includes('car') ||
                matName.includes('exterior') ||
                matName.includes('metal') ||
                matName.includes('shell') ||
                matName.includes('main') ||
                matName.includes('color')) {
              
              try {
                console.log('Found body material:', mat.name);
                mat.pbrMetallicRoughness.setBaseColorFactor([$r, $g, $b, 1.0]);
                applied = true;
              } catch(e) {
                console.error('Error applying color to ' + mat.name, e);
              }
            }
          }
          return applied;
        }
        
        // Thử apply ngay
        if (!applyColor()) {
          const mv = document.querySelector('model-viewer');
          if (mv) {
            mv.addEventListener('load', function() {
              console.log('Model loaded, applying color...');
              setTimeout(applyColor, 100);
              setTimeout(applyColor, 500);
              setTimeout(applyColor, 1000); // Retry longer
            });
          }
        }
        // Retry flows
        setTimeout(applyColor, 200);
        setTimeout(applyColor, 600);
        setTimeout(applyColor, 1200);
      })();
    ''';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
            ),
            const SizedBox(height: 16),
            Text(
              'Đang tải mô hình 3D...',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            if (widget.car.modelFileSizeMB != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  widget.car.modelSizeText,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (_modelUrl == null || _modelUrl!.isEmpty) {
      return _buildNoModelUI();
    }

    final colorScript = _generateColorChangeScript();
    const backgroundUrl = 'https://bitcftoahotylexzjxaa.supabase.co/storage/v1/object/public/backgrounds/grid-black-bg.jpg';
    
    // Tạo unique key dựa trên màu để force rebuild ModelViewer khi đổi màu
    final colorKey = widget.selectedColor?.value ?? 0;
    
    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: Image.network(
            backgroundUrl,
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.3),
            colorBlendMode: BlendMode.darken,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
          ),
        ),
        
        // 3D Model Viewer - rebuild khi màu thay đổi
        ModelViewer(
          key: ValueKey('model_${widget.car.id}_$colorKey'),
          src: _modelUrl!,
          alt: '${widget.car.name} 3D Model',
          loading: Loading.eager,
          autoRotate: true,
          autoRotateDelay: 0,
          rotationPerSecond: '30deg',
          cameraControls: true,
          disablePan: true,
          touchAction: TouchAction.panY,
          backgroundColor: Colors.transparent,
          environmentImage: 'https://modelviewer.dev/shared-assets/environments/neutral.hdr',
          exposure: 1.0,
          shadowIntensity: 0.8,
          shadowSoftness: 1.0,
          cameraOrbit: '0deg 75deg 75%',
          minCameraOrbit: 'auto 30deg 50%',
          maxCameraOrbit: 'auto 120deg 150%',
          interactionPrompt: InteractionPrompt.auto,
          interactionPromptThreshold: 3000,
          relatedJs: colorScript.isNotEmpty ? colorScript : null,
        ),
        
        // Badge hiển thị loại model
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.showInterior ? Icons.dashboard : Icons.directions_car,
                  color: const Color(0xFFFFD700),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.showInterior ? 'Nội thất' : 'Ngoại thất',
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoModelUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.view_in_ar_outlined,
            size: 80,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          Text(
            'Mô hình 3D không khả dụng',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.showInterior
                ? 'Mô hình nội thất đang được cập nhật'
                : 'Mô hình ngoại thất đang được cập nhật',
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
