import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  String? _error;
  String? _userName;

  AuthStatus get status => _status;
  String? get error => _error;
  String? get userName => _userName;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> checkAuth() async {
    final token = await ApiService.getToken();
    if (token != null) {
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final res = await ApiService.login(email, password);
      if (res['token'] != null) {
        await ApiService.saveToken(res['token']);
        _userName = res['user']?['name'];
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _error = res['message'] ?? 'Login gagal';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Koneksi gagal. Cek server backend.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String passwordConfirmation) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final res = await ApiService.register(name, email, password, passwordConfirmation);
      if (res['status'] == 'success' || res['message']?.toString().contains('berhasil') == true) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return true;
      } else {
        _error = res['message'] ?? 'Registrasi gagal';
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Koneksi gagal. Cek server backend.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    _status = AuthStatus.unauthenticated;
    _userName = null;
    notifyListeners();
  }
}
