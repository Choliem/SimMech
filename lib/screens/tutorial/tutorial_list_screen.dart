import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_theme.dart';
import '../../services/database_service.dart';
import '../../models/tutorial_model.dart';
import 'tutorial_detail_screen.dart';

class TutorialListScreen extends StatefulWidget {
  const TutorialListScreen({super.key});

  @override
  State<TutorialListScreen> createState() => _TutorialListScreenState();
}

class _TutorialListScreenState extends State<TutorialListScreen> {
  final dbService = DatabaseService();

  // PAGINATION STATE
  int _currentLimit = 5; // Mulai dengan 5 video
  final int _loadIncrement = 5; // Setiap load nambah 5

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tutorial Bengkel"), centerTitle: false),
      body: StreamBuilder<DocumentSnapshot>(
        // 1. DENGARKAN DATA USER
        stream: dbService.getUserStream(),
        builder: (context, userSnapshot) {
          // Handle Loading User
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var userData = userSnapshot.data?.data() as Map<String, dynamic>?;
          var garage = userData?['my_garage'];

          // LOGIKA JUDUL & TAG
          String? carTag; // Bisa null
          String displayTitle;

          if (garage == null) {
            // SKENARIO: SHOW ALL (EKSPLORASI)
            carTag = null;
            displayTitle = "Eksplorasi Semua Tutorial";
          } else {
            // SKENARIO: PERSONALISASI
            carTag = "${garage['brand']} ${garage['model']}";
            displayTitle = "Khusus untuk $carTag kamu";
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (garage == null)
                      const Text(
                        "(Pilih mobil di Home untuk filter otomatis)",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                  ],
                ),
              ),

              // 2. LIST VIDEO (DENGAN PAGINATION)
              Expanded(
                child: StreamBuilder<List<TutorialModel>>(
                  stream: dbService.getTutorials(carTag, _currentLimit),
                  builder: (context, tutSnapshot) {
                    if (tutSnapshot.hasError)
                      return Center(child: Text("Error: ${tutSnapshot.error}"));
                    if (!tutSnapshot.hasData)
                      return const Center(child: CircularProgressIndicator());

                    var tutorials = tutSnapshot.data!;

                    if (tutorials.isEmpty) {
                      return const Center(
                        child: Text(
                          "Belum ada video tersedia.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      // LOGIKA ITEM COUNT:
                      // Jika jumlah video < limit, berarti sudah habis -> Jangan tambah tombol (+0)
                      // Jika jumlah video == limit, mungkin masih ada -> Tambah tombol (+1)
                      itemCount:
                          tutorials.length +
                          (tutorials.length < _currentLimit ? 0 : 1),

                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        // JIKA INI POSISI TOMBOL LOAD MORE
                        if (index == tutorials.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _currentLimit += _loadIncrement;
                                });
                              },
                              icon: const Icon(Icons.expand_more),
                              label: const Text(
                                "Muat Lebih Banyak",
                              ), // Teks simpel aja
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[800],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          );
                        }

                        // TAMPILAN VIDEO CARD NORMAL
                        var video = tutorials[index];
                        return Card(
                          color: AppTheme.cardColor,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TutorialDetailScreen(tutorial: video),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thumbnail Dummy
                                Container(
                                  height: 150,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    image: const DecorationImage(
                                      image: AssetImage(
                                        'assets/placeholder_video.png',
                                      ), // Opsional
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_circle_fill,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        video.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          _buildTag(
                                            video.difficulty,
                                            _getDifficultyColor(
                                              video.difficulty,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (video.vehicleTag == 'General')
                                            _buildTag("Umum", Colors.blueAccent)
                                          else
                                            _buildTag(
                                              video.vehicleTag,
                                              Colors.purpleAccent,
                                            ), // Tag Mobil
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10)),
    );
  }

  Color _getDifficultyColor(String diff) {
    switch (diff) {
      case 'Mudah':
        return Colors.green;
      case 'Sedang':
        return Colors.orange;
      case 'Sulit':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
