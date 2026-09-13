import 'package:flutter/material.dart';
import '../../models/cart_model.dart';
import '../../services/order_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import 'order_history_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final CartModel cart;

  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handlePlaceOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final response = await OrderService.placeOrder(
      deliveryAddress: _addressController.text,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (response.success && response.data != null) {
      final orderData = response.data as Map<String, dynamic>;
      final orderId = orderData['order_id'];

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline_rounded, size: 54, color: AppConstants.successColor),
              ),
              const SizedBox(height: 18),
              const Text(
                'Order Placed!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Your order #$orderId has been placed successfully.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppConstants.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'View My Orders',
                onPressed: () {
                  final navigator = Navigator.of(context);
                  Navigator.pop(ctx); // Close dialog
                  navigator.pushReplacement(
                    MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
                  );
                },
              ),
            ],
          ),
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
          'Checkout',
          style: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppConstants.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Address Section
              const Text(
                'Delivery Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.textPrimary),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _addressController,
                label: 'Shipping Address',
                hint: 'Street Address, City, State/Province, Postal Code',
                prefixIcon: Icons.location_on_outlined,
                maxLines: 3,
                validator: (val) => Validators.validateRequired(val, 'Delivery address'),
              ),
              const SizedBox(height: 24),

              // Order Summary Section
              const Text(
                'Order Summary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.textPrimary),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.cart.items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      itemBuilder: (context, index) {
                        final item = widget.cart.items[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            'Qty: ${item.quantity}  ×  \$${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(color: AppConstants.textSecondary, fontSize: 13),
                          ),
                          trailing: Text(
                            '\$${item.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal', style: TextStyle(color: AppConstants.textSecondary, fontSize: 14)),
                              Text('\$${widget.cart.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Shipping & Handling', style: TextStyle(color: AppConstants.textSecondary, fontSize: 14)),
                              Text('FREE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppConstants.successColor)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.textPrimary)),
                              Text(
                                '\$${widget.cart.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppConstants.primaryColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Confirm Button
              CustomButton(
                text: 'Confirm & Place Order',
                icon: Icons.check_circle_outline_rounded,
                isLoading: _isSubmitting,
                onPressed: _handlePlaceOrder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
