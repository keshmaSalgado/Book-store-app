class UserModel {
  final int id;
  final String name;
  final String email;
  final String role; // 'customer', 'staff', 'admin'
  final String status; // 'active', 'inactive'
  final int? totalOrders;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.totalOrders,
    this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isStaff => role == 'staff';
  bool get isCustomer => role == 'customer';
  bool get isActive => status == 'active';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'customer',
      status: json['status'] ?? 'active',
      totalOrders: json['total_orders'] != null ? int.tryParse(json['total_orders'].toString()) : null,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'status': status,
      'total_orders': totalOrders,
      'created_at': createdAt,
    };
  }
}
