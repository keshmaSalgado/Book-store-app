import '../models/cart_model.dart';
import '../utils/api_constants.dart';
import 'api_service.dart';

class CartService {
  // Get customer cart
  static Future<ApiResponse<CartModel>> getCart() async {
    final response = await ApiService.get(ApiConstants.cart, requiresAuth: true);
    if (response.success && response.data != null) {
      final cart = CartModel.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse(
        success: true,
        message: response.message,
        data: cart,
        statusCode: response.statusCode,
      );
    }
    return ApiResponse(
      success: false,
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Add item to cart
  static Future<ApiResponse<dynamic>> addToCart(int bookId, {int quantity = 1}) async {
    return await ApiService.post(
      ApiConstants.cart,
      {
        'book_id': bookId,
        'quantity': quantity,
      },
      requiresAuth: true,
    );
  }

  // Update item quantity
  static Future<ApiResponse<dynamic>> updateQuantity(int cartItemId, int quantity) async {
    return await ApiService.put(
      ApiConstants.cartItem(cartItemId),
      {
        'quantity': quantity,
      },
      requiresAuth: true,
    );
  }

  // Remove item from cart
  static Future<ApiResponse<dynamic>> removeFromCart(int cartItemId) async {
    return await ApiService.delete(
      ApiConstants.cartItem(cartItemId),
      requiresAuth: true,
    );
  }
}
