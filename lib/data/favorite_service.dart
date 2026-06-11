import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../models/kost_model.dart';

String get _baseUrl {
  if (kIsWeb) return 'http://localhost:3000';
  return 'http://172.20.10.3:3000';
}

class FavoriteService extends ChangeNotifier {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;

  FavoriteService._internal() {
    AuthService().addListener(_onAuthChanged);
  }

  List<Kost> _favorites = [];
  bool _isLoading = false;
  String? _error;

  List<Kost> get favorites => List.unmodifiable(_favorites);
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isFavorite(dynamic kostId) =>
      _favorites.any((k) => k.id.toString() == kostId.toString());

  void _onAuthChanged() {
    if (!AuthService().isLoggedIn) {
      _favorites = [];
      _error = null;
      notifyListeners();
    }
  }

  Future<void> loadFavorites() async {
    if (!AuthService().isLoggedIn) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/favorites'),
            headers: AuthService().authHeaders,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        _favorites = list
            .map((e) => Kost.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        _error = 'Gagal memuat favorit';
      }
    } on SocketException {
      _error = 'Tidak bisa terhubung ke server';
    } on TimeoutException {
      _error = 'Koneksi timeout';
    } catch (_) {
      _error = 'Terjadi kesalahan';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleFavorite(Kost kost) async {
    if (!AuthService().isLoggedIn) return false;

    final alreadyFav = isFavorite(kost.id);

    // Optimistic update
    if (alreadyFav) {
      _favorites.removeWhere((k) => k.id.toString() == kost.id.toString());
    } else {
      _favorites.add(kost);
    }
    notifyListeners();

    try {
      http.Response response;
      if (alreadyFav) {
        response = await http
            .delete(
              Uri.parse('$_baseUrl/api/favorites/${kost.id}'),
              headers: AuthService().authHeaders,
            )
            .timeout(const Duration(seconds: 15));
      } else {
        response = await http
            .post(
              Uri.parse('$_baseUrl/api/favorites'),
              headers: AuthService().authHeaders,
              body: jsonEncode({'kost_id': kost.id}),
            )
            .timeout(const Duration(seconds: 15));
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        // Revert on failure
        if (alreadyFav) {
          _favorites.add(kost);
        } else {
          _favorites
              .removeWhere((k) => k.id.toString() == kost.id.toString());
        }
        notifyListeners();
        return false;
      }
      return true;
    } catch (_) {
      // Revert on error
      if (alreadyFav) {
        _favorites.add(kost);
      } else {
        _favorites.removeWhere((k) => k.id.toString() == kost.id.toString());
      }
      notifyListeners();
      return false;
    }
  }
}
