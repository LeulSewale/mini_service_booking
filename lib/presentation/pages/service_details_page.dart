import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/service_controller.dart';

class ServiceDetailsPage extends StatelessWidget {
  final String serviceId;
  final controller = Get.find<ServiceController>();

  ServiceDetailsPage({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    final service = controller.getServiceById(serviceId);

    if (service == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Service Details')),
        body: const Center(child: Text('Service not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(service.name),
        centerTitle: true,
      ),
      body: Card(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Image with fallback
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Hero(
                  tag:
                      Get.arguments['heroTag'] ?? 'service-image-${service.id}',
                  child: service.imageUrl.isURL
                      ? Image.network(
                          service.imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 80),
                          ),
                        )
                      : Container(
                          height: 200,
                          color: Colors.grey[300],
                          child:
                              const Icon(Icons.image_not_supported, size: 80),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Info card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Category', service.category),
                      _buildInfoRow('Price', '\$${service.price}'),
                      _buildInfoRow('Rating', '${service.rating} ★'),
                      _buildInfoRow('Duration', '${service.duration} mins'),
                      _buildInfoRow('Availability',
                          service.availability ? 'Available' : 'Not Available'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

                ElevatedButton.icon(
                onPressed: () => Get.toNamed('/edit-service/${service.id}'),
                icon: const Icon(Icons.edit),
                label: Text('editService'.tr,
                  style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.green, // Added green color
                ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text('$title:',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
