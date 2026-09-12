import 'package:uuid/uuid.dart';

class ProductModel {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final bool isFavorite;
  final String? imagePath;

  ProductModel({
    String? id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.imagePath,
    this.category = 'Geral',
    this.isFavorite = false,
  }) : id = id ?? const Uuid().v4();

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    String? imageUrl,
    String? category,
    bool? isFavorite,
    String? imagePath,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'category': category,
      'isFavorite': isFavorite,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      imagePath: map['imagePath'],
      category: map['category'] ?? 'Geral',
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}
