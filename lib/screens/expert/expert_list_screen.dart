import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_theme.dart';
import '../../services/database_service.dart';
import '../premium/upgrade_screen.dart'; // Halaman Bayar
import '../chat/chat_screen.dart'; // Halaman Chat Room

class ExpertListScreen extends StatelessWidget {
  const ExpertListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Konsultasi Expert")),
      body: StreamBuilder<DocumentSnapshot>(
        // 1. DENGARKAN DATA USER (Cek Tier: Free / Premium)
        stream: DatabaseService().getUserStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          var userData = snapshot.data!.data() as Map<String, dynamic>?;

          // AMBIL STATUS TIER & PEMBAYARAN
          String tier = userData?['tier'] ?? 'free';
          String paymentStatus = userData?['payment_status'] ?? 'none';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 2. BANNER STATUS (Terkunci / Menunggu / Aktif)
              if (tier == 'free')
                _buildUpgradeBanner(context, paymentStatus)
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified, color: Colors.green),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Akun Premium Aktif. Silakan chat expert.",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

              const Text(
                "Expert Tersedia:",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // 3. LIST EXPERT DUMMY
              // (Nama expert ini nanti diteruskan ke Chat Room)
              _buildExpertCard(
                context,
                "Budi Santoso",
                "Spesialis Mesin",
                tier,
              ),
              _buildExpertCard(
                context,
                "Andi Wijaya",
                "Spesialis Kelistrikan",
                tier,
              ),
              _buildExpertCard(
                context,
                "Siti Aminah",
                "Spesialis AC Mobil",
                tier,
              ),
            ],
          );
        },
      ),
    );
  }
  
  // Widget Banner untuk mengajak Upgrade
  Widget _buildUpgradeBanner(BuildContext context, String paymentStatus) {
    bool isPending = paymentStatus == 'pending';

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isPending
            ? Colors.blue[900]
            : AppTheme.secondaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPending ? Colors.blue : AppTheme.primaryColor,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isPending ? Icons.timelapse : Icons.lock,
            size: 40,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Text(
            isPending ? "Menunggu Verifikasi Admin" : "Fitur Terkunci",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isPending
                ? "Kami sedang mengecek pembayaranmu. Mohon tunggu notifikasi."
                : "Upgrade ke Premium untuk chat langsung dengan mekanik profesional.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
          if (!isPending) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UpgradeScreen(),
                  ),
                );
              },
              child: const Text("Buka Kunci Sekarang"),
            ),
          ],
        ],
      ),
    );
  }

  // Widget Kartu Expert
  Widget _buildExpertCard(
    BuildContext context,
    String name,
    String role,
    String userTier,
  ) {
    bool isLocked = userTier == 'free';

    return Card(
      color: AppTheme.cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Text(name[0])),
        title: Text(name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(role, style: const TextStyle(color: Colors.grey)),
        trailing: Icon(
          isLocked ? Icons.lock : Icons.chat,
          color: isLocked ? Colors.red : Colors.green,
        ),
        onTap: () {
          if (isLocked) {
            // SKENARIO FREE: Arahkan ke Upgrade
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Eits, fitur ini khusus Premium!"),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UpgradeScreen()),
            );
          } else {
            // SKENARIO PREMIUM: Buka Chat Room
            // Trik Demo: Kita cari akun Admin di database untuk dijadikan lawan bicara
            FirebaseFirestore.instance
                .collection('users')
                .where('roles', arrayContains: 'admin')
                .limit(1)
                .get()
                .then((snapshot) {
                  if (snapshot.docs.isNotEmpty) {
                    String adminId = snapshot.docs.first.id;

                    // Masuk ke Room Chat
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          receiverId: adminId,
                          receiverName:
                              name, // Pakai nama expert biar User merasa chat sama expert asli
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Expert sedang offline (Admin not found)",
                        ),
                      ),
                    );
                  }
                });
          }
        },
      ),
    );
  }
}
