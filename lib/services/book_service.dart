import '../models/book_model.dart';
import '../utils/api_constants.dart';
import 'api_service.dart';

class BookService {
  // Fetch all books (with optional filters)
  static Future<ApiResponse<List<BookModel>>> getBooks({
    int? categoryId,
    String? filter, // 'featured', 'latest'
    int? limit,
  }) async {
    String url = ApiConstants.books;
    List<String> queryParams = [];

    if (categoryId != null) queryParams.add('category_id=$categoryId');
    if (filter != null) queryParams.add('filter=$filter');
    if (limit != null) queryParams.add('limit=$limit');

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    final response = await ApiService.get(url, requiresAuth: false);

    if (response.success && response.data is List) {
      final books = (response.data as List)
          .map((item) => BookModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse(
        success: true,
        message: response.message,
        data: books,
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

  // Get book details by ID
  static Future<ApiResponse<BookModel>> getBook(int id) async {
    final response = await ApiService.get(ApiConstants.bookDetails(id), requiresAuth: false);
    if (response.success && response.data != null) {
      final book = BookModel.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse(
        success: true,
        message: response.message,
        data: book,
        statusCode: response.statusCode,
      );
    }
    return ApiResponse(
      success: false,
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Search books by title or author
  static Future<ApiResponse<List<BookModel>>> searchBooks(String query) async {
    final response = await ApiService.get(ApiConstants.searchBooks(query), requiresAuth: false);

    if (response.success && response.data is List) {
      final books = (response.data as List)
          .map((item) => BookModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse(
        success: true,
        message: response.message,
        data: books,
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

  // Add a book (Staff / Admin)
  static Future<ApiResponse<BookModel>> addBook(Map<String, dynamic> bookData) async {
    final response = await ApiService.post(ApiConstants.books, bookData, requiresAuth: true);
    if (response.success && response.data != null) {
      final book = BookModel.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse(
        success: true,
        message: response.message,
        data: book,
        statusCode: response.statusCode,
      );
    }
    return ApiResponse(
      success: false,
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Update a book (Staff / Admin)
  static Future<ApiResponse<BookModel>> updateBook(int id, Map<String, dynamic> bookData) async {
    final response = await ApiService.put(ApiConstants.bookDetails(id), bookData, requiresAuth: true);
    if (response.success && response.data != null) {
      final book = BookModel.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse(
        success: true,
        message: response.message,
        data: book,
        statusCode: response.statusCode,
      );
    }
    return ApiResponse(
      success: false,
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Delete a book (Admin only)
  static Future<ApiResponse<dynamic>> deleteBook(int id) async {
    return await ApiService.delete(ApiConstants.bookDetails(id), requiresAuth: true);
  }
}
