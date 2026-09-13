import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../models/category_model.dart';
import '../../services/book_service.dart';
import '../../services/cart_service.dart';
import '../../services/category_service.dart';
import '../../utils/constants.dart';
import '../../widgets/book_card.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import 'book_details_screen.dart';

class BookListScreen extends StatefulWidget {
  final int? initialCategoryId;
  final String title;

  const BookListScreen({
    super.key,
    this.initialCategoryId,
    this.title = 'Browse All Books',
  });

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  List<BookModel> _books = [];
  List<CategoryModel> _categories = [];
  int? _selectedCategoryId;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final categoriesFuture = CategoryService.getCategories();
    final booksFuture = BookService.getBooks(categoryId: _selectedCategoryId);

    final results = await Future.wait([categoriesFuture, booksFuture]);
    final catRes = results[0];
    final bookRes = results[1];

    if (!mounted) return;

    if (bookRes.success) {
      setState(() {
        _categories = (catRes.data as List<CategoryModel>?) ?? [];
        _books = (bookRes.data as List<BookModel>?) ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = bookRes.message;
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
          widget.title,
          style: const TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppConstants.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Category selector bar
          if (_categories.isNotEmpty)
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.white,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
                itemCount: _categories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isAll = index == 0;
                  final isSelected = isAll
                      ? _selectedCategoryId == null
                      : _selectedCategoryId == _categories[index - 1].id;
                  final title = isAll ? 'All' : _categories[index - 1].name;

                  return FilterChip(
                    label: Text(title),
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
                        _selectedCategoryId = isAll ? null : _categories[index - 1].id;
                      });
                      _loadData();
                    },
                  );
                },
              ),
            ),

          // Books Grid
          Expanded(
            child: _buildGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading catalog...');
    }

    if (_errorMessage != null) {
      return CustomErrorWidget(message: _errorMessage!, onRetry: _loadData);
    }

    if (_books.isEmpty) {
      return const EmptyWidget(
        icon: Icons.menu_book_outlined,
        title: 'No books found',
        subtitle: 'Try selecting another category or check back later.',
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
