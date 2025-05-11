import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/service_controller.dart';

class AddServicePage extends StatefulWidget {
  const AddServicePage({Key? key}) : super(key: key);

  @override
  State<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _formKey = GlobalKey<FormState>();
  final ServiceController controller = Get.find();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  String? availability;

  bool isFormValid = false;

  void _validateForm() {
    setState(() {
      isFormValid =
          _formKey.currentState?.validate() == true && availability != null;
    });
  }

  void _addService() {
    if (_formKey.currentState?.validate() != true || availability == null)
      return;

    final name = nameController.text.trim();
    final category = categoryController.text.trim();
    final imageUrl = imageUrlController.text.trim();
    final price = double.tryParse(priceController.text.trim()) ?? 0.0;
    final rating = double.tryParse(ratingController.text.trim()) ?? 0.0;
    final duration = durationController.text.trim();
    final isAvailable = availability == 'available'.tr;

    controller.addService(
        name, category, imageUrl, price, rating, duration, isAvailable);
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

  Widget _buildDropdownField() {
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
        items: [
          DropdownMenuItem(value: 'Available', child: Text('available'.tr)),
          DropdownMenuItem(
              value: 'Not Available', child: Text('not_available'.tr)),
        ],
        onChanged: (value) {
          setState(() {
            availability = value;
          });
          _validateForm();
        },
        validator: (value) => value == null ? 'select_availability'.tr : null,
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
        validator: (value) => value == null ? 'select_category'.tr : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('add_new_service'.tr),
        centerTitle: true,
      ),
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
                    if (price == null || price < 0) return 'invalid_price'.tr;
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'rating_0_5',
                  controller: ratingController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final rating = double.tryParse(value ?? '');
                    if (rating == null || rating < 0 || rating > 5) {
                      return 'invalid_rating'.tr;
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  label: 'duration_minutes',
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'duration_required'.tr;
                    final duration = int.tryParse(value);
                    if (duration == null || duration <= 0) {
                      return 'invalid_duration'.tr;
                    }
                    return null;
                  },
                ),
                _buildDropdownField(),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: isFormValid ? _addService : null,
                  icon: const Icon(Icons.add),
                  label: Text(
                    'add_service'.tr,
                    style: TextStyle(color: Colors.white),
                  ),
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
