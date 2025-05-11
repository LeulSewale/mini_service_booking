import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mini_service_booking_app/presentation/controllers/service_controller.dart';
import 'package:mini_service_booking_app/presentation/widgets/service_card.dart';
import 'package:mini_service_booking_app/routes/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = Get.find<ServiceController>();

  final List<String> categories = [
    'All',
    'Cleaning',
    'Repair',
    'Car Wash',
    'Catering'
  ];
  final List<double> ratingOptions = [0.0, 3.0, 4.0, 4.5];

  final ScrollController _scrollController = ScrollController();

  final Map<String, Locale> languages = {
    '🇺🇸 English': const Locale('en', 'US'),
    '🇪🇹 አማርኛ': const Locale('am', 'ET'),
  };

  @override
  void initState() {
    super.initState();
    controller.fetchServices(initial: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !controller.isFetchingMore.value &&
          controller.hasMoreData) {
        controller.fetchServices();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('service_booking_app'.tr),
        actions: [
          _buildLanguageDropdown(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Get.offAllNamed(AppRoutes.login),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            _buildFilters(),
            Expanded(
              child: Card(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.errorMessage.isNotEmpty) {
                    return Center(
                      child: Text(
                        '⚠️ ${controller.errorMessage}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final services = controller.filteredServices;

                  if (services.isEmpty) {
                    return Center(
                      child: Text(
                        'no_services_found'.tr,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return Obx(
                    () => NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        if (!controller.isFetchingMore.value &&
                            controller.hasMoreData &&
                            scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent - 200) {
                          controller.fetchServices();
                        }
                        return false;
                      },
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: services.length +
                            (controller.hasMoreData &&
                                    controller.isFetchingMore.value
                                ? 1
                                : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index < services.length) {
                            final service = services[index];
                            return ServiceCard(
                              service: service,
                              uniqueIndex: index,
                            );
                          } else {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addService),
        backgroundColor: Colors.green,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'search_services'.tr,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 20,
              runSpacing: 10,
              children: [
                // Rating Filter
                SizedBox(
                  width: 150,
                  child: Obx(() {
                    return DropdownButtonFormField<double>(
                      value: controller.selectedRating.value,
                      items: ratingOptions.map((rating) {
                        return DropdownMenuItem(
                          value: rating,
                          child: Text(
                            rating == 0.0
                                ? 'all_ratings'.tr
                                : '$rating+ ${'stars'.tr}',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.setRatingFilter(value);
                          FocusScope.of(context).unfocus(); // Minimize keyboard
                        }
                      },
                      decoration: InputDecoration(
                        labelText: 'rating'.tr,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }),
                ),

                // Price Filter
                SizedBox(
                  width: 150,
                  child: Obx(() {
                    return DropdownButtonFormField<String>(
                      value: controller.selectedPriceRange.value,
                      items: [
                        'All',
                        '< \$50',
                        '\$50 - \$100',
                        '> \$100',
                      ].map((price) {
                        return DropdownMenuItem(
                          value: price,
                          child: Text(price),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) controller.setPriceFilter(value);
                      },
                      decoration: InputDecoration(
                        labelText: 'price'.tr,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }),
                ),
                // Category Filter
                SizedBox(
                  width: 200,
                  child: Obx(() {
                    return DropdownButtonFormField<String>(
                      value: controller.selectedCategory.value.isEmpty
                          ? 'All'
                          : controller.selectedCategory.value,
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.tr),
                        );
                      }).toList(),
                      onChanged: (value) {
                        controller
                            .setCategoryFilter(value == 'All' ? '' : value!);
                      },
                      decoration: InputDecoration(
                        labelText: 'category'.tr,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  }),
                ),
                SizedBox(
                  child: TextButton.icon(
                    onPressed: controller.clearAllFilters,
                    icon: const Icon(Icons.clear),
                    label: Text('clear_filters'.tr),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<Locale>(
        icon: const Icon(Icons.language, color: Colors.green),
        onChanged: (locale) {
          if (locale != null) Get.updateLocale(locale);
        },
        items: languages.entries.map((entry) {
          return DropdownMenuItem<Locale>(
            value: entry.value,
            child: Text(
              entry.key,
              style: TextStyle(color: Colors.green),
            ),
          );
        }).toList(),
      ),
    );
  }
}
