import 'cart_item_model.dart';

class CartModel {
  final int cartId;
  final int totalItems;
  final double totalAmount;
  final List<CartItemModel> items;

  CartModel({
    required this.cartId,
    required this.totalItems,
    required this.totalAmount,
    required this.items,
  });

  bool get isEmpty => items.isEmpty;

  factory CartModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] as List? ?? [];
    List<CartItemModel> parsedItems = rawItems
        .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return CartModel(
      cartId: json['cart_id'] is int ? json['cart_id'] : int.tryParse(json['cart_id'].toString()) ?? 0,
      totalItems: json['total_items'] != null ? int.tryParse(json['total_items'].toString()) ?? 0 : 0,
      totalAmount: json['total_amount'] != null ? double.tryParse(json['total_amount'].toString()) ?? 0.0 : 0.0,
      items: parsedItems,
    );
  }
}
