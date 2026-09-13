import 'package:flutter/material.dart';
import '../../models/cart_model.dart';
import '../../services/cart_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  CartModel? _cart;
  bool _isLoading = true;
  String? _errorMessage;
  int? _updatingItemId;

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  Future<void> _fetchCart() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await CartService.getCart();

    if (!mounted) return;

    if (response.success && response.data != null) {
      setState(() {
        _cart = response.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateQuantity(int cartItemId, int newQuantity) async {
    setState(() => _updatingItemId = cartItemId);

    final response = await CartService.updateQuantity(cartItemId, newQuantity);

    if (!mounted) return;
    setState(() => _updatingItemId = null);

    if (response.success) {
      _fetchCart(); // Refresh cart totals
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: AppConstants.dangerColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _removeItem(int cartItemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove from cart?'),
        content: const Text('Are you sure you want to remove this book from your shopping cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppConstants.dangerColor),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final response = await CartService.removeFromCart(cartItemId);
    if (!mounted) return;

    if (response.success) {
      _fetchCart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed from cart'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: AppConstants.dangerColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
          'Shopping Cart',
          style: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppConstants.textPrimary),
            tooltip: 'Refresh Cart',
            onPressed: _fetchCart,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _cart != null && !_cart!.isEmpty ? _buildCheckoutBar() : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading your cart...');
    }

    if (_errorMessage != null) {
      return CustomErrorWidget(message: _errorMessage!, onRetry: _fetchCart);
    }

    if (_cart == null || _cart!.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchCart,
        color: AppConstants.primaryColor,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: EmptyWidget(
                icon: Icons.shopping_basket_outlined,
                title: 'Your cart is empty',
                subtitle: 'Explore our catalog and find your next favorite read!\n(Pull down to refresh)',
                action: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Browse Books'),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCart,
      color: AppConstants.primaryColor,
      child: ListView.separated(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: _cart!.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _cart!.items[index];
        final isUpdating = _updatingItemId == item.cartItemId;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Book Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.imageUrl ?? AppConstants.fallbackBookCover,
                  width: 64,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 64,
                    height: 90,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.book, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title, Author, Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.author,
                      style: const TextStyle(fontSize: 12, color: AppConstants.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Quantity Buttons & Remove
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppConstants.dangerColor, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _removeItem(item.cartItemId),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppConstants.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 14),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          onPressed: (item.canDecrease && !isUpdating)
                              ? () => _updateQuantity(item.cartItemId, item.quantity - 1)
                              : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: isUpdating
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  '${item.quantity}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 14),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          onPressed: (item.canIncrease && !isUpdating)
                              ? () => _updateQuantity(item.cartItemId, item.quantity + 1)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total (${_cart!.totalItems} items):',
                  style: const TextStyle(fontSize: 15, color: AppConstants.textSecondary),
                ),
                Text(
                  '\$${_cart!.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            CustomButton(
              text: 'Proceed to Checkout',
              icon: Icons.lock_outline_rounded,
              onPressed: () async {
                final orderPlaced = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutScreen(cart: _cart!),
                  ),
                );

                if (orderPlaced == true) {
                  _fetchCart();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
