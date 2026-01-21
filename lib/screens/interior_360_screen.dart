import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:panorama_viewer/panorama_viewer.dart';
import '../core/theme/app_theme.dart';
import '../models/car_model.dart';

/// Screen hiển thị nội thất 360° bằng ảnh panorama
///
/// Features:
/// - Xem ảnh panorama 360° của nội thất xe
/// - Có thể vuốt để xoay xem khắp bên trong xe
/// - Controls để chuyển đổi giữa các góc nhìn (Driver, Passenger, Rear)
class Interior360Screen extends StatefulWidget {
  final Car car;

  const Interior360Screen({super.key, required this.car});

  @override
  State<Interior360Screen> createState() => _Interior360ScreenState();
}

class _Interior360ScreenState extends State<Interior360Screen> {
  int _selectedView = 0; // 0: Driver, 1: Passenger, 2: Rear
  bool _isLoading = true;
  String? _errorMessage;
  ImageProvider? _panoramaImage;

  @override
  void initState() {
    super.initState();
    _preloadPanoramaImage();
  }

  @override
  void didUpdateWidget(Interior360Screen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.car.panoramaInteriorUrl != widget.car.panoramaInteriorUrl) {
      _preloadPanoramaImage();
    }
  }

  /// Pre-load ảnh panorama trước khi render để tránh lỗi "did not find frame"
  Future<void> _preloadPanoramaImage() async {
    if (!widget.car.hasPanorama) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Không có ảnh panorama';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _panoramaImage = null;
    });

    try {
      final url = widget.car.panoramaInteriorUrl!;
      final imageProvider = NetworkImage(url);
      
      // Pre-cache image - đợi ảnh load xong hoàn toàn
      final ImageStream stream = imageProvider.resolve(ImageConfiguration.empty);
      final completer = Completer<void>();
      
      late ImageStreamListener listener;
      listener = ImageStreamListener(
        (ImageInfo info, bool sync) {
          if (!completer.isCompleted) {
            completer.complete();
          }
          stream.removeListener(listener);
        },
        onError: (Object error, StackTrace? stackTrace) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
          stream.removeListener(listener);
        },
      );
      
      stream.addListener(listener);
      await completer.future;

      if (mounted) {
        setState(() {
          _panoramaImage = imageProvider;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Không thể tải ảnh panorama: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Panorama Viewer - chỉ render khi ảnh đã load xong
          if (!_isLoading && _panoramaImage != null && _errorMessage == null)
            PanoramaViewer(
              key: Key('panorama_$_selectedView'),
              child: Image(
                image: _panoramaImage!,
                fit: BoxFit.cover,
              ),
            )
          else if (!_isLoading && (_errorMessage != null || !widget.car.hasPanorama))
            _buildNoPanoramaUI()
          else
            const SizedBox.shrink(), // Placeholder khi đang loading

          // Loading overlay
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Đang tải ảnh panorama...',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Gradient overlay phía trên dưới - IgnorePointer để không chặn touch events
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.0, 0.15, 0.75, 1.0],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Row(
                          children: [
                            const Icon(Icons.arrow_back_ios,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Quay lại',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nội thất 360°',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                fontSize: 28,
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.car.name,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: const Color(0xFFFFD700),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Instructions hint
                if (!_isLoading && widget.car.hasPanorama)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.swipe,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Vuốt để xoay xem 360°',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlItem(
    BuildContext context,
    IconData icon,
    String label, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : Colors.white54,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : Colors.white54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPanoramaUI() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.threesixty,
              size: 80,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 16),
            Text(
              'Ảnh panorama không khả dụng',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ảnh nội thất 360° đang được cập nhật',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Fallback: show regular car image
            if (widget.car.imageUrl.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.car.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
