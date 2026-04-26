# Perpustakaan Mobile (Flutter & Laravel)

Aplikasi manajemen perpustakaan digital modern yang dibangun menggunakan framework **Flutter** untuk sisi mobile dan **Laravel** sebagai backend API. Proyek ini dirancang untuk memudahkan pengelola perpustakaan dalam melakukan manajemen data buku, anggota, serta pencatatan transaksi peminjaman secara real-time.

## ✨ Fitur Utama

- **Autentikasi Pengguna**: Sistem Login dan Register untuk pengelola (Admin/Petugas).
- **Manajemen Koleksi Buku**: Operasi CRUD lengkap (Create, Read, Update, Delete) untuk data buku.
- **Manajemen Anggota**: Pengelolaan data member perpustakaan yang terdaftar.
- **Sistem Transaksi**: Pencatatan peminjaman dan pengembalian buku secara digital.
- **RESTful API**: Integrasi yang mulus antara frontend mobile dan backend server.
- **Komentar Kode Profesional**: Kode didokumentasikan dengan baik menggunakan standar industri (Bahasa Indonesia).

## 🛠️ Arsitektur & Teknologi

### Backend (API)
- **Framework**: Laravel 11 (PHP)
- **Database**: MySQL
- **Autentikasi**: JWT (JSON Web Token)
- **Folder**: `/api_laravel`

### Frontend (Mobile)
- **Framework**: Flutter (Dart)
- **State Management**: Provider / Controller Based
- **Folder**: `/mobile_flutter`

## 🚀 Cara Instalasi

### Prasyarat
- PHP >= 8.2
- Composer
- Flutter SDK
- MySQL / XAMPP

### Langkah-langkah
1. **Clone Repositori**
   ```bash
   git clone https://github.com/irsyad-ku/perpustakaan_mobile.git
   cd perpustakaan_mobile
   ```

2. **Setup Backend (Laravel)**
   ```bash
   cd api_laravel
   composer install
   cp .env.example .env
   php artisan key:generate
   php artisan migrate
   php artisan serve
   ```

3. **Setup Frontend (Flutter)**
   ```bash
   cd ../mobile_flutter
   flutter pub get
   flutter run
   ```

## 📝 Catatan Pengembangan
Proyek ini dikembangkan dengan prinsip *Clean Code* dan didokumentasikan dalam Bahasa Indonesia untuk memudahkan pemahaman alur logika aplikasi.

---
Membangun dengan semangat oleh [Irsyad](https://github.com/irsyad-ku)
