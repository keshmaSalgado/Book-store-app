import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import 'order_details_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedStatus; // null means all

  final List<String> _statusFilters = [
    'All',
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await OrderService.getOrders(status: _selectedStatus);

    if (!mounted) return;

    if (response.success && response.data != null) {
      setState(() {
        _orders = response.data!;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.message;
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null) return '';
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Orders',
          style: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppConstants.textPrimary),
            onPressed: _fetchOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              itemCount: _statusFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final status = _statusFilters[index];
                final isSelected = (_selectedStatus == null && status == 'All') ||
                    (_selectedStatus?.toLowerCase() == status.toLowerCase());

                return FilterChip(
                  label: Text(status),
                  selected: isSelected,
                  selectedColor: AppConstants.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppConstants.textPrimary,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: AppConstants.surfaceColor,
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = status == 'All' ? null : status.toLowerCase();
                    });
                    _fetchOrders();
                  },
                );
              },
            ),
          ),

          // Orders List
          Expanded(
            child: _buildOrdersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading your orders...');
    }

    if (_errorMessage != null) {
      return CustomErrorWidget(message: _errorMessage!, onRetry: _fetchOrders);
    }

    if (_orders.isEmpty) {
      return const EmptyWidget(
        icon: Icons.receipt_long_outlined,
        title: 'No orders found',
        subtitle: 'You have not placed any orders matching this filter.',
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: _orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = _orders[index];

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailsScreen(orderId: order.id),
                ),
              ).then((_) => _fetchOrders());
            },
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: order.statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          order.status.toUpperCase(),
                          style: TextStyle(
                            color: order.statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(order.createdAt),
                    style: const TextStyle(fontSize: 12, color: AppConstants.textSecondary),
                  ),
                  const Divider(height: 20, color: Color(0xFFF1F5F9)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${order.totalItems} items (${order.totalQuantity} units)',
                        style: const TextStyle(fontSize: 13, color: AppConstants.textSecondary),
                      ),
                      Text(
                        '\$${order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
