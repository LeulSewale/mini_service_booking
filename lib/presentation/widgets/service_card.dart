import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/service_controller.dart';
import '../../data/models/service_model.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final int uniqueIndex; // Add this to ensure unique Hero tags
  final ServiceController controller = Get.find();

  ServiceCard({super.key, required this.service, required this.uniqueIndex});

  @override
  Widget build(BuildContext context) {
    final heroTag = 'service-image-${service.id}'; // Remove -$uniqueIndex

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => Get.toNamed('/service/${service.id}',
            arguments: {'heroTag': heroTag}),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Hero(
            tag: heroTag,
            child: SizedBox(
              width: 60,
              height: 60,
              child: service.imageUrl.isURL
                  ? Image.network(
                      service.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 40),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                            child: CircularProgressIndicator(strokeWidth: 2));
                      },
                    )
                  : const Icon(Icons.image_not_supported, size: 40),
            ),
          ),
        ),
        title: Text(service.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(service.category),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => Get.toNamed('/edit-service/${service.id}'),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                Get.defaultDialog(
                  title: 'deleteService'.tr,
                  middleText:
                      'Are you sure you want to delete "${service.name}"?',
                  textCancel: 'cancel'.tr,
                  textConfirm: 'delete'.tr,
                  confirmTextColor: Colors.white,
                  onConfirm: () {
                    controller.deleteService(service.id);
                    Get.back(); // close dialog
                  },
                  contentPadding: const EdgeInsets.all(20), // Add padding
                  radius: 10, // Optional: Add rounded corners
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
