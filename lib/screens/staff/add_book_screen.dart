import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../services/book_service.dart';
import '../../services/category_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<CategoryModel> _categories = [];
  int? _selectedCategoryId;
  bool _isLoadingCategories = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final response = await CategoryService.getCategories();
    if (!mounted) return;
    setState(() {
      _categories = response.data ?? [];
      if (_categories.isNotEmpty) {
        _selectedCategoryId = _categories.first.id;
      }
      _isLoadingCategories = false;
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final bookData = {
      'title': _titleController.text.trim(),
      'author': _authorController.text.trim(),
      'isbn': _isbnController.text.trim().isNotEmpty ? _isbnController.text.trim() : null,
      'price': double.parse(_priceController.text.trim()),
      'stock_quantity': int.parse(_stockController.text.trim()),
      'category_id': _selectedCategoryId,
      'image_url': _imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : null,
      'description': _descriptionController.text.trim(),
    };

    final response = await BookService.addBook(bookData);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book added to inventory successfully!'),
          backgroundColor: AppConstants.successColor,
        ),
      );
      Navigator.pop(context, true);
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
          'Add New Book',
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
              CustomTextField(
                controller: _titleController,
                label: 'Book Title *',
                hint: 'e.g. Clean Code',
                validator: (val) => Validators.validateRequired(val, 'Title'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _authorController,
                label: 'Author Name *',
                hint: 'e.g. Robert C. Martin',
                validator: (val) => Validators.validateRequired(val, 'Author'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceController,
                      label: 'Price (\$) *',
                      hint: '29.99',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: Validators.validatePrice,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: CustomTextField(
                      controller: _stockController,
                      label: 'Stock Quantity *',
                      hint: '10',
                      keyboardType: TextInputType.number,
                      validator: Validators.validateStock,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _isbnController,
                label: 'ISBN',
                hint: '978-0132350884',
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              const Text(
                'Category',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConstants.textPrimary),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: _isLoadingCategories
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedCategoryId,
                          isExpanded: true,
                          items: _categories.map((cat) {
                            return DropdownMenuItem<int>(
                              value: cat.id,
                              child: Text(cat.name),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedCategoryId = val),
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _imageUrlController,
                label: 'Cover Image URL',
                hint: 'https://images.unsplash.com/...',
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Overview and synopsis of the book...',
                maxLines: 4,
              ),
              const SizedBox(height: 28),

              CustomButton(
                text: 'Save Book to Catalog',
                icon: Icons.check_circle_outline_rounded,
                isLoading: _isSaving,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
