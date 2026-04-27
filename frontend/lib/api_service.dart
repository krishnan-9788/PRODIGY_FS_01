import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String authKey = 'jwt_token';

  /// Choose the proper host depending on the Flutter target.
  ///
  /// - Web: use localhost or 127.0.0.1 for local backend access.
  /// - Android emulator: use 10.0.2.2.
  /// - Real device: replace with your machine IP, e.g. http://192.168.1.100:5000
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000';
    }
    return 'http://10.0.2.2:5000';
  }

  Future<http.Response> _safePost(String path, Map<String, dynamic> body) async {
    try {
      return await http.post(
        Uri.parse('$baseUrl$path'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } catch (error) {
      throw Exception('Network error: Unable to connect to server');
    }
  }

  Future<Map<String, dynamic>> _buildResult(http.Response response) async {
    final data = response.body.isNotEmpty ? jsonDecode(response.body) : <String, dynamic>{};
    return {'status': response.statusCode, 'data': data};
  }

  Future<Map<String, dynamic>> register(String username, String password) async {
    try {
      final response = await _safePost('/api/auth/register', {
        'username': username,
        'password': password,
      });
      return await _buildResult(response);
    } catch (error) {
      return {
        'status': 500,
        'data': {'error': error.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _safePost('/api/auth/login', {
        'username': username,
        'password': password,
      });

      final result = await _buildResult(response);
      final data = result['data'] as Map<String, dynamic>;

      if (response.statusCode == 200 && data.containsKey('token')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(authKey, data['token']);
      }

      return result;
    } catch (error) {
      return {
        'status': 500,
        'data': {'error': error.toString()},
      };
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(authKey);
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(authKey);

      if (token == null || token.isEmpty) {
        return {
          'status': 401,
          'data': {'error': 'Unauthorized: No token found. Please login again.'},
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/protected/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return await _buildResult(response);
    } catch (error) {
      return {
        'status': 500,
        'data': {'error': 'Network error: Unable to connect to server'},
      };
    }
  }
}
