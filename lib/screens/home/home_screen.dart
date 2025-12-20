import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_theme.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../models/car_model.dart';
import '../admin/admin_dashboard_screen.dart';
import '../auth/login_screen.dart';
import 'notification_screen.dart'; // <--- INI OBATNYA (YANG TADINYA HILANG)

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();

    return StreamBuilder<DocumentSnapshot>(
      stream: dbService.getUserStream(),
      builder: (context, snapshot) {
        // Loading State
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>?;
        var garage = userData?['my_garage'];

        // AMBIL DATA PENTING
        List<dynamic> roles = userData?['roles'] ?? ['user'];
        bool isAdmin = roles.contains('admin');
        String userName = userData?['name'] ?? 'Sobat Otomotif';

        return Scaffold(
          appBar: AppBar(
            title: const Text("SimMech Dashboard"),
            actions: [
              // 1. TOMBOL ADMIN (Hanya Muncul Jika Admin)
              if (isAdmin)
                IconButton(
                  icon: const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.redAccent,
                  ),
                  tooltip: "Admin Panel",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminDashboardScreen(),
                      ),
                    );
                  },
                ),

              // 2. TOMBOL NOTIFIKASI (Inbox)
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: "Notifikasi",
                onPressed: () {
                  // Buka Halaman Inbox
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  );
                },
              ),

              // 3. TOMBOL LOGOUT
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: "Keluar",
                onPressed: () async {
                  await AuthService().logout();
                  if (!context.mounted) return;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER: Welcome & Garage ---
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Halo, $userName! 👋",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),

                      // Tampilkan Mobil Terpilih atau Tombol Pilih
                      if (garage != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.directions_car,
                              color: AppTheme.primaryColor,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${garage['brand']} ${garage['model']}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // Text(
                                //   "Tahun ${garage['year']}",
                                //   style: const TextStyle(color: AppTheme.primaryColor),
                                // ),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.grey),
                              onPressed: () => _showCarSelector(context),
                            ),
                          ],
                        ),
                      ] else ...[
                        const Text(
                          "Kamu belum pilih mobil.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _showCarSelector(context),
                          icon: const Icon(Icons.add),
                          label: const Text("Pilih Mobil Sekarang"),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 45),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  "Menu Cepat",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // --- GRID MENU DUMMY ---
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  children: [
                    _buildMenuIcon(Icons.build, "Servis"),
                    _buildMenuIcon(Icons.battery_charging_full, "Aki"),
                    _buildMenuIcon(Icons.oil_barrel, "Oli"),
                    _buildMenuIcon(Icons.more_horiz, "Lainnya"),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget Helper untuk Menu Icon
  Widget _buildMenuIcon(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: AppTheme.cardColor,
          radius: 28,
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

// --- POPUP PEMILIH MOBIL ---
  void _showCarSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pilih Mobil Kamu",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<List<CarModel>>(
                  stream: DatabaseService().getCarList(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return const Text("Error memuat data");
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());

                    var cars = snapshot.data!;

                    // GABUNGKAN OPSI "SEMUA MOBIL" + DATA DARI FIREBASE
                    return ListView.separated(
                      // Tambah 1 untuk opsi 'Reset' di paling atas
                      itemCount: cars.length + 1,
                      separatorBuilder: (context, index) =>
                          const Divider(color: Colors.grey),
                      itemBuilder: (context, index) {
                        // ITEM 0: OPSI RESET (SEMUA MOBIL)
                        if (index == 0) {
                          return ListTile(
                            leading: const Icon(
                              Icons.public,
                              color: Colors.blueAccent,
                            ),
                            title: const Text(
                              "Semua Mobil (Lihat Semua)",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () async {
                              // Hapus data garage di Firebase
                              String uid = AuthService().currentUser!.uid;
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .update({
                                    'my_garage':
                                        FieldValue.delete(), // Hapus field
                                  });
                              Navigator.pop(context); // Tutup Popup
                            },
                          );
                        }

                        // ITEM 1 DST: DATA MOBIL ASLI
                        var car =
                            cars[index - 1]; // Geser index karena ada item 0
                        return ListTile(
                          leading: const Icon(
                            Icons.directions_car,
                            color: Colors.white,
                          ),
                          title: Text(
                            "${car.brand} ${car.model}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            _showYearInput(context, car);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- POPUP INPUT TAHUN (REVISED: Dengan Inline Error) ---
  void _showYearInput(BuildContext parentContext, CarModel car) {
    final yearController = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (context) {
        String? errorMessage; // Variabel untuk menyimpan pesan error

        // StatefulBuilder berguna agar Dialog bisa me-refresh dirinya sendiri
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                "Tahun Berapa ${car.model}-mu?",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min, // Agar popup tidak kegedean
                children: [
                  TextField(
                    controller: yearController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    maxLength: 4,
                    decoration: InputDecoration(
                      hintText: "Contoh: 2021",
                      hintStyle: const TextStyle(color: Colors.grey),
                      counterText: "",

                      // LOGIKA ERROR INLINE
                      errorText: errorMessage,
                      errorStyle: const TextStyle(color: Colors.redAccent),

                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Batal",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    String year = yearController.text.trim();

                    // VALIDASI
                    if (year.length == 4 && int.tryParse(year) != null) {
                      // Simpan ke Database
                      DatabaseService().updateUserGarage(car, year);

                      // Tutup Dialog Tahun
                      Navigator.pop(context);

                      // Tutup BottomSheet List Mobil (Pakai context parent)
                      Navigator.pop(parentContext);
                    } else {
                      // GAGAL: Update tampilan Dialog jadi merah
                      setState(() {
                        errorMessage = "Wajib 4 digit angka (Misal: 2021)";
                      });
                    }
                  },
                  child: const Text("Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
