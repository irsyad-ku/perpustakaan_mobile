enum DataStatus { initial, loading, loaded, error }

// ── Buku ────────────────────────────────────────────────────────────────────
class Buku {
  final int id;
  final String judul;
  final String pengarang;
  final String penerbit;
  final String tahunTerbit;
  final String isbn;
  final int stok;
  final String kategori;

  Buku({
    required this.id,
    required this.judul,
    required this.pengarang,
    required this.penerbit,
    required this.tahunTerbit,
    required this.isbn,
    required this.stok,
    required this.kategori,
  });

  factory Buku.fromJson(Map<String, dynamic> json) => Buku(
        id: json['id'],
        judul: json['judul'] ?? '',
        pengarang: json['pengarang'] ?? '',
        penerbit: json['penerbit'] ?? '',
        tahunTerbit: json['tahun_terbit']?.toString() ?? '',
        isbn: json['isbn'] ?? '',
        stok: json['stok'] ?? 0,
        kategori: json['kategori'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'judul': judul,
        'pengarang': pengarang,
        'penerbit': penerbit,
        'tahun_terbit': tahunTerbit,
        'isbn': isbn,
        'stok': stok,
        'kategori': kategori,
      };
}

// ── Anggota ─────────────────────────────────────────────────────────────────
class Anggota {
  final int id;
  final String nama;
  final String email;
  final String noHp;
  final String alamat;
  final String tanggalDaftar;
  final String status;

  Anggota({
    required this.id,
    required this.nama,
    required this.email,
    required this.noHp,
    required this.alamat,
    required this.tanggalDaftar,
    required this.status,
  });

  factory Anggota.fromJson(Map<String, dynamic> json) => Anggota(
        id: json['id'],
        nama: json['nama'] ?? '',
        email: json['email'] ?? '',
        noHp: json['no_hp'] ?? '',
        alamat: json['alamat'] ?? '',
        tanggalDaftar: json['tgl_daftar'] ?? json['tanggal_daftar'] ?? '',
        status: json['status'] ?? 'aktif',
      );

  Map<String, dynamic> toJson() => {
        'nama': nama,
        'email': email,
        'no_hp': noHp,
        'alamat': alamat,
        'tanggal_daftar': tanggalDaftar,
        'status': status,
      };
}

// ── Peminjaman ───────────────────────────────────────────────────────────────
class Peminjaman {
  final int id;
  final int bukuId;
  final int anggotaId;
  final String judulBuku;
  final String namaAnggota;
  final String tanggalPinjam;
  final String tanggalKembaliRencana;
  final String? tanggalKembaliAktual;
  final String status;

  Peminjaman({
    required this.id,
    required this.bukuId,
    required this.anggotaId,
    required this.judulBuku,
    required this.namaAnggota,
    required this.tanggalPinjam,
    required this.tanggalKembaliRencana,
    this.tanggalKembaliAktual,
    required this.status,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) => Peminjaman(
        id: json['id'],
        bukuId: json['buku_id'] ?? 0,
        anggotaId: json['anggota_id'] ?? 0,
        judulBuku: json['buku']?['judul'] ?? json['judul_buku'] ?? '',
        namaAnggota: json['anggota']?['nama'] ?? json['nama_anggota'] ?? '',
        tanggalPinjam: json['tgl_pinjam'] ?? json['tanggal_pinjam'] ?? '',
        tanggalKembaliRencana: json['tgl_kembali_rencana'] ?? json['tanggal_kembali_rencana'] ?? '',
        tanggalKembaliAktual: json['tgl_kembali_aktual'] ?? json['tanggal_kembali_aktual'],
        status: json['status'] ?? 'dipinjam',
      );

  Map<String, dynamic> toJson() => {
        'buku_id': bukuId,
        'anggota_id': anggotaId,
        'tanggal_pinjam': tanggalPinjam,
        'tanggal_kembali_rencana': tanggalKembaliRencana,
        'status': status,
      };
}
