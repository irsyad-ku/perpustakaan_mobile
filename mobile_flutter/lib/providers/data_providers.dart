import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AnggotaProvider extends ChangeNotifier {
  DataStatus _status = DataStatus.initial;
  List<Anggota> _anggotas = [];
  List<Anggota> _filtered = [];
  String? _error;
  String _search = '';
  String _filterStatus = '';

  DataStatus get status => _status;
  List<Anggota> get anggotas => _filtered;
  String? get error => _error;
  String get filterStatus => _filterStatus;
  String get search => _search;

  Future<void> fetchAnggotas() async {
    _status = DataStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.getAnggotas();
      _anggotas = data.map((e) => Anggota.fromJson(e)).toList();
      _applyFilter();
      _status = DataStatus.loaded;
    } catch (e) {
      _error = 'Gagal memuat data anggota';
      _status = DataStatus.error;
    }
    notifyListeners();
  }

  void setSearch(String val) { _search = val; _applyFilter(); notifyListeners(); }
  void setFilterStatus(String val) { _filterStatus = val; _applyFilter(); notifyListeners(); }
  void resetFilter() { _search = ''; _filterStatus = ''; _applyFilter(); notifyListeners(); }

  void _applyFilter() {
    _filtered = _anggotas.where((a) {
      final ms = _search.isEmpty || a.nama.toLowerCase().contains(_search.toLowerCase()) || a.email.toLowerCase().contains(_search.toLowerCase()) || a.noHp.contains(_search);
      final mf = _filterStatus.isEmpty || a.status == _filterStatus;
      return ms && mf;
    }).toList();
  }

  Future<bool> createAnggota(Map<String, dynamic> body) async { 
    try { 
      final res = await ApiService.createAnggota(body);
      print('CREATE ANGGOTA SUCCESS: $res');
      await fetchAnggotas(); 
      return true; 
    } catch (e) { 
      print('CREATE ANGGOTA ERROR: $e');
      return false; 
    } 
  }
  Future<bool> updateAnggota(int id, Map<String, dynamic> body) async { 
    try { 
      await ApiService.updateAnggota(id, body); 
      await fetchAnggotas(); 
      return true; 
    } catch (e) { 
      print('UPDATE ANGGOTA ERROR: $e');
      return false; 
    } 
  }
  Future<bool> deleteAnggota(int id) async { 
    try { 
      await ApiService.deleteAnggota(id); 
      await fetchAnggotas(); 
      return true; 
    } catch (e) { 
      print('DELETE ANGGOTA ERROR: $e');
      return false; 
    } 
  }
}

class PeminjamanProvider extends ChangeNotifier {
  DataStatus _status = DataStatus.initial;
  List<Peminjaman> _peminjamans = [];
  List<Peminjaman> _filtered = [];
  String? _error;
  String _search = '';
  String _filterStatus = '';

  DataStatus get status => _status;
  List<Peminjaman> get peminjamans => _filtered;
  List<Peminjaman> get allPeminjamans => _peminjamans;
  String? get error => _error;
  String get filterStatus => _filterStatus;
  String get search => _search;

  Future<void> fetchPeminjamans() async {
    _status = DataStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.getPeminjamans();
      _peminjamans = data.map((e) => Peminjaman.fromJson(e)).toList();
      _applyFilter();
      _status = DataStatus.loaded;
    } catch (e) {
      _error = 'Gagal memuat data peminjaman';
      _status = DataStatus.error;
    }
    notifyListeners();
  }

  void setSearch(String val) { _search = val; _applyFilter(); notifyListeners(); }
  void setFilterStatus(String val) { _filterStatus = val; _applyFilter(); notifyListeners(); }
  void resetFilter() { _search = ''; _filterStatus = ''; _applyFilter(); notifyListeners(); }

  void _applyFilter() {
    _filtered = _peminjamans.where((p) {
      final ms = _search.isEmpty || p.judulBuku.toLowerCase().contains(_search.toLowerCase()) || p.namaAnggota.toLowerCase().contains(_search.toLowerCase());
      final mf = _filterStatus.isEmpty || p.status == _filterStatus;
      return ms && mf;
    }).toList();
  }

  Future<bool> createPeminjaman(Map<String, dynamic> body) async { 
    try { 
      await ApiService.createPeminjaman(body); 
      await fetchPeminjamans(); 
      return true; 
    } catch (e) { 
      print('CREATE PEMINJAMAN ERROR: $e');
      return false; 
    } 
  }
  Future<bool> updatePeminjaman(int id, Map<String, dynamic> body) async { 
    try { 
      await ApiService.updatePeminjaman(id, body); 
      await fetchPeminjamans(); 
      return true; 
    } catch (e) { 
      print('UPDATE PEMINJAMAN ERROR: $e');
      return false; 
    } 
  }
  Future<bool> deletePeminjaman(int id) async { 
    try { 
      await ApiService.deletePeminjaman(id); 
      await fetchPeminjamans(); 
      return true; 
    } catch (e) { 
      print('DELETE PEMINJAMAN ERROR: $e');
      return false; 
    } 
  }
}
