import '../models/user_model.dart';
import '../utils/api_constants.dart';
import 'api_service.dart';

class AuthService {
  // Login user and save token + role to SharedPreferences
  static Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      ApiConstants.login,
      {
        'email': email.trim(),
        'password': password,
      },
      requiresAuth: false,
    );

    if (response.success && response.data != null) {
      final token = response.data['token']?.toString() ?? '';
      final userData = response.data['user'] as Map<String, dynamic>;
      final user = UserModel.fromJson(userData);

      await ApiService.saveSession(
        token: token,
        role: user.role,
        userId: user.id,
        name: user.name,
        email: user.email,
      );

      return ApiResponse(
        success: true,
        message: response.message,
        data: user,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse(
      success: false,
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Register a new customer
  static Future<ApiResponse<dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    return await ApiService.post(
      ApiConstants.register,
      {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'confirm_password': confirmPassword,
      },
      requiresAuth: false,
    );
  }

  // Get current user profile
  static Future<ApiResponse<UserModel>> getProfile() async {
    final response = await ApiService.get(ApiConstants.profile, requiresAuth: true);
    if (response.success && response.data != null) {
      final user = UserModel.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse(
        success: true,
        message: response.message,
        data: user,
        statusCode: response.statusCode,
      );
    }
    return ApiResponse(
      success: false,
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Update profile
  static Future<ApiResponse<UserModel>> updateProfile({
    String? name,
    String? email,
    String? password,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name.trim();
    if (email != null) body['email'] = email.trim();
    if (password != null && password.isNotEmpty) body['password'] = password;

    final response = await ApiService.put(ApiConstants.profile, body, requiresAuth: true);
    if (response.success && response.data != null) {
      final user = UserModel.fromJson(response.data as Map<String, dynamic>);
      // Update locally saved name and email
      await ApiService.saveSession(
        token: (await ApiService.getToken()) ?? '',
        role: user.role,
        userId: user.id,
        name: user.name,
        email: user.email,
      );
      return ApiResponse(
        success: true,
        message: response.message,
        data: user,
        statusCode: response.statusCode,
      );
    }
    return ApiResponse(
      success: false,
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Logout and clear storage
  static Future<void> logout() async {
    try {
      await ApiService.post(ApiConstants.logout, {}, requiresAuth: true);
    } catch (_) {}
    await ApiService.clearSession();
  }

  // Check if currently authenticated
  static Future<bool> isLoggedIn() async {
    final token = await ApiService.getToken();
    return token != null && token.isNotEmpty;
  }
}
