import '../models/category_model.dart';
import '../utils/api_constants.dart';
import 'api_service.dart';

class CategoryService {
  // Get all categories
  static Future<ApiResponse<List<CategoryModel>>> getCategories() async {
    final response = await ApiService.get(ApiConstants.categories, requiresAuth: false);
    if (response.success && response.data is List) {
      final categories = (response.data as List)
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse(
        success: true,
        message: response.message,
        data: categories,
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

  // Add Category (Admin)
  static Future<ApiResponse<dynamic>> addCategory(String name, String? description) async {
    return await ApiService.post(
      ApiConstants.categories,
      {
        'name': name.trim(),
        'description': description?.trim() ?? '',
      },
      requiresAuth: true,
    );
  }

  // Update Category (Admin)
  static Future<ApiResponse<dynamic>> updateCategory(int id, String name, String? description) async {
    return await ApiService.put(
      ApiConstants.category(id),
      {
        'name': name.trim(),
        'description': description?.trim() ?? '',
      },
      requiresAuth: true,
    );
  }

  // Delete Category (Admin)
  static Future<ApiResponse<dynamic>> deleteCategory(int id) async {
    return await ApiService.delete(ApiConstants.category(id), requiresAuth: true);
  }
}
