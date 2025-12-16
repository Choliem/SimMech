class ProductModel {
  final String id;
  final String name;
  final int price;
  final String condition; // 'new' or 'used'
  final String type; // 'official' or 'community'
  final String imageUrl;
  final String sellerName;
  final String category;

  // Data Opsional (Tergantung Tipe)
  final String? linkUrl; // Khusus Official
  final String? sellerWa; // Khusus Community

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.condition,
    required this.type,
    required this.imageUrl,
    required this.sellerName,
    required this.category,
    this.linkUrl,
    this.sellerWa,
  });

  factory ProductModel.fromMap(Map<String, dynamic> data, String id) {
    return ProductModel(
      id: id,
      name: data['name'] ?? 'Tanpa Nama',
      price: data['price'] ?? 0,
      condition: data['condition'] ?? 'new',
      type: data['type'] ?? 'official',
      imageUrl: data['image_url'] ?? '',
      sellerName: data['seller_name'] ?? 'SimMech',
      category: data['category'] ?? 'Umum',
      linkUrl: data['link_url'],
      sellerWa: data['seller_wa'],
    );
  }
}
