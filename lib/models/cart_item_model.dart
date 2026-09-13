class CartItemModel {
  final int cartItemId;
  final int bookId;
  final String title;
  final String author;
  final String? isbn;
  final double price;
  final int stockQuantity;
  final String? imageUrl;
  final String? categoryName;
  int quantity;
  final double subtotal;

  CartItemModel({
    required this.cartItemId,
    required this.bookId,
    required this.title,
    required this.author,
    this.isbn,
    required this.price,
    required this.stockQuantity,
    this.imageUrl,
    this.categoryName,
    required this.quantity,
    required this.subtotal,
  });

  bool get canIncrease => quantity < stockQuantity;
  bool get canDecrease => quantity > 1;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      cartItemId: json['cart_item_id'] is int ? json['cart_item_id'] : int.tryParse(json['cart_item_id'].toString()) ?? 0,
      bookId: json['book_id'] is int ? json['book_id'] : int.tryParse(json['book_id'].toString()) ?? 0,
      title: json['title'] ?? 'Book',
      author: json['author'] ?? '',
      isbn: json['isbn'],
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      stockQuantity: json['stock_quantity'] != null ? int.tryParse(json['stock_quantity'].toString()) ?? 0 : 0,
      imageUrl: json['image_url'],
      categoryName: json['category_name'],
      quantity: json['quantity'] != null ? int.tryParse(json['quantity'].toString()) ?? 1 : 1,
      subtotal: json['subtotal'] != null ? double.tryParse(json['subtotal'].toString()) ?? 0.0 : 0.0,
    );
  }
}
