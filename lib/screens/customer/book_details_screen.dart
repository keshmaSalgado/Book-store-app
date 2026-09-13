import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../services/book_service.dart';
import '../../services/cart_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import 'cart_screen.dart';

class BookDetailsScreen extends StatefulWidget {
  final int bookId;
  final BookModel? initialBook;

  const BookDetailsScreen({
    super.key,
    required this.bookId,
    this.initialBook,
  });

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  BookModel? _book;
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedQuantity = 1;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialBook != null) {
      _book = widget.initialBook;
      _isLoading = false;
    } else {
      _fetchBookDetails();
    }
  }

  Future<void> _fetchBookDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await BookService.getBook(widget.bookId);

    if (!mounted) return;

    if (response.success && response.data != null) {
      setState(() {
        _book = response.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleAddToCart() async {
    if (_book == null || !_book!.inStock) return;

    setState(() => _isAddingToCart = true);

    final response = await CartService.addToCart(_book!.id, quantity: _selectedQuantity);

    if (!mounted) return;
    setState(() => _isAddingToCart = false);

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${_selectedQuantity}x "${_book!.title}" to cart'),
          backgroundColor: AppConstants.successColor,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'VIEW CART',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const LoadingWidget(message: 'Loading book details...'),
      );
    }

    if (_errorMessage != null || _book == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: CustomErrorWidget(
          message: _errorMessage ?? 'Book not found',
          onRetry: _fetchBookDetails,
        ),
      );
    }

    final book = _book!;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Book Details',
          style: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppConstants.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, color: AppConstants.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Book Cover
            Container(
              width: double.infinity,
              height: 280,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
              ),
              child: Center(
                child: Hero(
                  tag: 'book_cover_${book.id}',
                  child: Container(
                    width: 170,
                    height: 240,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                      child: Image.network(
                        book.imageUrl ?? AppConstants.fallbackBookCover,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.book, size: 60, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Book Details Container
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Tag
                  if (book.categoryName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppConstants.accentLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        book.categoryName!.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB45309),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Author
                  Text(
                    'by ${book.author}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppConstants.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price & Stock Availability Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${book.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: book.inStock
                              ? (book.isLowStock ? Colors.amber.shade50 : Colors.green.shade50)
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: book.inStock
                                ? (book.isLowStock ? Colors.amber.shade300 : Colors.green.shade300)
                                : Colors.red.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              book.inStock ? Icons.check_circle_outline : Icons.cancel_outlined,
                              size: 16,
                              color: book.inStock
                                  ? (book.isLowStock ? AppConstants.warningColor : AppConstants.successColor)
                                  : AppConstants.dangerColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              book.inStock
                                  ? '${book.stockQuantity} in stock'
                                  : 'Out of Stock',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: book.inStock
                                    ? (book.isLowStock ? AppConstants.warningColor : AppConstants.successColor)
                                    : AppConstants.dangerColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ISBN Info Card
                  if (book.isbn != null && book.isbn!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.qr_code_rounded, size: 20, color: AppConstants.textSecondary),
                          const SizedBox(width: 10),
                          const Text(
                            'ISBN: ',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppConstants.textPrimary),
                          ),
                          Text(
                            book.isbn!,
                            style: const TextStyle(fontSize: 13, color: AppConstants.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.description?.isNotEmpty == true
                        ? book.description!
                        : 'No description provided for this book.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppConstants.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Bar with Quantity Selector and Add to Cart
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity Selector
              if (book.inStock) ...[
                Container(
                  decoration: BoxDecoration(
                    color: AppConstants.surfaceColor,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: _selectedQuantity > 1
                            ? () => setState(() => _selectedQuantity--)
                            : null,
                      ),
                      Text(
                        '$_selectedQuantity',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: _selectedQuantity < book.stockQuantity
                            ? () => setState(() => _selectedQuantity++)
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
              ],

              // Add to Cart Button
              Expanded(
                child: CustomButton(
                  text: book.inStock ? 'Add to Cart' : 'Out of Stock',
                  icon: book.inStock ? Icons.shopping_cart_outlined : null,
                  isLoading: _isAddingToCart,
                  backgroundColor: book.inStock ? AppConstants.primaryColor : Colors.grey,
                  onPressed: book.inStock ? _handleAddToCart : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
