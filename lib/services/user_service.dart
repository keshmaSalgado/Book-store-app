import '../models/user_model.dart';
import '../utils/api_constants.dart';
import 'api_service.dart';

class UserService {
  // Get all users (Admin)
  static Future<ApiResponse<List<UserModel>>> getUsers({String? role}) async {
    String url = ApiConstants.users;
    if (role != null && role.isNotEmpty) {
      url += '?role=$role';
    }

    final response = await ApiService.get(url, requiresAuth: true);
    if (response.success && response.data is List) {
      final users = (response.data as List)
          .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse(
        success: true,
        message: response.message,
        data: users,
        statusCode: response.statusCode,
      );
    }
    return ApiResponse(
      success: false,
      message: response.message,
      data: [],
      statusCode: response.statusCode,
    );
  }

  // Add User (Admin)
  static Future<ApiResponse<UserModel>> addUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required String status,
  }) async {
    final response = await ApiService.post(
      ApiConstants.users,
      {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'role': role,
        'status': status,
      },
      requiresAuth: true,
    );

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

  // Update User (Admin)
  static Future<ApiResponse<UserModel>> updateUser(int id, Map<String, dynamic> data) async {
    final response = await ApiService.put(ApiConstants.user(id), data, requiresAuth: true);
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

  // Delete User (Admin)
  static Future<ApiResponse<dynamic>> deleteUser(int id) async {
    return await ApiService.delete(ApiConstants.user(id), requiresAuth: true);
  }

  // Get Admin Dashboard Metrics
  static Future<ApiResponse<Map<String, dynamic>>> getAdminDashboard() async {
    final response = await ApiService.get(ApiConstants.adminDashboard, requiresAuth: true);
    if (response.success && response.data is Map<String, dynamic>) {
      return ApiResponse(
        success: true,
        message: response.message,
        data: response.data as Map<String, dynamic>,
        statusCode: response.statusCode,
      );
    }
    return ApiResponse(
      success: false,
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Get Staff Dashboard Metrics
  static Future<ApiResponse<Map<String, dynamic>>> getStaffDashboard() async {
    final response = await ApiService.get(ApiConstants.staffDashboard, requiresAuth: true);
    if (response.success && response.data is Map<String, dynamic>) {
      return ApiResponse(
        success: true,
        message: response.message,
        data: response.data as Map<String, dynamic>,
        statusCode: response.statusCode,
      );
    }
    return ApiResponse(
      success: false,
      message: response.message,
      statusCode: response.statusCode,
    );
  }
}
