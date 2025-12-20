# SimMech (Simple Mechanic) 🚗🛠️

**Solusi Otomotif Pintar: Rawat Kendaraanmu, Tanpa Rasa Ragu.**

SimMech adalah platform aplikasi *mobile* terintegrasi yang dirancang untuk membantu pemilik kendaraan (khususnya pemula) dalam merawat kendaraan mereka. Aplikasi ini menggabungkan tutorial perawatan, marketplace sparepart transparan, dan konsultasi langsung dengan mekanik ahli.

---

## 💡 Latar Belakang

Banyak pemilik kendaraan, seperti pengemudi taksi online atau pengguna pribadi, menghadapi masalah klasik:
1.  **Kurang Pengetahuan Dasar:** Bingung cara merawat mesin sederhana.
2.  **Informasi Membingungkan:** Tutorial di internet seringkali tidak terstruktur.
3.  **Ketidakpercayaan:** Takut ditipu harga saat ke bengkel atau membeli sparepart.

**SimMech hadir sebagai solusi *One-Stop-Platform* untuk mengatasi masalah tersebut.**

---

## 🚀 Fitur Utama

### 1. 📚 Edukasi & Tutorial
- **Smart Filtering:** Menampilkan tutorial yang hanya relevan dengan merk/tipe mobil pengguna (My Garage).
- **Step-by-Step Guide:** Panduan visual (video/gambar) untuk perawatan ringan (Ganti oli, Cek aki, Wiper).

### 2. 🛒 Marketplace Sparepart (Shop)
- **Official & Community Sellers:** Menjual sparepart baru (Official) dan bekas berkualitas (Komunitas).
- **Transparansi Harga:** Membandingkan harga pasar agar pengguna tidak tertipu.
- **Direct Purchase:** Terintegrasi dengan link e-commerce atau kontak WhatsApp penjual.

### 3. 💬 Konsultasi Expert (Premium Feature)
- **Realtime Chat:** Fitur chat langsung dengan mekanik terverifikasi (WhatsApp-style interface).
- **Personalized Advice:** Expert dapat melihat profil mobil pengguna untuk diagnosa lebih akurat.
- **Priority Inbox:** Expert memiliki tab khusus untuk mengelola klien premium.

---

## 👥 Struktur Role Pengguna

Aplikasi ini memiliki sistem *Role-Based Access Control (RBAC)* yang membedakan fitur antar pengguna:

| Role | Fitur & Akses |
| :--- | :--- |
| **User (Free)** | Akses Tutorial dasar, Melihat Shop, Mengelola "My Garage". |
| **User (Premium)** | Semua fitur Free + **Akses Chat ke Expert**. (Status didapat setelah upload bukti bayar & diverifikasi Admin). |
| **Expert** | Dashboard khusus dengan **Tab Inbox Klien**, bisa membalas chat user premium, dan tetap bisa mengakses fitur user biasa. |
| **Admin** | Dashboard khusus untuk **Verifikasi Pembayaran** (Terima/Tolak bukti transfer) dan **Manajemen User** (Ban/Unban akun). |

---

## 🛠️ Teknologi yang Digunakan

- **Framework:** [Flutter](https://flutter.dev/) (Dart) - Hybrid (Android/iOS).
- **Backend & Database:** [Firebase](https://firebase.google.com/)
  - **Authentication:** Login/Register email & password.
  - **Firestore (NoSQL):** Penyimpanan data user, produk, chat, dan tutorial.
  - **Storage:** Penyimpanan gambar bukti pembayaran.
- **Fitur Khusus:**
  - `StreamBuilder` untuk update data *Realtime* (Chat & Status Pembayaran).
  - Custom UI/UX Theme (Dark Mode Elegant).

---

## 💻 Instalasi & Menjalankan

Ikuti langkah ini untuk menjalankan proyek di lokal (Pastikan Flutter SDK sudah terinstall):

1.  **Clone Repository**
    ```bash
    git clone [https://github.com/username/simmech.git](https://github.com/username/simmech.git)
    cd simmech_app
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Setup Firebase**
    - Pastikan file `google-services.json` (Android) atau `GoogleService-Info.plist` (iOS) sudah ada di folder masing-masing.
    - *Note: Proyek ini membutuhkan Index Firestore khusus untuk fitur Chat. Silakan cek console log saat running jika muncul error index.*

4.  **Jalankan Aplikasi**
    ```bash
    flutter run
    ```
---

> **SimMech** - *Simple Mechanic for Everyone.*
