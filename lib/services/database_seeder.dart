import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseSeeder {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // FUNGSI INJEKSI DATA
  Future<void> seedData() async {
    // 1. TAMBAH DATA PRODUK (SHOP)
    var products = [
      {
        'name': 'Oli Shell Helix HX6',
        'price': 350000,
        'condition': 'new',
        'type': 'official',
        'image_url':
            'https://down-id.img.susercontent.com/file/id-11134207-7r98o-lm6uy8j6j02f74', // Link contoh
        'seller_name': 'SimMech Official',
        'category': 'Mesin',
        'link_url': 'https://shopee.co.id',
      },
      {
        'name': 'Velg Racing R15 Bekas',
        'price': 1500000,
        'condition': 'used',
        'type': 'community',
        'image_url':
            'https://down-id.img.susercontent.com/file/54f57564619379647209591438902506',
        'seller_name': 'Budi Garage',
        'category': 'Kaki-kaki',
        'seller_wa': '628123456789',
      },
      {
        'name': 'Aki GS Astra Hybrid',
        'price': 850000,
        'condition': 'new',
        'type': 'official',
        'image_url':
            'https://astraotoparts.co.id/uploads/product/1660114068_GS_Hybrid_NS60.png',
        'seller_name': 'SimMech Official',
        'category': 'Kelistrikan',
        'link_url': 'https://tokopedia.com',
      },
    ];

    for (var p in products) {
      await _db.collection('products').add(p);
    }

    print("✅ DATA PRODUK BERHASIL DIINJEKSI");
  }
}
