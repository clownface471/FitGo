# FitGo - Aplikasi Pelacak Kebugaran & Nutrisi

![FitGo Mockup](https://i.imgur.com/your-mockup-image.png)

FitGo adalah aplikasi mobile lintas platform (cross-platform) yang dibangun menggunakan Flutter. Aplikasi ini berfungsi sebagai asisten kebugaran pribadi, membantu pengguna untuk mencapai tujuan kesehatan mereka melalui program latihan dan rencana diet yang dipersonalisasi.

## ✨ Fitur Utama

- **Otentikasi Pengguna:** Sistem registrasi dan login yang aman menggunakan Firebase Authentication.
- **Onboarding Cerdas:** Alur onboarding multi-langkah untuk mengumpulkan data pengguna (tujuan, level kebugaran, metrik tubuh) untuk personalisasi.
- **Rekomendasi Program Latihan:** Sistem secara otomatis merekomendasikan program latihan yang paling sesuai dari database berdasarkan profil pengguna.
- **Workout Player Interaktif:** Pemandu latihan *real-time* yang melacak set, repetisi, dan waktu istirahat, lengkap dengan logging performa (berat & repetisi).
- **Database Latihan & Diet Kustom:** Semua data latihan, program, resep, dan rencana diet dikelola sepenuhnya melalui Cloud Firestore, memungkinkan kontrol penuh dan skalabilitas.
- **Rekomendasi Diet Personal:** Menampilkan rencana makan harian (sarapan, makan siang, makan malam) yang disesuaikan dengan tujuan pengguna (`fat_loss` atau `muscle_gain`).
- **Pelacakan Progres:**
  - **Riwayat Latihan:** Setiap sesi latihan yang selesai akan dicatat dan dapat dilihat kembali secara detail.
  - **Pelacakan Kalori:** Pengguna dapat mencatat makanan yang dikonsumsi, dan aplikasi akan melacak total asupan kalori harian.
  - **Dasbor Visual:** Halaman Laporan menampilkan grafik aktivitas mingguan untuk memotivasi pengguna.
- **Manajemen Profil:** Pengguna dapat melihat dan memperbarui data profil mereka kapan saja.
- **Konten Motivasi:** Halaman khusus berisi kutipan dan cerita inspiratif untuk menjaga semangat pengguna.

## 🛠️ Teknologi yang Digunakan

- **Framework:** Flutter 3.x
- **Bahasa:** Dart
- **Backend & Database:** Firebase (Authentication, Cloud Firestore)
- **Manajemen State:** `StatefulWidget` & `FutureBuilder` (untuk manajemen state lokal dan async)
- **Package Pihak Ketiga:**
  - `firebase_core`, `firebase_auth`, `cloud_firestore`: Untuk integrasi dengan Firebase.
  - `fl_chart`: Untuk membuat grafik visual di halaman laporan.
  - `intl`: Untuk format tanggal yang mudah dibaca.
  - `flutter_svg` (direkomendasikan): Untuk menggunakan ikon SVG.

## 🚀 Memulai Proyek

Untuk menjalankan proyek ini di lingkungan lokal Anda, ikuti langkah-langkah berikut:

### Prasyarat

- Pastikan Anda sudah menginstal [Flutter SDK](https://flutter.dev/docs/get-started/install).
- Sebuah akun Firebase dan proyek Firebase yang sudah dibuat.

### Instalasi

1. **Clone repository ini:**

    ```bash
    git clone https://github.com/clownface471/fitgo.git
    cd fitgo
    ```

2. **Siapkan Firebase:**
    - Ikuti petunjuk di [dokumentasi FlutterFire](https://firebase.flutter.dev/docs/cli) untuk menginstal Firebase CLI dan menghubungkan proyek Flutter Anda dengan proyek Firebase Anda.
    - Jalankan `flutterfire configure` untuk menghasilkan file `lib/firebase_options.dart`.
    - Di Firebase Console, aktifkan **Authentication** (dengan provider Email/Password) dan **Cloud Firestore** (dalam mode tes).

3. **Unggah Data Awal (Opsional, tapi Direkomendasikan):**
    - Aplikasi ini dirancang untuk bekerja dengan data dari `assets/data/`.
    - Gunakan `DataUploader` script di `lib/utils/data_uploader.dart` untuk mengunggah `exercises.json`, `workout_plans.json`, `recipes.json`, dll., ke Firestore Anda.
    - Pastikan untuk menjalankan fungsi `uploadAllData()` sekali dari `main.dart`, lalu berikan komentar lagi.

4. **Install dependensi:**

    ```bash
    flutter pub get
    ```

5. **Jalankan aplikasi:**

    ```bash
    flutter run
    ```

## 🤝 Kontribusi

Kontribusi, isu, dan permintaan fitur sangat diterima! Jangan ragu untuk membuka *issue* atau *pull request*.

---
*Aplikasi ini dikembangkan sebagai bagian dari proyek kolaboratif.*
