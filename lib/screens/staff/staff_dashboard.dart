import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../utils/constants.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import '../customer/order_details_screen.dart';
import '../customer/profile_screen.dart';
import 'manage_books_screen.dart';
import 'manage_orders_screen.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const _StaffDashboardFeed(),
    const ManageBooksScreen(canDelete: false),
    const ManageOrdersScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: AppConstants.primaryColor,
          unselectedItemColor: AppConstants.textMuted,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book_rounded),
              label: 'Books',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffDashboardFeed extends StatefulWidget {
  const _StaffDashboardFeed();

  @override
  State<_StaffDashboardFeed> createState() => _StaffDashboardFeedState();
}

class _StaffDashboardFeedState extends State<_StaffDashboardFeed> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await UserService.getStaffDashboard();

    if (!mounted) return;

    if (response.success && response.data != null) {
      setState(() {
        _data = response.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Loading store metrics...'),
      );
    }

    if (_errorMessage != null || _data == null) {
      return Scaffold(
        body: CustomErrorWidget(message: _errorMessage ?? 'Failed to load metrics', onRetry: _loadMetrics),
      );
    }

    final d = _data!;
    final recentOrders = d['recent_orders'] as List? ?? [];
    final lowStockItems = d['low_stock_items'] as List? ?? [];

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Staff Portal',
          style: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppConstants.textPrimary),
            onPressed: _loadMetrics,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadMetrics,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store Staff Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Store Operations',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Manage book inventory, restock alerts, and order fulfillment.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // KPI Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
                children: [
                  _buildMetricCard(
                    title: 'Total Books',
                    value: '${d['total_books'] ?? 0}',
                    icon: Icons.menu_book_rounded,
                    color: AppConstants.infoColor,
                  ),
                  _buildMetricCard(
                    title: 'Total Orders',
                    value: '${d['total_orders'] ?? 0}',
                    icon: Icons.shopping_bag_rounded,
                    color: AppConstants.primaryColor,
                  ),
                  _buildMetricCard(
                    title: 'Pending Orders',
                    value: '${d['pending_orders'] ?? 0}',
                    icon: Icons.pending_actions_rounded,
                    color: AppConstants.warningColor,
                  ),
                  _buildMetricCard(
                    title: 'Low Stock Items',
                    value: '${d['low_stock_books'] ?? 0}',
                    icon: Icons.warning_amber_rounded,
                    color: AppConstants.dangerColor,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Low Stock Alerts
              if (lowStockItems.isNotEmpty) ...[
                const Text(
                  'Low Stock Alerts (Restock Needed)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.textPrimary),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lowStockItems.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, index) {
                      final item = lowStockItems[index];
                      return ListTile(
                        leading: const Icon(Icons.warning_amber_rounded, color: AppConstants.dangerColor),
                        title: Text(item['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text('Author: ${item['author'] ?? ''}', style: const TextStyle(fontSize: 12)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Only ${item['stock_quantity']} left',
                            style: const TextStyle(color: AppConstants.dangerColor, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Recent Orders
              const Text(
                'Recent Orders For Fulfillment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.textPrimary),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentOrders.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final order = recentOrders[index];
                    return ListTile(
                      title: Text('Order #${order['id']} - ${order['customer_name']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text('\$${order['total_amount']} • Status: ${order['status']}', style: const TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsScreen(orderId: order['id']),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, color: AppConstants.textSecondary, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
