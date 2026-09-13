import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../services/book_service.dart';
import '../../services/cart_service.dart';
import '../../utils/constants.dart';
import '../../widgets/book_card.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/loading_widget.dart';
import 'book_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<BookModel> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Pre-populate with all books initially
    _executeSearch('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _executeSearch(query);
    });
  }

  Future<void> _executeSearch(String query) async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    final response = await BookService.searchBooks(query);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _searchResults = response.data ?? [];
    });
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
        title: const Text(
          'Search Books',
          style: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Search Input Bar
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: _executeSearch,
              decoration: InputDecoration(
                hintText: 'Search by title, author, or ISBN...',
                hintStyle: const TextStyle(color: AppConstants.textMuted, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: AppConstants.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _executeSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppConstants.surfaceColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Search Results
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Searching catalog...');
    }

    if (_hasSearched && _searchResults.isEmpty) {
      return EmptyWidget(
        icon: Icons.search_off_rounded,
        title: 'No books found',
        subtitle: 'Try checking your spelling or searching for a different author or title.',
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
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final book = _searchResults[index];
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
