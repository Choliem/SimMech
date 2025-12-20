import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Hapus ini (tidak dipakai)
import '../core/app_theme.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';
import 'tutorial/tutorial_list_screen.dart';
import 'shop/shop_screen.dart'; // <--- File ini sekarang sudah ada
import 'expert/expert_list_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TutorialListScreen(),
    const ShopScreen(), // <--- Panggil ShopScreen yang asli
    const ExpertListScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // KILL SWITCH: Mendengarkan Status User secara Realtime
    return StreamBuilder<DocumentSnapshot>(
      stream: DatabaseService().getUserStream(),
      builder: (context, snapshot) {
        // 1. Cek Apakah Data Ada
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>?;

        if (userData == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. CEK STATUS BAN
        bool isBanned = userData['is_banned'] ?? false;

        if (isBanned) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await AuthService().logout();
            if (context.mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  backgroundColor: AppTheme.cardColor,
                  title: const Row(
                    children: [
                      Icon(Icons.block, color: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        "Akun Dibekukan",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  content: const Text(
                    "Mohon maaf, akun Anda telah dinonaktifkan oleh Admin.",
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "Keluar Aplikasi",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            }
          });
          return const Scaffold(backgroundColor: Colors.black);
        }

        // 3. JIKA AMAN, TAMPILKAN APLIKASI
        return Scaffold(
          body: _screens[_selectedIndex],
          bottomNavigationBar: NavigationBar(
            backgroundColor: AppTheme.cardColor,
            indicatorColor: AppTheme.primaryColor,
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.play_circle_outline),
                selectedIcon: Icon(Icons.play_circle_fill),
                label: 'Tutorial',
              ),
              NavigationDestination(
                icon: Icon(Icons.shopping_bag_outlined),
                selectedIcon: Icon(Icons.shopping_bag),
                label: 'Shop',
              ),
              NavigationDestination(
                icon: Icon(Icons.verified_user_outlined),
                selectedIcon: Icon(Icons.verified_user),
                label: 'Expert',
              ),
            ],
          ),
        );
      },
    );
  }
}
