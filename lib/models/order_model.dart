import 'package:flutter/material.dart';
import 'order_item_model.dart';

class OrderModel {
  final int id;
  final int userId;
  final String? customerName;
  final String? customerEmail;
  final double totalAmount;
  final String status; // 'pending', 'processing', 'shipped', 'delivered', 'cancelled'
  final String deliveryAddress;
  final int totalItems;
  final int totalQuantity;
  final String? createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.userId,
    this.customerName,
    this.customerEmail,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    this.totalItems = 0,
    this.totalQuantity = 0,
    this.createdAt,
    this.items = const [],
  });

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.amber.shade700;
      case 'processing':
        return Colors.blue.shade600;
      case 'shipped':
        return Colors.indigo.shade600;
      case 'delivered':
        return Colors.teal.shade600;
      case 'cancelled':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] as List? ?? [];
    List<OrderItemModel> parsedItems = rawItems
        .map((i) => OrderItemModel.fromJson(i as Map<String, dynamic>))
        .toList();

    return OrderModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      customerName: json['customer_name'],
      customerEmail: json['customer_email'],
      totalAmount: json['total_amount'] != null ? double.tryParse(json['total_amount'].toString()) ?? 0.0 : 0.0,
      status: json['status'] ?? 'pending',
      deliveryAddress: json['delivery_address'] ?? '',
      totalItems: json['total_items'] != null ? int.tryParse(json['total_items'].toString()) ?? parsedItems.length : parsedItems.length,
      totalQuantity: json['total_quantity'] != null ? int.tryParse(json['total_quantity'].toString()) ?? 0 : 0,
      createdAt: json['created_at'],
      items: parsedItems,
    );
  }
}
