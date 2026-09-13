import 'package:flutter/material.dart';
import '../../models/book_model.dart';
import '../../models/category_model.dart';
import '../../services/api_service.dart';
import '../../services/book_service.dart';
import '../../services/cart_service.dart';
import '../../services/category_service.dart';
import '../../utils/constants.dart';
import '../../widgets/book_card.dart';
import '../../widgets/loading_widget.dart';
import 'book_details_screen.dart';
import 'book_list_screen.dart';
import 'cart_screen.dart';
import 'category_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const _HomeFeedTab(),
    const SearchScreen(),
    const CartScreen(),
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
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag_rounded),
              label: 'Cart',
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

class _HomeFeedTab extends StatefulWidget {
  const _HomeFeedTab();

  @override
  State<_HomeFeedTab> createState() => _HomeFeedTabState();
}

class _HomeFeedTabState extends State<_HomeFeedTab> {
  String _userName = 'Reader';
  List<BookModel> _featuredBooks = [];
  List<BookModel> _latestBooks = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    setState(() => _isLoading = true);

    final userName = await ApiService.getUserName();
    if (userName != null && userName.isNotEmpty) {
      _userName = userName.split(' ').first;
    }

    final featuredFuture = BookService.getBooks(filter: 'featured', limit: 6);
    final latestFuture = BookService.getBooks(filter: 'latest', limit: 8);
    final categoriesFuture = CategoryService.getCategories();

    final results = await Future.wait([featuredFuture, latestFuture, categoriesFuture]);

    if (!mounted) return;

    setState(() {
      _featuredBooks = (results[0].data as List<BookModel>?) ?? [];
      _latestBooks = (results[1].data as List<BookModel>?) ?? [];
      _categories = (results[2].data as List<CategoryModel>?) ?? [];
      _isLoading = false;
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
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Discovering great books...'),
      );
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadFeed,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Welcome Banner
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $_userName 👋',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppConstants.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'What will you read today?',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppConstants.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.shopping_bag_outlined, color: AppConstants.textPrimary),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CartScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar trigger
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SearchScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search_rounded, color: AppConstants.textMuted, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Search books by title, author...',
                            style: TextStyle(color: AppConstants.textMuted, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Featured Books Carousel Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Featured Books',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textPrimary),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BookListScreen(title: 'Featured Books'),
                            ),
                          );
                        },
                        child: const Text('See All', style: TextStyle(color: AppConstants.accentColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 255,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: _featuredBooks.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final book = _featuredBooks[index];
                      return SizedBox(
                        width: 155,
                        child: BookCard(
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
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Categories Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textPrimary),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BookListScreen(title: 'All Categories'),
                            ),
                          );
                        },
                        child: const Text('Explore', style: TextStyle(color: AppConstants.accentColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      return ActionChip(
                        label: Text('${cat.name} (${cat.bookCount})'),
                        backgroundColor: Colors.white,
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        labelStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.textPrimary,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryScreen(category: cat),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),

                // Latest Books Grid Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Latest Arrivals',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textPrimary),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BookListScreen(title: 'Latest Arrivals'),
                            ),
                          );
                        },
                        child: const Text('See All', style: TextStyle(color: AppConstants.accentColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.62,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: _latestBooks.length,
                    itemBuilder: (context, index) {
                      final book = _latestBooks[index];
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
