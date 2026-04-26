# LAPORAN PENGEMBANGAN PROYEK PERPUSTAKAAN DIGITAL
**Sistem Manajemen Perpustakaan Berbasis Mobile (Flutter) & Web API (Laravel)**

---

## 1. Deskripsi Aplikasi
Aplikasi **Perpustakaan Mobile** adalah solusi digital terpadu untuk manajemen operasional perpustakaan. Aplikasi ini memungkinkan pengelola untuk beralih dari pencatatan manual ke sistem digital yang lebih cepat, akurat, dan dapat diakses kapan saja. 

Aplikasi ini fokus pada tiga pilar utama:
1. **Efisiensi Inventaris**: Manajemen koleksi buku yang terorganisir.
2. **Database Keanggotaan**: Pendataan anggota yang rapi dan terpusat.
3. **Integritas Transaksi**: Pencatatan peminjaman dan pengembalian yang sistematis untuk meminimalisir kehilangan buku.

---

## 2. Arsitektur Sistem
Aplikasi ini menggunakan arsitektur **Client-Server** yang memisahkan logika antarmuka pengguna dengan pengolahan data.

### 🧩 Diagram Arsitektur (Abstraksi)
`Mobile App (Flutter)` <--- *REST API (JSON)* ---> `Server (Laravel)` <---> `Database (MySQL)`

- **Frontend (Mobile)**: Menggunakan Flutter untuk memberikan pengalaman pengguna yang responsif di platform Android dan iOS.
- **Backend (API)**: Menggunakan Laravel 11 untuk menangani logika bisnis, validasi data, keamanan, dan interaksi database.
- **Autentikasi**: Menggunakan sistem **JWT (JSON Web Token)** untuk memastikan setiap permintaan ke server aman dan terverifikasi.

---

## 3. Fitur Utama & Implementasi

### A. Fitur Wajib (Core Features)
1. **Sistem Autentikasi**:
   - Login & Register Petugas (User).
   - Keamanan akses menggunakan Bearer Token.
2. **Manajemen Buku (CRUD)**:
   - Menambah koleksi buku baru.
   - Mengubah informasi buku (judul, pengarang, stok).
   - Menghapus data buku yang sudah tidak tersedia.
3. **Manajemen Anggota**:
   - Pendataan profil anggota perpustakaan secara lengkap.

### B. Fitur Tambahan (Optional/Enhanced)
1. **Sistem Transaksi Peminjaman**:
   - Pencatatan tanggal pinjam dan rencana tanggal kembali.
   - Integrasi status peminjaman secara real-time.
2. **Relasi Data (Eager Loading)**:
   - Backend dioptimalkan untuk memuat data buku dan anggota sekaligus dalam satu permintaan transaksi guna meningkatkan performa.

---

## 4. Best Practices yang Diterapkan
Sebagai standar profesional, proyek ini menerapkan beberapa praktik terbaik industri:

1. **Clean Code & Readable Code**: Penamaan variabel dan fungsi yang deskriptif dan konsisten.
2. **Dokumentasi Kode Internal**: Penulisan komentar formal dalam Bahasa Indonesia pada setiap fungsi penting untuk memudahkan pemeliharaan (maintenance).
3. **Structured Git Commits**: Menggunakan konvensional commit (feat, fix, docs, refactor) agar riwayat perubahan proyek terlacak dengan jelas.
4. **Validasi Data Berlapis**: Validasi dilakukan di sisi mobile (Frontend) dan secara ketat di sisi server (Backend).
5. **RESTful Standards**: Penggunaan metode HTTP (GET, POST, PUT, DELETE) dan kode status respon yang sesuai standar dunia.

---

## 5. Dokumentasi Visual (Screenshot)

| Login & Autentikasi | Dashboard / List Buku |
| :---: | :---: |
| ![Screenshot Login](https://placehold.co/300x600?text=Screenshot+Login) | ![Screenshot Dashboard](https://placehold.co/300x600?text=Screenshot+Dashboard) |

| Form Input Data | Riwayat Peminjaman |
| :---: | :---: |
| ![Screenshot Form Buku](https://placehold.co/300x600?text=Screenshot+Form+Buku) | ![Screenshot Transaksi](https://placehold.co/300x600?text=Screenshot+Transaksi) |

---

## 6. Tautan Penting (Links)
- **Repositori GitHub**: [github.com/irsyad-ku/perpustakaan_mobile](https://github.com/irsyad-ku/perpustakaan_mobile)
- **Video Demo Aplikasi**: [Link Video YouTube Anda di Sini]

---
**Dibuat Oleh:** [Irsyad]
**Tanggal Laporan:** 26 April 2026
