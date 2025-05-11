import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:mini_service_booking_app/core/utils/network_checker.dart';
import 'package:mini_service_booking_app/core/utils/snackbar_util.dart';
import 'package:mini_service_booking_app/data/models/service_model.dart';
import 'package:mini_service_booking_app/data/services/api_service.dart';

class ServiceController extends GetxController {
  final Box<ServiceModel> servicesBox = Hive.box<ServiceModel>('servicesBox');
  // API service
  final ApiService apiService = ApiService();
  // Master service list from API
  var services = <ServiceModel>[].obs;
  // Filtered result list
  var filteredServices = <ServiceModel>[].obs;

  // Loading and error states
  var isLoading = false.obs;
  var isFetchingMore = false.obs;
  var errorMessage = ''.obs;

  // Filters
  var searchQuery = ''.obs;
  var selectedCategory = ''.obs;
  var selectedRating = 0.0.obs;
  var selectedPriceRange = 'All'.obs;
  int _page = 1;
  final int _limit = 10;
  bool hasMoreData = true;

  @override
  void onInit() {
    super.onInit();
    fetchServices(initial: true);
    everAll([
      searchQuery,
      selectedCategory,
      selectedRating,
      selectedPriceRange,
    ], (_) {
      resetPagination();
      applyFilters();
    });
  }

  void resetPagination() {
    _page = 1;
    hasMoreData = true;
    services.clear();
    filteredServices.clear();
    fetchServices(initial: true);
  }

  Future<void> fetchServices({bool initial = false}) async {
    if (isLoading.value || isFetchingMore.value || !hasMoreData) return;

    final Box<ServiceModel> servicesBox = Hive.box<ServiceModel>('servicesBox');

    final bool hasInternet = await NetworkChecker.hasInternetConnection();

    if (!hasInternet) {
      if (servicesBox.isNotEmpty) {
        services.assignAll(servicesBox.values.toList());
        applyFilters();
        SnackbarUtil.showSuccess('Loaded services from offline cache');
      } else {
        errorMessage.value = 'No internet connection and no cached data';
        SnackbarUtil.showError(errorMessage.value);
      }
      return;
    }

    if (initial) {
      isLoading.value = true;
    } else {
      isFetchingMore.value = true;
    }

    try {
      final newServices =
          await apiService.getServices(page: _page, limit: _limit);

      if (newServices.isEmpty) {
        hasMoreData = false;
      } else {
        final uniqueNewServices = newServices
            .where(
              (newItem) =>
                  !services.any((existing) => existing.id == newItem.id),
            )
            .toList();

        services.addAll(uniqueNewServices);

        if (initial) {
          await servicesBox.clear();
          await servicesBox.addAll(services);
        }

        _page++;
      }

      applyFilters();
      errorMessage.value = '';
    } catch (e) {
      errorMessage.value = 'Error fetching services: $e';
      SnackbarUtil.showError(errorMessage.value);
    } finally {
      isLoading.value = false;
      isFetchingMore.value = false;
    }
  }

  // Apply filters
  void applyFilters() {
    final query = searchQuery.value.toLowerCase();
    final category = selectedCategory.value;
    final rating = selectedRating.value;
    final priceRange = selectedPriceRange.value;

    final filtered = services.where((service) {
      final matchesSearch = service.name.toLowerCase().contains(query);
      final matchesCategory = category.isEmpty || service.category == category;
      final matchesRating = rating == 0.0 || service.rating >= rating;

      final price = service.price;
      final matchesPrice = priceRange == 'All' ||
          (priceRange == '< \$50' && price < 50) ||
          (priceRange == '\$50 - \$100' && price >= 50 && price <= 100) ||
          (priceRange == '> \$100' && price > 100);

      return matchesSearch && matchesCategory && matchesRating && matchesPrice;
    }).toList();

    filteredServices.assignAll(filtered);
  }

  // Filter setters
  void setSearchQuery(String query) => searchQuery.value = query;
  void setCategoryFilter(String category) => selectedCategory.value = category;
  void setRatingFilter(double rating) => selectedRating.value = rating;
  void setPriceFilter(String priceRange) =>
      selectedPriceRange.value = priceRange;

  void clearAllFilters() {
    searchQuery.value = '';
    selectedCategory.value = '';
    selectedRating.value = 0.0;
    selectedPriceRange.value = 'All';
    applyFilters();
  }

  // CRUD OPERATIONS

  Future<void> addService(
    String name,
    String category,
    String imageUrl,
    double price,
    double rating,
    String duration,
    bool availability,
  ) async {
    if (!(await NetworkChecker.hasInternetConnection())) {
      errorMessage.value = 'No internet connection';
      SnackbarUtil.showError(errorMessage.value);
      return;
    }

    try {
      final newService = await apiService.createService(
          name, category, imageUrl, price, rating, duration, availability);
      services.add(newService);
      applyFilters();
      errorMessage.value = '';
      SnackbarUtil.showSuccess('Service added successfully');
    } catch (e) {
      errorMessage.value = 'Error adding service: $e';
      SnackbarUtil.showError(errorMessage.value);
    }
  }

  Future<void> editService(
    String id,
    String name,
    String category,
    String imageUrl,
    double price,
    double rating,
    String duration,
    bool availability,
  ) async {
    if (!(await NetworkChecker.hasInternetConnection())) {
      errorMessage.value = 'No internet connection';
      SnackbarUtil.showError(errorMessage.value);
      return;
    }

    try {
      final updated = await apiService.updateService(
          id, name, category, imageUrl, price, rating, duration, availability);
      final index = services.indexWhere((s) => s.id == id);
      if (index != -1) {
        services[index] = updated;
        applyFilters();
      }
      errorMessage.value = '';
      SnackbarUtil.showSuccess('Service updated successfully');
    } catch (e) {
      errorMessage.value = 'Error editing service: $e';
      SnackbarUtil.showError(errorMessage.value);
    }
  }

  Future<void> deleteService(String id) async {
    if (!(await NetworkChecker.hasInternetConnection())) {
      errorMessage.value = 'No internet connection';
      SnackbarUtil.showError(errorMessage.value);
      return;
    }

    try {
      await apiService.deleteService(id);
      services.removeWhere((s) => s.id == id);
      applyFilters();
      SnackbarUtil.showSuccess('Service deleted successfully');
    } catch (e) {
      errorMessage.value = 'Error deleting service: $e';
      SnackbarUtil.showError(errorMessage.value);
    }
  }

  ServiceModel? getServiceById(String id) {
    return services.firstWhereOrNull((s) => s.id == id);
  }
}
