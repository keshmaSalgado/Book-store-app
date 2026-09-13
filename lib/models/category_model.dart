class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final int bookCount;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.bookCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      bookCount: json['book_count'] != null ? int.tryParse(json['book_count'].toString()) ?? 0 : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
