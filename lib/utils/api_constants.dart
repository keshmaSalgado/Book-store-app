import 'package:flutter/foundation.dart';

class ApiConstants {
  // Base URLs for different test environments
  // Android Emulator maps host machine localhost to 10.0.2.2
  // Physical device should use the PC local LAN IP (e.g. 192.168.1.100)
  // Windows / Web / Desktop can use localhost directly
  
  // Choose your environment mode here:
  // Options: 'xampp' (http://.../bookverse_api) or 'php_cli' (http://...:8000)
  static const String serverMode = 'xampp';

  // Manual IP override if testing on physical phone (Leave empty for auto)
  static const String physicalDeviceIp = '10.151.196.225'; 

  static String get baseUrl {
    if (physicalDeviceIp.isNotEmpty) {
      return serverMode == 'xampp' 
          ? 'http://$physicalDeviceIp/bookverse_api' 
          : 'http://$physicalDeviceIp:8000';
    }

    if (kIsWeb) {
      return serverMode == 'xampp' 
          ? 'http://localhost/bookverse_api' 
          : 'http://127.0.0.1:8000';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return serverMode == 'xampp' 
            ? 'http://10.0.2.2/bookverse_api' 
            : 'http://10.0.2.2:8000';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        return serverMode == 'xampp' 
            ? 'http://localhost/bookverse_api' 
            : 'http://127.0.0.1:8000';
    }
  }

  // Authentication Endpoints
  static String get register => '$baseUrl/api/auth/register';
  static String get login => '$baseUrl/api/auth/login';
  static String get profile => '$baseUrl/api/auth/profile';
  static String get logout => '$baseUrl/api/auth/logout';

  // Books Endpoints
  static String get books => '$baseUrl/api/books';
  static String bookDetails(int id) => '$baseUrl/api/books/$id';
  static String searchBooks(String query) => '$baseUrl/api/books/search?query=${Uri.encodeComponent(query)}';

  // Categories Endpoints
  static String get categories => '$baseUrl/api/categories';
  static String category(int id) => '$baseUrl/api/categories/$id';

  // Cart Endpoints
  static String get cart => '$baseUrl/api/cart';
  static String cartItem(int id) => '$baseUrl/api/cart/$id';

  // Orders Endpoints
  static String get orders => '$baseUrl/api/orders';
  static String orderDetails(int id) => '$baseUrl/api/orders/$id';
  static String updateOrderStatus(int id) => '$baseUrl/api/orders/$id/status';

  // Users Endpoints (Admin)
  static String get users => '$baseUrl/api/users';
  static String user(int id) => '$baseUrl/api/users/$id';

  // Dashboard Endpoints
  static String get adminDashboard => '$baseUrl/api/admin/dashboard';
  static String get staffDashboard => '$baseUrl/api/staff/dashboard';
}
