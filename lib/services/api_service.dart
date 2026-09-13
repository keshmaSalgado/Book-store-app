import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });
}

class ApiService {
  static const String _tokenKey = 'bookverse_jwt_token';
  static const String _userRoleKey = 'bookverse_user_role';
  static const String _userIdKey = 'bookverse_user_id';
  static const String _userNameKey = 'bookverse_user_name';
  static const String _userEmailKey = 'bookverse_user_email';

  // Session Token Management
  static Future<void> saveSession({
    required String token,
    required String role,
    required int userId,
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userRoleKey, role);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userRoleKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }

  // Common Headers Builder
  static Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Standard GET Request
  static Future<ApiResponse<dynamic>> get(String url, {bool requiresAuth = false}) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http.get(Uri.parse(url), headers: headers);
      return _processResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection failed: Ensure PHP API / Apache is running. ($e)',
        statusCode: 500,
      );
    }
  }

  // Standard POST Request
  static Future<ApiResponse<dynamic>> post(String url, Map<String, dynamic> body, {bool requiresAuth = false}) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection failed: Ensure PHP API / Apache is running. ($e)',
        statusCode: 500,
      );
    }
  }

  // Standard PUT Request
  static Future<ApiResponse<dynamic>> put(String url, Map<String, dynamic> body, {bool requiresAuth = true}) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection failed: Ensure PHP API / Apache is running. ($e)',
        statusCode: 500,
      );
    }
  }

  // Standard DELETE Request
  static Future<ApiResponse<dynamic>> delete(String url, {bool requiresAuth = true}) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      final response = await http.delete(Uri.parse(url), headers: headers);
      return _processResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Connection failed: Ensure PHP API / Apache is running. ($e)',
        statusCode: 500,
      );
    }
  }

  // Response Processor
  static ApiResponse<dynamic> _processResponse(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) {
        final success = decoded['success'] == true;
        final message = decoded['message']?.toString() ?? (success ? 'Success' : 'Error');
        final data = decoded['data'];

        return ApiResponse(
          success: success,
          message: message,
          data: data,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse(
          success: response.statusCode >= 200 && response.statusCode < 300,
          message: 'Received unexpected response format',
          data: decoded,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error parsing server response: ${response.body.isNotEmpty ? response.body : response.statusCode.toString()}',
        statusCode: response.statusCode,
      );
    }
  }
}
