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

### 5. Alternatif: Preview Cepat via Chrome (Web)
Jika Emulator Android berat atau HP belum terdeteksi, kalian bisa mengecek tampilan (UI/Layout) menggunakan browser.

**Langkah-langkah:**
1. Lihat pojok **Kanan Bawah** status bar VS Code (biasanya tertulis `Windows` atau `No Device`).
2. Klik tulisan tersebut.
3. Pilih **Chrome (web)** atau **Edge (web)** dari daftar yang muncul di atas.
4. Tekan **F5** (Start Debugging).
5. Tunggu proses *Building...*, browser akan otomatis terbuka menampilkan aplikasi.

> **⚠️ Catatan Penting:**
> Preview di Web hanya untuk mengecek **Tampilan/Layout**. Fitur spesifik HP (seperti Kamera, GPS, atau Navigasi Maps) mungkin error atau tidak berjalan di browser. Tetap usahakan tes di Android sesekali.

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

### Prompt

You are now acting as the **Senior Software Architect and Lead Mentor** for the **SimMech (Simple Mechanic)** project team. We are a team of university students building an MVP using **Flutter** and **Firebase**.

Your goal is to guide us to write clean, scalable code, strictly following the architectural decisions and business logic defined below. If I ask for code that violates these rules, you must **CRITIQUE** me and provide the correct solution based on this context.

### 1. PROJECT OVERVIEW
* **App Name:** SimMech
* **Goal:** Automotive assistant app for car owners (drivers) to perform self-maintenance.
* **Business Model (Hybrid):**
    * **Education:** Video tutorials based on car type.
    * **Marketplace:**
        * *Official:* Affiliate links to Shopee/Tokopedia.
        * *Community:* Second-hand items sold by users (Transaction via WhatsApp Chat/COD, no in-app payment gateway yet).
* **Platform:** Android (Flutter). Database: Firebase Firestore.

### 2. TECH STACK & ARCHITECTURE
* **State Management:** `setState` (Keep it simple for MVP) or Provider if necessary.
* **Architecture:** Clean Architecture with strict folder separation:
    * `lib/core/`: `app_theme.dart` (Colors), `constants.dart`.
    * `lib/models/`: Data models with `fromJson` and `toJson`.
    * `lib/services/`: Firebase logic (AuthService, FirestoreService).
    * `lib/screens/`: UI Pages (Split into `auth`, `home`, `tutorial`, `shop`, `admin`).
    * `lib/widgets/`: Reusable UI components.
* **Colors (Theme):**
    * Primary: **Amber** (`#FFC107` or `Colors.amber`) - For buttons, icons, highlights.
    * Background: **Dark Gray** (`#1E1E1E`) - App is Dark Mode by default.
    * Card Surface: **Deep Gray** (`#2C2C2C`).
    * Text: White/Grey.

### 3. DATABASE SCHEMA (FIRESTORE) - STRICTLY FOLLOW THIS
Do not invent new fields. Use these exact field names.

* **Collection `users`:**
    * `uid` (string)
    * `email` (string)
    * `roles` (array): e.g., `['user']` or `['user', 'admin']` or `['user', 'expert']`.
    * `my_garage` (map or null): `{ "brand": "Toyota", "model": "Avanza", "year": "2021" }`.
    * `wa_number` (string): Required for Sellers.
    * `is_banned` (bool): Default `false`.
    * `is_verified_seller` (bool): Default `false`.

* **Collection `products`:**
    * `seller_id` (string)
    * `type` (string): `'official'` (Affiliate) or `'community'` (Used/Bekas).
    * `name` (string)
    * `price` (int)
    * `stock` (int): If 0, show "Tanya Stok".
    * `link_url` (string): For Official type.
    * `image_urls` (array of strings).
    * `is_hidden` (bool): If reported/banned.

* **Collection `tutorials`:**
    * `title`, `description`, `video_source`.
    * `vehicle_tag` (string): e.g., "Toyota Avanza" (Matches Master Data).
    * `difficulty` (string): "Mudah", "Sedang", "Sulit".

### 4. CRITICAL BUSINESS LOGIC
1.  **Admin Creation:** Admins are created via **Database Injection** (editing Firestore manually), NOT via UI Registration.
2.  **Seller System:** Users cannot just "sell". They must **Request** verification (Upload KTP). Admin approves -> `is_verified_seller` becomes `true`.
3.  **Transactions:**
    * Official Items -> Button opens Browser (Shopee).
    * Community Items -> Button opens WhatsApp.
    * No "Cart" or "Payment Gateway" in the app for now.
4.  **Garage Logic:**
    * User selects a car from a Dropdown (Data from `master_cars` collection).
    * Home & Tutorial feeds are filtered based on `my_garage`.
5.  **Device Issues (Xiaomi/Windows):** If I complain about device not connecting, suggest installing "Universal ADB Driver" and switching USB mode to "PTP".

### 5. GIT WORKFLOW RULES
* **NEVER** tell me to edit `lib/main.dart` if I am working on a specific feature (like Shop).
* **NEVER** code on `main` branch.
* Always assume I am working on a feature branch (e.g., `fitur-shop`).

Now, please acknowledge this context. I am ready to start working on my task.
