import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

String get _baseUrl {
  if (kIsWeb) return 'http://localhost:3000';
  return 'http://172.20.10.3:3000';
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  String? _token;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _currentUser != null && _token != null;

  Map<String, String> get authHeaders => {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      };

  /// Restores saved JWT session on app startup.
  Future<void> loadSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('auth_token');
    if (savedToken == null) return;

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/auth/profile'),
            headers: {'Authorization': 'Bearer $savedToken'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _token = savedToken;
        _currentUser = UserModel.fromJson(data);
        notifyListeners();
      } else {
        await prefs.remove('auth_token');
      }
    } catch (_) {
      // Silently fail — user will need to re-login
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email.trim(), 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _token = data['token'] as String;
        _currentUser =
            UserModel.fromJson(data['user'] as Map<String, dynamic>);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        notifyListeners();
        return null;
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['error'] as String? ?? 'Login gagal';
    } on SocketException {
      return 'Tidak bisa terhubung ke server';
    } on TimeoutException {
      return 'Koneksi timeout. Coba lagi.';
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name.trim(),
              'email': email.trim(),
              'password': password,
              'phone': phone.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        return login(email.trim(), password);
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['error'] as String? ?? 'Registrasi gagal';
    } on SocketException {
      return 'Tidak bisa terhubung ke server';
    } on TimeoutException {
      return 'Koneksi timeout. Coba lagi.';
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<String?> updateProfile({
    required String name,
    required String phone,
  }) async {
    if (_token == null) return 'Tidak terautentikasi';
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/api/auth/profile'),
            headers: authHeaders,
            body: jsonEncode({'name': name.trim(), 'phone': phone.trim()}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _currentUser =
            UserModel.fromJson(data['user'] as Map<String, dynamic>);
        notifyListeners();
        return null;
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['error'] as String? ?? 'Update profil gagal';
    } on SocketException {
      return 'Tidak bisa terhubung ke server';
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      try {
        await http
            .post(
              Uri.parse('$_baseUrl/api/auth/logout'),
              headers: authHeaders,
            )
            .timeout(const Duration(seconds: 10));
      } catch (_) {
        // Proceed with local logout even if server call fails
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
    _currentUser = null;
    notifyListeners();
  }
}
