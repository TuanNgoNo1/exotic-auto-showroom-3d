import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../providers/car_provider.dart';
import 'home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _dataLoaded = false;
  bool _minTimeElapsed = false;

  @override
  void initState() {
    super.initState();
    
    // Animation controller cho zoom in/out
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Scale animation: 0.8 -> 1.2 -> 1.0 (zoom in/out effect)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    // Repeat animation 2 lần
    _controller.repeat();

    // Minimum splash time (2.5 giây)
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() => _minTimeElapsed = true);
        _checkAndNavigate();
      }
    });

    // Preload data
    _preloadData();
  }

  Future<void> _preloadData() async {
    try {
      // Preload featured car và cars list
      await ref.read(featuredCarProvider.future);
      await ref.read(carsProvider.future);
    } catch (e) {
      // Ignore errors, app will show error state in home screen
      debugPrint('Preload error: $e');
    } finally {
      if (mounted) {
        setState(() => _dataLoaded = true);
        _checkAndNavigate();
      }
    }
  }

  void _checkAndNavigate() {
    if (_dataLoaded && _minTimeElapsed && mounted) {
      _controller.stop();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        // Chỉ có logo ở giữa màn hình
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Image.asset(
            'assets/icons/splash_logo.png',
            width: 180,
            height: 180,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
