import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Untuk buka WA/Shopee
import '../../core/app_theme.dart';
import '../../models/product_model.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    bool isNew = product.condition == 'new';
    bool isOfficial = product.type == 'official';

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Column(
        children: [
          // 1. GAMBAR PRODUK (Scrollable content)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.white,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, stack) => const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Harga & Kondisi
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Rp ${product.price}",
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isNew ? Colors.blue : Colors.orange,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isNew ? 'BARU' : 'BEKAS',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Nama Produk
                        Text(
                          product.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Penjual
                        Row(
                          children: [
                            const Icon(Icons.store, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              product.sellerName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            if (isOfficial) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                        const Divider(color: Colors.grey, height: 32),

                        // Deskripsi (Dummy text jika kosong)
                        const Text(
                          "Deskripsi Produk",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Kategori: ${product.category}.\nBarang ini sangat direkomendasikan untuk perawatan kendaraan Anda. Pastikan sesuai dengan tipe mobil.",
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. BOTTOM BAR (TOMBOL BELI)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              border: Border(
                top: BorderSide(color: Colors.grey.withOpacity(0.2)),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOfficial
                      ? AppTheme.primaryColor
                      : Colors.green, // Kuning (Official) / Hijau (WA)
                  foregroundColor: Colors.black,
                ),
                icon: Icon(isOfficial ? Icons.shopping_cart : Icons.chat),
                label: Text(
                  isOfficial
                      ? "BELI SEKARANG (Affiliate)"
                      : "CHAT PENJUAL (WhatsApp)",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => _handleBuyAction(context, product),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIKA TOMBOL SAKTI ---
  Future<void> _handleBuyAction(
    BuildContext context,
    ProductModel product,
  ) async {
    Uri? targetUrl;

    if (product.type == 'official') {
      // 1. OFFICIAL: Buka Link Shopee/Tokped
      if (product.linkUrl != null && product.linkUrl!.isNotEmpty) {
        targetUrl = Uri.parse(product.linkUrl!);
      }
    } else {
      // 2. COMMUNITY: Buka WhatsApp
      if (product.sellerWa != null && product.sellerWa!.isNotEmpty) {
        // Format WA API: https://wa.me/628xxx?text=Halo...
        String message =
            "Halo ${product.sellerName}, saya tertarik dengan ${product.name} di SimMech.";
        String urlString =
            "https://wa.me/${product.sellerWa}?text=${Uri.encodeComponent(message)}";
        targetUrl = Uri.parse(urlString);
      }
    }

    // Eksekusi Buka Link
    if (targetUrl != null) {
      try {
        await launchUrl(targetUrl, mode: LaunchMode.externalApplication);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal membuka link: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Link/Nomor WA tidak tersedia"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
