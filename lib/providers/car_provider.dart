import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/car_model.dart';
import '../services/car_service.dart';

/// Provider cho CarService
final carServiceProvider = Provider((ref) => CarService());

/// Provider cho tất cả cars
final carsProvider = FutureProvider<List<Car>>((ref) async {
  final carService = ref.watch(carServiceProvider);
  return await carService.getCars();
});

/// Provider cho featured car - Load độc lập để nhanh hơn
final featuredCarProvider = FutureProvider<Car?>((ref) async {
  final carService = ref.watch(carServiceProvider);
  return await carService.getFeaturedCar();
});

/// Provider cho discovery cars (limit 20)
final discoveryCarsProvider = FutureProvider<List<Car>>((ref) async {
  final carService = ref.watch(carServiceProvider);
  return await carService.getCars(limit: 20);
});

/// Provider cho car by ID (family provider)
final carByIdProvider = FutureProvider.family<Car, String>((ref, carId) async {
  final carService = ref.watch(carServiceProvider);
  return await carService.getCarById(carId);
});

/// Provider cho search query
final carSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider cho search results
final carSearchResultsProvider = FutureProvider<List<Car>>((ref) async {
  final query = ref.watch(carSearchQueryProvider);
  if (query.isEmpty) return [];
  
  final carService = ref.watch(carServiceProvider);
  return await carService.searchCars(query);
});

/// Provider cho brands list
final brandsProvider = FutureProvider<List<String>>((ref) async {
  final carService = ref.watch(carServiceProvider);
  return await carService.getBrands();
});

/// Provider cho car count
final carCountProvider = FutureProvider<int>((ref) async {
  final carService = ref.watch(carServiceProvider);
  return await carService.getCarCount();
});

/// Provider cho cars by brand (family provider)
final carsByBrandProvider = FutureProvider.family<List<Car>, String>((ref, brandName) async {
  final carService = ref.watch(carServiceProvider);
  return await carService.getCars(brandName: brandName);
});
