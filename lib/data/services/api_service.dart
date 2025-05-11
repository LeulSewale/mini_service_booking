import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';

class ApiService {
  final String baseUrl = "https://681d1447f74de1d219aebf17.mockapi.io/api/v1";

  // Get all services
  Future<List<ServiceModel>> getServices({int page = 1, int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/services?page=$page&limit=$limit'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ServiceModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load services');
    }
  }

  // Create a new service
  Future<ServiceModel> createService(
      String name,
      String category,
      String imageUrl,
      double price,
      double rating,
      String duration,
      bool availability) async {
    final response = await http.post(
      Uri.parse('$baseUrl/services'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'category': category,
        'imageUrl': imageUrl,
        'price': price,
        'rating': rating,
        'duration': duration,
        'availability': availability,
      }),
    );

    if (response.statusCode == 201) {
      return ServiceModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add service');
    }
  }

  // Update an existing service
  Future<ServiceModel> updateService(
      String id,
      String name,
      String category,
      String imageUrl,
      double price,
      double rating,
      String duration,
      bool availability) async {
    final response = await http.put(
      Uri.parse('$baseUrl/services/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'category': category,
        'imageUrl': imageUrl,
        'price': price,
        'rating': rating,
        'duration': duration,
        'availability': availability,
      }),
    );

    if (response.statusCode == 200) {
      return ServiceModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update service');
    }
  }

  // Delete a service
  Future<void> deleteService(String id) async {
  final url = Uri.parse('$baseUrl/services/$id'); // Make sure this is correct
  final response = await http.delete(url);

  print('DELETE $url');
  print('Status code: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode != 200 && response.statusCode != 204) {
    throw Exception('Failed to delete service. Status: ${response.statusCode}');
  }
}

}
