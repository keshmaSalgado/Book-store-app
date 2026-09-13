class OrderItemModel {
  final int orderItemId;
  final int bookId;
  final String title;
  final String? author;
  final String? imageUrl;
  final int quantity;
  final double price;
  final double subtotal;

  OrderItemModel({
    required this.orderItemId,
    required this.bookId,
    required this.title,
    this.author,
    this.imageUrl,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      orderItemId: json['order_item_id'] is int ? json['order_item_id'] : int.tryParse(json['order_item_id']?.toString() ?? '0') ?? 0,
      bookId: json['book_id'] is int ? json['book_id'] : int.tryParse(json['book_id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? 'Book',
      author: json['author'],
      imageUrl: json['image_url'],
      quantity: json['quantity'] != null ? int.tryParse(json['quantity'].toString()) ?? 1 : 1,
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      subtotal: json['subtotal'] != null ? double.tryParse(json['subtotal'].toString()) ?? 0.0 : 0.0,
    );
  }
}
