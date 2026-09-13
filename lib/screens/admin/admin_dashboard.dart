import 'package:flutter/material.dart';
import '../../services/user_service.dart';
import '../../utils/constants.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import '../customer/order_details_screen.dart';
import '../customer/profile_screen.dart';
import '../staff/manage_books_screen.dart';
import '../staff/manage_orders_screen.dart';
import 'manage_categories_screen.dart';
import 'manage_users_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const _AdminDashboardFeed(),
    const ManageUsersScreen(),
    const ManageBooksScreen(canDelete: true),
    const ManageCategoriesScreen(),
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
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              activeIcon: Icon(Icons.people_rounded),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book_rounded),
              label: 'Books',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined),
              activeIcon: Icon(Icons.category_rounded),
              label: 'Categories',
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

class _AdminDashboardFeed extends StatefulWidget {
  const _AdminDashboardFeed();

  @override
  State<_AdminDashboardFeed> createState() => _AdminDashboardFeedState();
}

class _AdminDashboardFeedState extends State<_AdminDashboardFeed> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMetrics();
  }

  Future<void> _fetchMetrics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await UserService.getAdminDashboard();

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
        body: LoadingWidget(message: 'Calculating store performance metrics...'),
      );
    }

    if (_errorMessage != null || _data == null) {
      return Scaffold(
        body: CustomErrorWidget(message: _errorMessage ?? 'Failed to load dashboard', onRetry: _fetchMetrics),
      );
    }

    final d = _data!;
    final recentOrders = d['recent_orders'] as List? ?? [];

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Admin Command Center',
          style: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppConstants.textPrimary),
            onPressed: _fetchMetrics,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMetrics,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppConstants.accentColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.shield_rounded, color: AppConstants.accentColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'BookVerse Administration',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Real-time store metrics & control',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(color: Color(0xFF334155), height: 1),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Total Platform Revenue',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(
                              '\$${d['total_revenue'] ?? 0.00}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Key Performance Indicators',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.textPrimary),
              ),
              const SizedBox(height: 12),

              // 6 KPI Cards Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [
                  _buildMetricCard(
                    title: 'Total Users',
                    value: '${d['total_users'] ?? 0}',
                    subtitle: 'Customers & Staff',
                    icon: Icons.people_alt_rounded,
                    color: AppConstants.infoColor,
                  ),
                  _buildMetricCard(
                    title: 'Total Books',
                    value: '${d['total_books'] ?? 0}',
                    subtitle: 'Published Titles',
                    icon: Icons.auto_stories_rounded,
                    color: Colors.indigo,
                  ),
                  _buildMetricCard(
                    title: 'Total Orders',
                    value: '${d['total_orders'] ?? 0}',
                    subtitle: 'Lifetime orders',
                    icon: Icons.shopping_bag_rounded,
                    color: Colors.teal,
                  ),
                  _buildMetricCard(
                    title: 'Pending Orders',
                    value: '${d['pending_orders'] ?? 0}',
                    subtitle: 'Needs review',
                    icon: Icons.schedule_rounded,
                    color: AppConstants.warningColor,
                  ),
                  _buildMetricCard(
                    title: 'Low Stock Books',
                    value: '${d['low_stock_books'] ?? 0}',
                    subtitle: '5 or fewer units',
                    icon: Icons.warning_rounded,
                    color: AppConstants.dangerColor,
                  ),
                  _buildMetricCard(
                    title: 'Gross Revenue',
                    value: '\$${d['total_revenue'] ?? 0}',
                    subtitle: 'Completed sales',
                    icon: Icons.attach_money_rounded,
                    color: AppConstants.successColor,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Recent Orders
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Orders',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.textPrimary),
                  ),
                  Text(
                    'Latest 5 placed',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                      title: Text(
                        'Order #${order['id']} • ${order['customer_name']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        '\$${order['total_amount']}  •  Status: ${(order['status'] as String).toUpperCase()}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => OrderDetailsScreen(orderId: order['id'])),
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
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  style: const TextStyle(fontSize: 12, color: AppConstants.textSecondary, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10.5, color: AppConstants.textMuted),
          ),
        ],
      ),
    );
  }
}
