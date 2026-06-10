import 'package:flutter/foundation.dart';

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
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Dummy users
  final List<Map<String, String>> _users = [
    {
      'id': '1',
      'name': 'Demo User',
      'email': 'demo@kostmap.id',
      'phone': '081234567890',
      'password': 'demo123',
    },
  ];

  Future<String?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final user = _users.firstWhere(
      (u) => u['email'] == email.trim().toLowerCase() && u['password'] == password,
      orElse: () => {},
    );

    if (user.isEmpty) return 'Email atau password salah.';

    _currentUser = UserModel(
      id: user['id']!,
      name: user['name']!,
      email: user['email']!,
      phone: user['phone']!,
    );
    notifyListeners();
    return null;
  }

  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final exists = _users.any((u) => u['email'] == email.trim().toLowerCase());
    if (exists) return 'Email sudah terdaftar.';

    final newId = (_users.length + 1).toString();
    _users.add({
      'id': newId,
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'phone': phone.trim(),
      'password': password,
    });

    _currentUser = UserModel(
      id: newId,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
    );
    notifyListeners();
    return null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
