import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../models/category_model.dart';
import '../../services/book_service.dart';
import '../../services/cart_service.dart';
import '../../utils/constants.dart';
import '../../widgets/book_card.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import 'book_details_screen.dart';

class CategoryScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<BookModel> _books = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCategoryBooks();
  }

  Future<void> _fetchCategoryBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await BookService.getBooks(categoryId: widget.category.id);

    if (!mounted) return;

    if (response.success && response.data != null) {
      setState(() {
        _books = response.data!;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _addToCart(BookModel book) async {
    final response = await CartService.addToCart(book.id, quantity: 1);
    if (!mounted) return;

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added "${book.title}" to cart'),
          backgroundColor: AppConstants.successColor,
          duration: const Duration(seconds: 2),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.category.name,
          style: const TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppConstants.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading category books...');
    }

    if (_errorMessage != null) {
      return CustomErrorWidget(message: _errorMessage!, onRetry: _fetchCategoryBooks);
    }

    if (_books.isEmpty) {
      return EmptyWidget(
        icon: Icons.auto_stories_outlined,
        title: 'No books in this category',
        subtitle: 'Check back soon for new arrivals in ${widget.category.name}.',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _books.length,
      itemBuilder: (context, index) {
        final book = _books[index];
        return BookCard(
          book: book,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookDetailsScreen(bookId: book.id, initialBook: book),
              ),
            );
          },
          onAddToCart: () => _addToCart(book),
        );
      },
    );
  }
}
