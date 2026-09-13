class BookModel {
  final int id;
  final String title;
  final String author;
  final String? isbn;
  final String? description;
  final double price;
  final int stockQuantity;
  final String? imageUrl;
  final int? categoryId;
  final String? categoryName;
  final String? createdAt;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    this.isbn,
    this.description,
    required this.price,
    required this.stockQuantity,
    this.imageUrl,
    this.categoryId,
    this.categoryName,
    this.createdAt,
  });

  bool get inStock => stockQuantity > 0;
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 5;

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? 'Untitled',
      author: json['author'] ?? 'Unknown Author',
      isbn: json['isbn'],
      description: json['description'],
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      stockQuantity: json['stock_quantity'] != null ? int.tryParse(json['stock_quantity'].toString()) ?? 0 : 0,
      imageUrl: json['image_url'],
      categoryId: json['category_id'] != null ? int.tryParse(json['category_id'].toString()) : null,
      categoryName: json['category_name'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'description': description,
      'price': price,
      'stock_quantity': stockQuantity,
      'image_url': imageUrl,
      'category_id': categoryId,
      'category_name': categoryName,
    };
  }
}
