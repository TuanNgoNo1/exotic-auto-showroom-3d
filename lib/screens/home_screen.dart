import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/car_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/garage_provider.dart';
import '../providers/recently_viewed_provider.dart';
import '../widgets/featured_car_card.dart';
import '../widgets/car_list_item.dart';
import '../core/theme/app_theme.dart';
import 'garage_screen.dart';
import 'discovery_screen.dart';
import 'profile_screen.dart';
import 'car_detail_screen.dart';
import 'auth/login_screen.dart';

import '../widgets/custom_bottom_navigation.dart';
import '../widgets/shimmer_loading.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const HomeContent(),
    const DiscoveryScreen(),
    const GarageScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildQuickStats(BuildContext context, WidgetRef ref) {
    final garageAsync = ref.watch(garageProvider);
    final recentlyViewed = ref.watch(recentlyViewedProvider);
    final carsAsync = ref.watch(carsProvider);
    
    final garageCount = garageAsync.maybeWhen(
      data: (cars) => cars.length,
      orElse: () => 0,
    );
    final totalCars = carsAsync.maybeWhen(
      data: (cars) => cars.length,
      orElse: () => 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thống kê nhanh',
          style: Theme.of(context).textTheme.titleLarge,
        ).animate().fadeIn(delay: 500.ms),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.garage,
                value: garageCount.toString(),
                label: 'Trong Garage',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.visibility,
                value: recentlyViewed.length.toString(),
                label: 'Đã xem',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.directions_car,
                value: totalCars.toString(),
                label: 'Tổng xe',
                color: Colors.green,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.1, end: 0),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentlyViewed(BuildContext context, WidgetRef ref) {
    final recentlyViewed = ref.watch(recentlyViewedProvider);
    
    if (recentlyViewed.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Đã xem gần đây',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (recentlyViewed.length > 3)
              TextButton(
                onPressed: () {
                  // Có thể mở màn hình xem tất cả
                },
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(color: AppColors.primary, fontSize: 12),
                ),
              ),
          ],
        ).animate().fadeIn(delay: 600.ms),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: recentlyViewed.length > 5 ? 5 : recentlyViewed.length,
            itemBuilder: (context, index) {
              final car = recentlyViewed[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CarDetailScreen(car: car)),
                  );
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            car.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[900],
                              child: const Icon(Icons.car_repair, color: Colors.white24),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          car.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (650 + (index * 50)).ms).slideX();
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carsAsync = ref.watch(carsProvider);
    final featuredCarAsync = ref.watch(featuredCarProvider);
    final userAsync = ref.watch(currentUserProvider);

    // Lấy thông tin user
    final user = userAsync.valueOrNull;
    final userName = user?.userMetadata?['full_name'] as String? ?? 
                     user?.email?.split('@').first ?? 
                     'Guest';
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user != null ? 'WELCOME BACK' : 'WELCOME',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Greeting text
                    Text(
                      _getGreeting(),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    // User name - cho phép xuống dòng nếu dài
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 110,
                      child: Text(
                        userName,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: const Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    if (user == null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    } else {
                      // Chuyển đến Profile screen (tab index 3)
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 3)),
                      );
                    }
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5), width: 1),
                      color: avatarUrl == null ? AppColors.surface : null,
                      image: avatarUrl != null
                          ? DecorationImage(
                              image: NetworkImage(avatarUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: avatarUrl == null
                        ? Icon(
                            user != null ? Icons.person : Icons.login,
                            color: AppColors.primary,
                            size: 24,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideX(),
          
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    
                    const SizedBox(height: 24),
                    
                    // Featured Car - Từ Supabase
                    featuredCarAsync.when(
                      data: (car) => car != null
                          ? FeaturedCarCard(car: car)
                              .animate()
                              .fadeIn(delay: 200.ms)
                              .scale()
                          : const SizedBox.shrink(),
                      loading: () => const FeaturedCarShimmer(),
                      error: (error, stack) => Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 40),
                              const SizedBox(height: 8),
                              Text('Lỗi: $error', style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Featured Models List - Từ Supabase
                    Text(
                      'Các Mẫu Xe Nổi Bật',
                      style: Theme.of(context).textTheme.titleLarge,
                    ).animate().fadeIn(delay: 400.ms),
                    
                    const SizedBox(height: 16),
                    
                    // Cars List - Từ Supabase
                    carsAsync.when(
                      data: (cars) => SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: cars.length,
                          itemBuilder: (context, index) {
                            return CarListItem(car: cars[index])
                                .animate()
                                .fadeIn(delay: (400 + (index * 100)).ms)
                                .slideX();
                          },
                        ),
                      ),
                      loading: () => const CarListShimmer(),
                      error: (error, stack) => SizedBox(
                        height: 180,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(height: 8),
                              Text('Lỗi tải xe: $error', 
                                style: const TextStyle(color: Colors.white, fontSize: 12)),
                              TextButton(
                                onPressed: () => ref.refresh(carsProvider),
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Quick Stats
                    _buildQuickStats(context, ref),
                    
                    const SizedBox(height: 32),
                    
                    // Recently Viewed
                    _buildRecentlyViewed(context, ref),
                    
                    const SizedBox(height: 100), // Bottom padding for nav bar
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
