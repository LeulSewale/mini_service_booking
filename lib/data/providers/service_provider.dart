import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';

class ServiceProvider {
  static const baseUrl =
      'https://mockapi.io/api/services'; // Replace with your real endpoint

  Future<List<ServiceModel>> fetchServices() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => ServiceModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load services');
    }
  }

  Future<ServiceModel> addService(ServiceModel service) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(service.toJson()),
    );
    if (response.statusCode == 201) {
      return ServiceModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add service');
    }
  }

  Future<void> deleteService(String id) async {
    final url = Uri.parse('$baseUrl/services/$id');
    final response = await http.delete(url, headers: {
      'Content-Type': 'application/json',
    });

    print('DELETE $url');
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete service: ${response.statusCode}');
    }
  }

  Future<ServiceModel> updateService(String id, ServiceModel service) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(service.toJson()),
    );
    if (response.statusCode == 200) {
      return ServiceModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update service');
    }
  }

  Future<ServiceModel> getServiceById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return ServiceModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch service detail');
    }
  }
}
