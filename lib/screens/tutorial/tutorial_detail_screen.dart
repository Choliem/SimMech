import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk cek kIsWeb
import 'package:url_launcher/url_launcher.dart'; // Untuk buka link di browser
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../core/app_theme.dart';
import '../../models/tutorial_model.dart';

class TutorialDetailScreen extends StatefulWidget {
  final TutorialModel tutorial;

  const TutorialDetailScreen({super.key, required this.tutorial});

  @override
  State<TutorialDetailScreen> createState() => _TutorialDetailScreenState();
}

class _TutorialDetailScreenState extends State<TutorialDetailScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();

    // HANYA JALANKAN LOGIC PLAYER JIKA BUKAN WEB
    if (!kIsWeb) {
      final videoId = YoutubePlayer.convertUrlToId(widget.tutorial.videoUrl);
      _controller = YoutubePlayerController(
        initialVideoId: videoId ?? "",
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          disableDragSeek: false,
        ),
      )..addListener(listener);
    }

    // Tampilkan Disclaimer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDisclaimerDialog();
    });
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {});
    }
  }

  @override
  void deactivate() {
    // Cek kIsWeb dulu biar gak error
    if (!kIsWeb) _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    // Cek kIsWeb dulu
    if (!kIsWeb) _controller.dispose();
    super.dispose();
  }

  // --- UI START ---
  @override
  Widget build(BuildContext context) {
    // ==========================================
    // JALUR 1: TAMPILAN KHUSUS WEB (CHROME)
    // ==========================================
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text("Putar Tutorial")),
        body: ListView(
          children: [
            // KOTAK PENGGANTI PLAYER
            Container(
              height: 250,
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.ondemand_video,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Mode Web Preview",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "(Player Video hanya jalan di HP Android)",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final urlString = widget.tutorial.videoUrl;

                        // 1. Validasi Sederhana: Harus ada https
                        if (!urlString.startsWith('http')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Link video rusak/tidak valid (Harus dimulai https://)",
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return; // Stop disini, jangan paksa buka
                        }

                        // 2. Coba Buka
                        final Uri url = Uri.parse(urlString);
                        try {
                          // Gunakan launchUrl dengan mode external (Tab Baru)
                          if (!await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          )) {
                            throw 'Could not launch $url';
                          }
                        } catch (e) {
                          // 3. Tangkap Error biar Aplikasi Gak Crash/Pause
                          print("Error membuka link: $e");
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Gagal membuka browser"),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text("Tonton di YouTube Asli"),
                    ),
                  ],
                ),
              ),
            ),

            // ISI KONTEN TETAP SAMA
            _buildDetailsContent(),
          ],
        ),
      );
    }

    // ==========================================
    // JALUR 2: TAMPILAN KHUSUS ANDROID (HP)
    // ==========================================
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppTheme.primaryColor,
        onReady: () {
          _isPlayerReady = true;
        },
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(title: const Text("Putar Tutorial")),
          body: ListView(
            children: [
              player, // Video Player Embed
              _buildDetailsContent(), // Isi Konten
            ],
          ),
        );
      },
    );
  }

  // --- REUSABLE WIDGET (Bisa dipakai Web & Android) ---
  Widget _buildDetailsContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // JUDUL & TAG
          Text(
            widget.tutorial.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTagIcon(Icons.directions_car, widget.tutorial.vehicleTag),
              const SizedBox(width: 12),
              _buildTagIcon(
                Icons.speed,
                "Tingkat: ${widget.tutorial.difficulty}",
              ),
            ],
          ),
          const Divider(color: Colors.grey, height: 30),

          // DESKRIPSI
          const Text("Deskripsi:", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            widget.tutorial.description.isNotEmpty
                ? widget.tutorial.description
                : "Tidak ada deskripsi tambahan.",
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 24),

          // LANGKAH-LANGKAH (STEPS)
          const Text(
            "Langkah Pengerjaan:",
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (widget.tutorial.steps.isEmpty)
            const Text(
              "- Ikuti panduan di video.",
              style: TextStyle(color: Colors.white),
            )
          else
            ...widget.tutorial.steps.map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        step,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // ALAT (TOOLS)
          if (widget.tutorial.toolIds.isNotEmpty) ...[
            const Text(
              "Alat & Bahan:",
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.tutorial.toolIds.length,
                itemBuilder: (context, index) {
                  return _buildToolCard(widget.tutorial.toolIds[index]);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- HELPER KECIL ---
  Widget _buildTagIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildToolCard(String toolId) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Membuka Shop untuk ID: $toolId")),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag,
              color: AppTheme.primaryColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                toolId, // Sementara tampilkan ID dulu
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Text(
              "Beli",
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDisclaimerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text("Disclaimer", style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            "Video ini hanya referensi edukasi. SimMech tidak bertanggung jawab atas kerusakan yang terjadi akibat kesalahan praktik.\n\nJika ragu, silakan gunakan fitur Konsultasi Expert.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Saya Mengerti, Lanjutkan",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }
}
