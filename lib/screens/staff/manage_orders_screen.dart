import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import '../customer/order_details_screen.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedStatus;

  final List<String> _statuses = [
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled'
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

  Future<void> _changeStatus(OrderModel order) async {
    String? chosenStatus = order.status;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Update Order #${order.id} Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _statuses.map((status) {
              return RadioListTile<String>(
                title: Text(
                  status.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                value: status,
                groupValue: chosenStatus,
                onChanged: (val) {
                  setModalState(() => chosenStatus = val);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor),
              child: const Text('Save Status', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && chosenStatus != null && chosenStatus != order.status) {
      final response = await OrderService.updateStatus(order.id, chosenStatus!);
      if (!mounted) return;

      if (response.success) {
        _fetchOrders();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: AppConstants.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: AppConstants.dangerColor,
          ),
        );
      }
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
          'Manage Customer Orders',
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
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedStatus == null,
                  selectedColor: AppConstants.primaryColor,
                  labelStyle: TextStyle(
                    color: _selectedStatus == null ? Colors.white : AppConstants.textPrimary,
                    fontSize: 12,
                  ),
                  onSelected: (_) {
                    setState(() => _selectedStatus = null);
                    _fetchOrders();
                  },
                ),
                const SizedBox(width: 8),
                ..._statuses.map((s) {
                  final isSelected = _selectedStatus == s;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(s.toUpperCase()),
                      selected: isSelected,
                      selectedColor: AppConstants.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppConstants.textPrimary,
                        fontSize: 12,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedStatus = s);
                        _fetchOrders();
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading orders...');
    }

    if (_errorMessage != null) {
      return CustomErrorWidget(message: _errorMessage!, onRetry: _fetchOrders);
    }

    if (_orders.isEmpty) {
      return const EmptyWidget(
        icon: Icons.receipt_long_outlined,
        title: 'No orders found',
        subtitle: 'No orders match this status filter.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: _orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = _orders[index];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  InkWell(
                    onTap: () => _changeStatus(order),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: order.statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: order.statusColor.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            order.status.toUpperCase(),
                            style: TextStyle(color: order.statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.edit, size: 12, color: order.statusColor),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Customer: ${order.customerName ?? 'User #${order.userId}'} (${order.customerEmail ?? ''})',
                style: const TextStyle(color: AppConstants.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(order.createdAt),
                style: const TextStyle(color: AppConstants.textMuted, fontSize: 12),
              ),
              const Divider(height: 20, color: Color(0xFFF1F5F9)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}  •  ${order.totalItems} items',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppConstants.primaryColor),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('View Details'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppConstants.primaryColor,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrderDetailsScreen(orderId: order.id)),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
