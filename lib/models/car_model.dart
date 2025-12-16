class CarModel {
  final String id;
  final String brand;
  final String model;
  final String imageUrl;

  CarModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.imageUrl,
  });

  // Mengubah data JSON dari Firebase menjadi Object Dart
  factory CarModel.fromMap(Map<String, dynamic> data, String documentId) {
    return CarModel(
      id: documentId,
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      imageUrl: data['image_url'] ?? '',
    );
  }
}
