import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/service_controller.dart';

class EditServicePage extends StatefulWidget {
  final String serviceId;

  const EditServicePage({Key? key, required this.serviceId}) : super(key: key);

  @override
  State<EditServicePage> createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
  final _formKey = GlobalKey<FormState>();
  final ServiceController controller = Get.find();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  String? availability;

  bool isFormValid = true;

  void _validateForm() {
    setState(() {
      isFormValid =
          _formKey.currentState?.validate() == true && availability != null;
    });
  }

  @override
  void initState() {
    super.initState();
    final service = controller.getServiceById(widget.serviceId);
    if (service != null) {
      nameController.text = service.name;
      categoryController.text = service.category;
      imageUrlController.text = service.imageUrl;
      priceController.text = service.price.toString();
      ratingController.text = service.rating.toString();
      durationController.text = service.duration;
      availability = service.availability ? 'Available' : 'Not Available';
    } else {
      Get.snackbar('error'.tr, 'service_not_found'.tr);
    }
  }

  void _saveChanges() {
    if (_formKey.currentState?.validate() != true || availability == null)
      return;

    controller.editService(
      widget.serviceId,
      nameController.text.trim(),
      categoryController.text.trim(),
      imageUrlController.text.trim(),
      double.tryParse(priceController.text.trim()) ?? 0.0,
      double.tryParse(ratingController.text.trim()) ?? 0.0,
      durationController.text.trim(),
      availability == 'Available',
    );
    Get.back();
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label.tr,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
          validator: validator,
          onChanged: (_) => _validateForm(),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    const categories = ['Cleaning', 'Repair', 'Car Wash', 'Catering'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value:
            categoryController.text.isNotEmpty ? categoryController.text : null,
        decoration: InputDecoration(
          labelText: 'category'.tr,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        items: categories.map((cat) {
          return DropdownMenuItem(
            value: cat,
            child: Text(cat.tr),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            categoryController.text = value!;
          });
          _validateForm();
        },
        validator: (value) =>
            value == null ? 'please_select_category'.tr : null,
      ),
    );
  }

  Widget _buildAvailabilityDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: availability,
        decoration: InputDecoration(
          labelText: 'availability'.tr,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        items: const [
          DropdownMenuItem(value: 'Available', child: Text('Available')),
          DropdownMenuItem(
              value: 'Not Available', child: Text('Not Available')),
        ],
        onChanged: (value) {
          setState(() {
            availability = value;
          });
          _validateForm();
        },
        validator: (value) =>
            value == null ? 'please_select_availability'.tr : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('edit_service'.tr)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            onChanged: _validateForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  label: 'service_name',
                  controller: nameController,
                  validator: (value) => value == null || value.isEmpty
                      ? 'name_required'.tr
                      : null,
                ),
                _buildCategoryDropdown(),
                _buildTextField(
                  label: 'image_url',
                  controller: imageUrlController,
                  validator: (value) => value == null || value.isEmpty
                      ? 'image_url_required'.tr
                      : null,
                ),
                _buildTextField(
                  label: 'price',
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final price = double.tryParse(value ?? '');
                    if (price == null || price < 0)
                      return 'enter_valid_price'.tr;
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'rating',
                  controller: ratingController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final rating = double.tryParse(value ?? '');
                    if (rating == null || rating < 0 || rating > 5) {
                      return 'rating_range'.tr;
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'duration',
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'duration_required'.tr;
                    final duration = int.tryParse(value);
                    if (duration == null || duration <= 0) {
                      return 'enter_valid_duration'.tr;
                    }
                    return null;
                  },
                ),
                _buildAvailabilityDropdown(),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: isFormValid ? _saveChanges : null,
                  icon: const Icon(Icons.save),
                  label: Text('save'.tr),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
