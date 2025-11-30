# SimMech: Solusi Otomotif Mandiri 🛠️

---

## 📋 Ringkasan Project

- **Core Concept**: Aplikasi mobile "Asisten Otomotif" berbasis Flutter untuk membantu pemilik kendaraan melakukan perawatan mandiri.
- **Hybrid Business Model**:
    - **Edukasi**: Tutorial video step-by-step (Avanza, Brio, dll).
    - **Marketplace**: Gabungan *Affiliate* (Barang Baru) dan *Community Chat* (Barang Bekas/COD).
- **Multi-Role System**: Satu aplikasi mendukung 3 peran sekaligus: **User** (Pembeli), **Expert** (Konsultan), dan **Admin** (Pengelola).

---

## 💻 Prasyarat (System Requirements)

Pastikan environment laptop sudah siap sebelum memulai:

1.  **Flutter SDK** (Versi Stable Terbaru).
2.  **VS Code**: Wajib install Extension `Flutter` dan `Dart`.
3.  **Android Studio**: Diperlukan untuk komponen SDK & Emulator.
4.  **Git SCM**: Untuk manajemen versi dan kolaborasi.
5.  **Universal ADB Driver**: (Khusus Windows + HP Xiaomi/Samsung) agar device terdeteksi saat debugging.

---

## 🚀 Instalasi & Konfigurasi (Step-by-Step)

Mirip dengan framework lain (seperti Laravel yang meng-ignore `.env`), Flutter juga memiliki file konfigurasi lokal yang **TIDAK DI-UPLOAD** ke GitHub demi keamanan dan kecocokan path local.

Ikuti langkah ini untuk membangun ulang environment tersebut:

### 1. Clone Repository
Ambil kode dari GitHub ke laptopmu:

```bash
git clone https://github.com/Choliem/SimMech.git
cd SimMech
```

### 2. Download Library (Dependencies)
Install semua paket yang terdaftar di `pubspec.yaml`:

```bash
flutter pub get
```

### 3. Konfigurasi Environment (PENTING ⚠️)
File `android/local.properties` masuk ke dalam `.gitignore` sehingga tidak akan ada saat kamu clone. Kamu harus membuatnya manual agar build tidak error.

**Langkah:**
1. Masuk ke folder `android/`.
2. Buat file baru bernama `local.properties`.
3. Isi dengan path SDK laptopmu:

**Untuk Windows:**
```properties
sdk.dir=C:\\Users\\USERNAME_LAPTOP_KAMU\\AppData\\Local\\Android\\Sdk
```

**Untuk Mac/Linux:**
```properties
sdk.dir=/Users/USERNAME_LAPTOP_KAMU/Library/Android/sdk
```

> **Catatan:** Ganti `USERNAME_LAPTOP_KAMU` dengan nama user PC kamu. Pastikan menggunakan double backslash `\\` di Windows.

### 4. Jalankan Aplikasi
Pastikan HP terhubung (Mode USB Debugging ON) atau Emulator menyala:

```bash
flutter run
```
*(Atau tekan F5 di VS Code)*.

---

## 📂 Struktur Folder (Clean Architecture)

Kami menggunakan pemisahan folder yang ketat untuk mencegah konflik kode antar programmer.

```text
lib/
├── core/                # Konfigurasi Global
│   ├── app_theme.dart   # Warna & Tema (Amber/Dark)
│   └── constants.dart   # Asset path & String statis
├── models/              # Data Models (JSON Parsing)
│   ├── user_model.dart
│   └── product_model.dart
├── services/            # Logic Backend (Firebase Auth/Firestore)
│   ├── auth_service.dart
│   └── database_service.dart
├── widgets/             # Reusable Components (Button, Card, Input)
└── screens/             # Halaman UI (Tampilan Utama)
    ├── auth/            # [P1] Login, Register, Forgot Password
    ├── home/            # [P2] Dashboard, Garage Filter, Search
    ├── tutorial/        # [P2] Video Player, Detail Step, Tools List
    ├── shop/            # [P3] Grid Product, Detail (Affiliate/Chat)
    └── admin/           # [P1] Verification Panel, Reports
```

---

## 🤝 Workflow Kolaborasi (Git SOP)

**ATURAN UTAMA:** Dilarang commit langsung ke branch `main`.

### 1. Pull Dulu (Pagi Hari)
Selalu ambil update terbaru sebelum mulai coding.

```bash
git checkout main
git pull origin main
```

### 2. Buat Branch Fitur
Kerjakan tugasmu di branch terpisah agar aman.

```bash
git checkout -b fitur-login-screen  # Contoh P1
git checkout -b fitur-garage-logic  # Contoh P2
```

### 3. Push & Pull Request (Sore Hari)
Upload kodinganmu ke GitHub.

```bash
git add .
git commit -m "Menambahkan layout login"
git push origin fitur-login-screen
```
*Lalu buka GitHub dan buat Pull Request (PR) ke `main`.*

---

## 👨‍💻 Pembagian Tugas (Task Division)

| Role | Tanggung Jawab Utama | Fitur Spesifik |
| :--- | :--- | :--- |
| **Programmer 1 (Lead)** | **Auth & Admin** | • Login Logic & Role Check<br>• Admin Dashboard (Verify Seller)<br>• Report System |
| **Programmer 2** | **Core & Edukasi** | • Home & Garage Dropdown<br>• Video Player & Disclaimer<br>• Search Engine (Title + Desc) |
| **Programmer 3** | **Shop & Interaksi** | • UI Katalog Produk<br>• Logic Tombol (Shopee vs WA)<br>• Form Upload Barang Bekas |

---

## 🛠️ Troubleshooting

### Error: `SDK location not found`
Ini terjadi karena file `local.properties` hilang (karena di-ignore git).
**Solusi:** Lihat langkah **No. 3** di bagian Instalasi di atas.

### Error: Device tidak muncul (Xiaomi/POCO)
Xiaomi membutuhkan izin keamanan tambahan.
**Solusi:**
1. Pastikan Driver USB sudah terinstall (Gunakan Universal ADB Driver).
2. Di HP, ubah mode USB dari "File Transfer" ke **"PTP" (Picture Transfer)**.
3. Di *Developer Options*, aktifkan:
   - USB Debugging
   - Install via USB
   - USB Debugging (Security Settings)

---
