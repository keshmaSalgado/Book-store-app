import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../services/book_service.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import 'add_book_screen.dart';
import 'edit_book_screen.dart';

class ManageBooksScreen extends StatefulWidget {
  final bool canDelete; // true for Admin, false for Staff

  const ManageBooksScreen({super.key, this.canDelete = false});

  @override
  State<ManageBooksScreen> createState() => _ManageBooksScreenState();
}

class _ManageBooksScreenState extends State<ManageBooksScreen> {
  List<BookModel> _books = [];
  List<BookModel> _filteredBooks = [];
  bool _isLoading = true;
  String? _errorMessage;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await BookService.getBooks();

    if (!mounted) return;

    if (response.success && response.data != null) {
      setState(() {
        _books = response.data!;
        _filterBooks(_searchController.text);
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.message;
        _isLoading = false;
      });
    }
  }

  void _filterBooks(String query) {
    if (query.trim().isEmpty) {
      setState(() => _filteredBooks = List.from(_books));
    } else {
      final q = query.toLowerCase();
      setState(() {
        _filteredBooks = _books
            .where((b) =>
                b.title.toLowerCase().contains(q) ||
                b.author.toLowerCase().contains(q) ||
                (b.isbn != null && b.isbn!.toLowerCase().contains(q)))
            .toList();
      });
    }
  }

  Future<void> _updateStock(BookModel book, int newStock) async {
    if (newStock < 0) return;

    final response = await BookService.updateBook(book.id, {'stock_quantity': newStock});

    if (!mounted) return;

    if (response.success) {
      _loadBooks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: AppConstants.dangerColor,
        ),
      );
    }
  }

  Future<void> _deleteBook(BookModel book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to permanently delete "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppConstants.dangerColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final response = await BookService.deleteBook(book.id);
    if (!mounted) return;

    if (response.success) {
      _loadBooks();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book deleted successfully'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Inventory & Books',
          style: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppConstants.textPrimary),
            onPressed: _loadBooks,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppConstants.primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Book', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const AddBookScreen()),
          );
          if (added == true) _loadBooks();
        },
      ),
      body: Column(
        children: [
          // Search filter bar
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: _filterBooks,
              decoration: InputDecoration(
                hintText: 'Search by title, author, or ISBN...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppConstants.textSecondary),
                filled: true,
                fillColor: AppConstants.surfaceColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading inventory...');
    }

    if (_errorMessage != null) {
      return CustomErrorWidget(message: _errorMessage!, onRetry: _loadBooks);
    }

    if (_filteredBooks.isEmpty) {
      return const EmptyWidget(
        icon: Icons.inventory_2_outlined,
        title: 'No books found',
        subtitle: 'No inventory items match your current filter.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: _filteredBooks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final book = _filteredBooks[index];

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Book Cover + Full Book Information
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      book.imageUrl ?? AppConstants.fallbackBookCover,
                      width: 52,
                      height: 74,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 52,
                        height: 74,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.book, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'by ${book.author}',
                          style: const TextStyle(color: AppConstants.textSecondary, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              '\$${book.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppConstants.primaryColor,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: book.inStock
                                    ? (book.isLowStock ? Colors.amber.shade50 : Colors.green.shade50)
                                    : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                book.inStock ? 'Stock: ${book.stockQuantity}' : 'Out of Stock',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: book.inStock
                                      ? (book.isLowStock ? AppConstants.warningColor : AppConstants.successColor)
                                      : AppConstants.dangerColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 8),

              // Row 2: Stock Quick Controls & Management Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Quick Stock Stepper
                  Container(
                    decoration: BoxDecoration(
                      color: AppConstants.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: book.stockQuantity > 0 ? () => _updateStock(book, book.stockQuantity - 1) : null,
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Icon(Icons.remove, size: 16, color: AppConstants.textSecondary),
                          ),
                        ),
                        Text(
                          '${book.stockQuantity}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        InkWell(
                          onTap: () => _updateStock(book, book.stockQuantity + 1),
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Icon(Icons.add, size: 16, color: AppConstants.primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Edit & Delete Actions
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.edit_outlined, size: 14),
                        label: const Text('Edit', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppConstants.infoColor,
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: const Size(0, 32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(builder: (context) => EditBookScreen(book: book)),
                          );
                          if (updated == true) _loadBooks();
                        },
                      ),
                      if (widget.canDelete) ...[
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.delete_outline, size: 14),
                          label: const Text('Delete', style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppConstants.dangerColor,
                            side: BorderSide(color: Colors.red.shade200),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: const Size(0, 32),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _deleteBook(book),
                        ),
                      ],
                    ],
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
