import 'package:hive/hive.dart';

part 'service_model.g.dart'; // Required for build_runner

@HiveType(typeId: 0)
class ServiceModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final String imageUrl;

  @HiveField(4)
  final double price;

  @HiveField(5)
  final double rating;

  @HiveField(6)
  final String duration;

  @HiveField(7)
  final bool availability;

  ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.duration,
    required this.availability,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        id: json['id'],
        name: json['name'],
        category: json['category'],
        imageUrl: json['imageUrl'],
        price: double.tryParse(json['price'].toString()) ?? 0,
        rating: double.tryParse(json['rating'].toString()) ?? 0,
        duration: json['duration'],
        availability: json['availability'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'imageUrl': imageUrl,
        'price': price,
        'rating': rating,
        'duration': duration,
        'availability': availability,
      };
}
