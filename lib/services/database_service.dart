import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/car_model.dart';
import '../models/tutorial_model.dart';
import '../models/product_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Ambil Semua Jenis Mobil dari 'master_cars'
  Stream<List<CarModel>> getCarList() {
    return _db.collection('master_cars').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CarModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // 2. Ambil Data User Saat Ini
  Stream<DocumentSnapshot> getUserStream() {
    // Pastikan user login agar tidak error null
    if (_auth.currentUser == null) {
      return const Stream.empty();
    }
    String uid = _auth.currentUser!.uid;
    return _db.collection('users').doc(uid).snapshots();
  }

  // 3. Simpan Pilihan Mobil User ke Database (DENGAN TAHUN)
  Future<void> updateUserGarage(CarModel car, String yearInput) async {
    String uid = _auth.currentUser!.uid;
    await _db.collection('users').doc(uid).set({
      'my_garage': {'brand': car.brand, 'model': car.model, 'year': yearInput},
    }, SetOptions(merge: true));
  }

  // 4. Ambil Tutorial (Updated: Support All & Pagination Limit)
  Stream<List<TutorialModel>> getTutorials(String? userCarTag, int limit) {
    var query = _db.collection('tutorials');

    if (userCarTag == null || userCarTag == 'General') {
      // SKENARIO 1: Belum pilih mobil (Tampilkan SEMUA video)
      // Kita urutkan biar rapi (opsional, pastikan field created_at ada atau hapus orderBy jika error index)
      return query.limit(limit).snapshots().map(_tutorialListFromSnapshot);
    } else {
      // SKENARIO 2: Punya mobil (Filter Khusus + General)
      return query
          .where('vehicle_tag', whereIn: [userCarTag, 'General'])
          .limit(limit)
          .snapshots()
          .map(_tutorialListFromSnapshot);
    }
  }

  // Helper function biar gak nulis ulang map-nya
  List<TutorialModel> _tutorialListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return TutorialModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  // 5. Ambil Daftar Produk (Bisa Filter Kategori/Tipe)
  Stream<List<ProductModel>> getProducts({String filterType = 'all'}) {
    Query query = _db.collection('products');

    // Filter: hanya tampilkan 'official' atau 'community' jika diminta
    if (filterType != 'all') {
      query = query.where('type', isEqualTo: filterType);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
