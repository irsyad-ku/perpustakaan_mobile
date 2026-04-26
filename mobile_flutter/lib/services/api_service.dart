import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  /**
   * Mengambil token autentikasi yang tersimpan di penyimpanan lokal (SharedPreferences).
   * 
   * @return String? Token akses jika tersedia, null jika tidak ada.
   */
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /**
   * Menyimpan token autentikasi ke penyimpanan lokal setelah login berhasil.
   * 
   * @param String token Token akses yang diterima dari server.
   */
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  /**
   * Menghapus token autentikasi dari penyimpanan lokal saat logout.
   */
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  /**
   * Menghasilkan header HTTP standar untuk setiap permintaan API.
   * Menyertakan Authorization header jika token tersedia.
   * 
   * @return Map<String, String> Koleksi header HTTP.
   */
  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── AUTHENTICATION ─────────────────────────────────────

  /**
   * Melakukan login pengguna ke sistem.
   * 
   * @param String email Alamat email pengguna.
   * @param String password Kata sandi pengguna.
   * @return Map<String, dynamic> Respon dari server yang berisi token atau pesan error.
   */
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  /**
   * Mendaftarkan akun pengelola baru ke sistem.
   * 
   * @param String name Nama lengkap.
   * @param String email Alamat email unik.
   * @param String password Kata sandi.
   * @param String passwordConfirmation Konfirmasi kata sandi.
   * @return Map<String, dynamic> Respon dari server.
   */
  static Future<Map<String, dynamic>> register(
      String name, String email, String password, String passwordConfirmation) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );
    return jsonDecode(res.body);
  }

  /**
   * Mengakhiri sesi pengguna dan membersihkan data autentikasi lokal.
   */
  static Future<void> logout() async {
    final headers = await getHeaders();
    await http.post(Uri.parse('$baseUrl/auth/logout'), headers: headers);
    await removeToken();
  }

  // ── MANAJEMEN BUKU ─────────────────────────────────────

  /**
   * Mengambil daftar seluruh koleksi buku dari database.
   * 
   * @return List<dynamic> Daftar objek buku.
   */
  static Future<List<dynamic>> getBukus() async {
    final headers = await getHeaders();
    final res = await http.get(Uri.parse('$baseUrl/bukus'), headers: headers);
    final data = jsonDecode(res.body);
    return data['data'] ?? [];
  }

  /**
   * Menambahkan data buku baru ke koleksi perpustakaan.
   * 
   * @param Map<String, dynamic> body Data buku yang akan disimpan.
   * @return Map<String, dynamic> Objek buku yang berhasil dibuat.
   */
  static Future<Map<String, dynamic>> createBuku(Map<String, dynamic> body) async {
    final headers = await getHeaders();
    final res = await http.post(
      Uri.parse('$baseUrl/bukus'),
      headers: headers,
      body: jsonEncode(body),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Gagal membuat data buku: ${res.statusCode}');
    }
    return jsonDecode(res.body);
  }

  /**
   * Memperbarui data buku yang sudah ada berdasarkan ID.
   * 
   * @param int id ID unik buku.
   * @param Map<String, dynamic> body Data buku yang diperbarui.
   * @return Map<String, dynamic> Objek buku hasil pembaruan.
   */
  static Future<Map<String, dynamic>> updateBuku(int id, Map<String, dynamic> body) async {
    final headers = await getHeaders();
    final res = await http.put(
      Uri.parse('$baseUrl/bukus/$id'),
      headers: headers,
      body: jsonEncode(body),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Gagal memperbarui data buku: ${res.statusCode}');
    }
    return jsonDecode(res.body);
  }

  /**
   * Menghapus data buku dari sistem berdasarkan ID.
   * 
   * @param int id ID unik buku yang akan dihapus.
   */
  static Future<void> deleteBuku(int id) async {
    final headers = await getHeaders();
    final res = await http.delete(Uri.parse('$baseUrl/bukus/$id'), headers: headers);
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Gagal menghapus data buku: ${res.statusCode}');
    }
  }

  // ── MANAJEMEN ANGGOTA ──────────────────────────────────

  /**
   * Mengambil daftar seluruh anggota perpustakaan yang terdaftar.
   * 
   * @return List<dynamic> Daftar objek anggota.
   */
  static Future<List<dynamic>> getAnggotas() async {
    final headers = await getHeaders();
    final res = await http.get(Uri.parse('$baseUrl/anggotas'), headers: headers);
    final data = jsonDecode(res.body);
    return data['data'] ?? [];
  }

  /**
   * Mendaftarkan anggota baru ke dalam sistem.
   * 
   * @param Map<String, dynamic> body Data lengkap anggota.
   * @return Map<String, dynamic> Objek anggota yang berhasil didaftarkan.
   */
  static Future<Map<String, dynamic>> createAnggota(Map<String, dynamic> body) async {
    final headers = await getHeaders();
    final res = await http.post(
      Uri.parse('$baseUrl/anggotas'),
      headers: headers,
      body: jsonEncode(body),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Gagal mendaftarkan anggota: ${res.statusCode}');
    }
    return jsonDecode(res.body);
  }

  /**
   * Memperbarui informasi profil anggota perpustakaan.
   * 
   * @param int id ID unik anggota.
   * @param Map<String, dynamic> body Data anggota yang diperbarui.
   * @return Map<String, dynamic> Objek anggota hasil pembaruan.
   */
  static Future<Map<String, dynamic>> updateAnggota(int id, Map<String, dynamic> body) async {
    final headers = await getHeaders();
    final res = await http.put(
      Uri.parse('$baseUrl/anggotas/$id'),
      headers: headers,
      body: jsonEncode(body),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Gagal memperbarui data anggota: ${res.statusCode}');
    }
    return jsonDecode(res.body);
  }

  /**
   * Menghapus data anggota dari database.
   * 
   * @param int id ID unik anggota yang akan dihapus.
   */
  static Future<void> deleteAnggota(int id) async {
    final headers = await getHeaders();
    final res = await http.delete(Uri.parse('$baseUrl/anggotas/$id'), headers: headers);
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Gagal menghapus data anggota: ${res.statusCode}');
    }
  }

  // ── TRANSAKSI PEMINJAMAN ───────────────────────────────

  /**
   * Mengambil seluruh riwayat transaksi peminjaman buku.
   * 
   * @return List<dynamic> Daftar transaksi peminjaman.
   */
  static Future<List<dynamic>> getPeminjamans() async {
    final headers = await getHeaders();
    final res = await http.get(Uri.parse('$baseUrl/peminjamans'), headers: headers);
    final data = jsonDecode(res.body);
    return data['data'] ?? [];
  }

  /**
   * Mencatat transaksi peminjaman buku baru oleh anggota.
   * 
   * @param Map<String, dynamic> body Data transaksi peminjaman.
   * @return Map<String, dynamic> Objek transaksi yang berhasil dicatat.
   */
  static Future<Map<String, dynamic>> createPeminjaman(Map<String, dynamic> body) async {
    final headers = await getHeaders();
    final res = await http.post(
      Uri.parse('$baseUrl/peminjamans'),
      headers: headers,
      body: jsonEncode(body),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Gagal mencatat peminjaman: ${res.statusCode}');
    }
    return jsonDecode(res.body);
  }

  /**
   * Memperbarui status atau detail transaksi peminjaman (misal: pengembalian buku).
   * 
   * @param int id ID transaksi peminjaman.
   * @param Map<String, dynamic> body Data yang akan diperbarui.
   * @return Map<String, dynamic> Objek transaksi hasil pembaruan.
   */
  static Future<Map<String, dynamic>> updatePeminjaman(int id, Map<String, dynamic> body) async {
    final headers = await getHeaders();
    final res = await http.put(
      Uri.parse('$baseUrl/peminjamans/$id'),
      headers: headers,
      body: jsonEncode(body),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Gagal memperbarui transaksi: ${res.statusCode}');
    }
    return jsonDecode(res.body);
  }

  /**
   * Menghapus catatan transaksi peminjaman.
   * 
   * @param int id ID transaksi peminjaman yang akan dihapus.
   */
  static Future<void> deletePeminjaman(int id) async {
    final headers = await getHeaders();
    final res = await http.delete(Uri.parse('$baseUrl/peminjamans/$id'), headers: headers);
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Gagal menghapus catatan transaksi: ${res.statusCode}');
    }
  }
}
