import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/photo_item.dart';
import 'api_config.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  ApiService._();

  /// Login এর পর token এখানে জমা থাকবে
  static String? token;

  // ---------------- LOGIN ----------------
  static Future<void> login(String email, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse(ApiConfig.login),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 20));

      final body = _decode(res.body);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final t = _findToken(body);
        if (t == null) {
          throw ApiException('Response এ token পাওয়া যায়নি');
        }
        token = t;
      } else {
        throw ApiException(_errorMessage(body) ?? 'Login ব্যর্থ হয়েছে');
      }
    } on SocketException {
      throw ApiException('Server এর সাথে সংযোগ হচ্ছে না। Network/IP চেক করো।');
    } on TimeoutException {
      throw ApiException('Server সাড়া দিচ্ছে না (timeout)');
    }
  }

  // ---------------- MY PHOTOS ----------------
  static Future<List<PhotoItem>> getMyPhotos({
    String? tag,
    String? date,
    bool? isFavorite,
    String? sort, // যেমন: '-createdAt'
  }) async {
    final query = <String, String>{
      if (tag != null) 'tag': tag,
      if (date != null) 'date': date,
      if (isFavorite != null) 'isFavorite': isFavorite.toString(),
      if (sort != null) 'sort': sort,
    };

    final uri = Uri.parse(ApiConfig.myPhotos)
        .replace(queryParameters: query.isEmpty ? null : query);

    try {
      final res = await http.get(
        uri,
        // Postman এ Authorization এ শুধু token দেওয়া আছে, "Bearer" নেই
        headers: {'Authorization': token ?? ''},
      ).timeout(const Duration(seconds: 20));

      final body = _decode(res.body);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final list = _findList(body);
        return list.map((e) => PhotoItem.fromJson(e)).toList();
      } else {
        throw ApiException(_errorMessage(body) ?? 'ছবি আনা যায়নি');
      }
    } on SocketException {
      throw ApiException('Server এর সাথে সংযোগ হচ্ছে না। Network/IP চেক করো।');
    } on TimeoutException {
      throw ApiException('Server সাড়া দিচ্ছে না (timeout)');
    }
  }

  // ---------------- helpers ----------------
  static dynamic _decode(String s) {
    try {
      return jsonDecode(s);
    } catch (_) {
      return null;
    }
  }

  static String? _errorMessage(dynamic body) {
    if (body is Map && body['message'] != null) {
      return body['message'].toString();
    }
    return null;
  }

  /// Response এর ভেতর যেকোনো জায়গা থেকে token খুঁজে বের করে
  static String? _findToken(dynamic node) {
    if (node is Map) {
      for (final key in ['accessToken', 'token', 'access_token']) {
        final v = node[key];
        if (v is String && v.isNotEmpty) return v;
      }
      for (final v in node.values) {
        final r = _findToken(v);
        if (r != null) return r;
      }
    }
    return null;
  }

  /// Response এর ভেতর থেকে ছবির list টা খুঁজে বের করে
  static List<Map<String, dynamic>> _findList(dynamic node) {
    if (node is List) {
      return node.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (node is Map) {
      for (final v in node.values) {
        final r = _findList(v);
        if (r.isNotEmpty) return r;
      }
    }
    return [];
  }
}
