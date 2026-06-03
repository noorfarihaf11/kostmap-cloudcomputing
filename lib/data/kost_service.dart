import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/kost_model.dart';

String get _baseUrl {
  if (kIsWeb) return 'http://localhost:3000';
  return 'http://192.168.1.7:3000'; // physical device on same WiFi
}

class KostService {
  static Future<List<Kost>> fetchAllKost({String? label}) async {
    final params = <String, String>{};
    if (label != null && label != 'Semua') params['label'] = label;

    final uri =
        Uri.parse('$_baseUrl/api/kost').replace(queryParameters: params);
    return _getList(uri);
  }

  static Future<Kost> fetchKostById(dynamic id) async {
    final response = await _get(Uri.parse('$_baseUrl/api/kost/$id'));
    return Kost.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<List<Kost>> fetchNearbyKost(
    double lat,
    double lng, {
    int limit = 20,
  }) async {
    final uri =
        Uri.parse('$_baseUrl/api/kost/nearby').replace(queryParameters: {
      'lat': lat.toString(),
      'lng': lng.toString(),
      'limit': limit.toString(),
    });
    return _getList(uri);
  }

  static Future<List<Kost>> _getList(Uri uri) async {
    final response = await _get(uri);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['data'] as List)
        .map((e) => Kost.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<http.Response> _get(Uri uri) async {
    try {
      final response =
          await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) return response;
      throw Exception(
          'Server error ${response.statusCode}: ${response.body}');
    } on SocketException catch (e) {
      throw Exception(
          'Tidak bisa terhubung ke server.\nPastikan backend sudah berjalan.\n(${e.message})');
    } on TimeoutException {
      throw Exception('Koneksi timeout. Coba lagi.');
    }
  }
}
