import '../models/order_model.dart';
import '../utils/api_constants.dart';
import 'api_service.dart';

class OrderService {
  // Place a new order (Checkout)
  static Future<ApiResponse<dynamic>> placeOrder({required String deliveryAddress}) async {
    return await ApiService.post(
      ApiConstants.orders,
      {
        'delivery_address': deliveryAddress.trim(),
      },
      requiresAuth: true,
    );
  }

  // Get orders (Customer sees own, Staff & Admin see all)
  static Future<ApiResponse<List<OrderModel>>> getOrders({String? status}) async {
    String url = ApiConstants.orders;
    if (status != null && status.isNotEmpty) {
      url += '?status=$status';
    }

    final response = await ApiService.get(url, requiresAuth: true);
    if (response.success && response.data is List) {
      final orders = (response.data as List)
          .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse(
        success: true,
        message: response.message,
        data: orders,
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

  // Get single order details
  static Future<ApiResponse<OrderModel>> getOrderDetails(int orderId) async {
    final response = await ApiService.get(ApiConstants.orderDetails(orderId), requiresAuth: true);
    if (response.success && response.data != null) {
      final order = OrderModel.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse(
        success: true,
        message: response.message,
        data: order,
        statusCode: response.statusCode,
      );
    }
    return ApiResponse(
      success: false,
      message: response.message,
      statusCode: response.statusCode,
    );
  }

  // Update order status (Staff / Admin)
  static Future<ApiResponse<dynamic>> updateStatus(int orderId, String status) async {
    return await ApiService.put(
      ApiConstants.updateOrderStatus(orderId),
      {
        'status': status.toLowerCase().trim(),
      },
      requiresAuth: true,
    );
  }
}
