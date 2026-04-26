import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class BukuProvider extends ChangeNotifier {
  DataStatus _status = DataStatus.initial;
  List<Buku> _bukus = [];
  List<Buku> _filtered = [];
  String? _error;
  String _search = '';
  String _filterKategori = '';

  DataStatus get status => _status;
  List<Buku> get bukus => _filtered;
  String? get error => _error;
  String get search => _search;
  String get filterKategori => _filterKategori;

  List<String> get kategoriList {
    final set = _bukus.map((b) => b.kategori).where((k) => k.isNotEmpty).toSet().toList();
    set.sort();
    return set;
  }

  Future<void> fetchBukus() async {
    _status = DataStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.getBukus();
      _bukus = data.map((e) => Buku.fromJson(e)).toList();
      _applyFilter();
      _status = DataStatus.loaded;
    } catch (e) {
      _error = 'Gagal memuat data buku';
      _status = DataStatus.error;
    }
    notifyListeners();
  }

  void setSearch(String val) {
    _search = val;
    _applyFilter();
    notifyListeners();
  }

  void setKategori(String val) {
    _filterKategori = val;
    _applyFilter();
    notifyListeners();
  }

  void resetFilter() {
    _search = '';
    _filterKategori = '';
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    _filtered = _bukus.where((b) {
      final matchSearch = _search.isEmpty ||
          b.judul.toLowerCase().contains(_search.toLowerCase()) ||
          b.pengarang.toLowerCase().contains(_search.toLowerCase()) ||
          b.isbn.toLowerCase().contains(_search.toLowerCase());
      final matchKategori = _filterKategori.isEmpty || b.kategori == _filterKategori;
      return matchSearch && matchKategori;
    }).toList();
  }

  Future<bool> createBuku(Map<String, dynamic> body) async {
    try {
      final res = await ApiService.createBuku(body);
      print('CREATE BUKU SUCCESS: $res');
      await fetchBukus();
      return true;
    } catch (e) {
      print('CREATE BUKU ERROR: $e');
      return false;
    }
  }

  Future<bool> updateBuku(int id, Map<String, dynamic> body) async {
    try {
      await ApiService.updateBuku(id, body);
      await fetchBukus();
      return true;
    } catch (e) {
      print('UPDATE BUKU ERROR: $e');
      return false;
    }
  }

  Future<bool> deleteBuku(int id) async {
    try {
      await ApiService.deleteBuku(id);
      await fetchBukus();
      return true;
    } catch (e) {
      print('DELETE BUKU ERROR: $e');
      return false;
    }
  }
}
