import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/book.dart';
import '../../providers/book_provider.dart';
import '../../widgets/custom_text_field.dart';

class AddEditBookScreen extends StatefulWidget {
  const AddEditBookScreen({super.key, this.book});

  final Book? book;

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _isbnController;
  late TextEditingController _quantityController;
  late TextEditingController _descriptionController;
  late TextEditingController _coverImageController;
  String _selectedCategory = AppConstants.bookCategories[1]; // default Computer Science
  bool _isLoading = false;

  bool get isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _titleController = TextEditingController(text: b?.title ?? '');
    _authorController = TextEditingController(text: b?.author ?? '');
    _isbnController = TextEditingController(text: b?.isbn ?? '');
    _quantityController = TextEditingController(text: b?.quantity.toString() ?? '5');
    _descriptionController = TextEditingController(text: b?.description ?? '');
    _coverImageController = TextEditingController(text: b?.coverImage ?? '');

    if (b != null && AppConstants.bookCategories.contains(b.category)) {
      _selectedCategory = b.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _coverImageController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final bookProvider = context.read<BookProvider>();

    bool success = false;
    final qty = int.tryParse(_quantityController.text) ?? 1;

    if (isEditing) {
      success = await bookProvider.updateBook(
        id: widget.book!.id,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        category: _selectedCategory,
        isbn: _isbnController.text.trim(),
        description: _descriptionController.text.trim(),
        coverImage: _coverImageController.text.trim(),
        quantity: qty,
        availableQuantity: widget.book!.availableQuantity,
      );
    } else {
      success = await bookProvider.createBook(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        category: _selectedCategory,
        isbn: _isbnController.text.trim(),
        description: _descriptionController.text.trim(),
        coverImage: _coverImageController.text.trim(),
        quantity: qty,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Book updated successfully!' : 'Book added to catalog!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookProvider.errorMessage ?? 'Operation failed'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = AppConstants.bookCategories.where((c) => c != 'All').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Book' : 'Add New Book'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Book Title',
                hint: 'Introduction to Algorithms',
                validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _authorController,
                label: 'Author(s)',
                hint: 'Thomas H. Cormen, Charles E. Leiserson',
                validator: (val) => val == null || val.trim().isEmpty ? 'Author is required' : null,
              ),
              const SizedBox(height: 16),

              // Category dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _isbnController,
                      label: 'ISBN',
                      hint: '978-0262033848',
                      validator: (val) => val == null || val.trim().isEmpty ? 'ISBN is required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: CustomTextField(
                      controller: _quantityController,
                      label: 'Total Copies',
                      hint: '5',
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        final parsed = int.tryParse(val ?? '');
                        if (parsed == null || parsed <= 0) return 'Min 1';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _coverImageController,
                label: 'Cover Image URL (Optional)',
                hint: 'https://images.unsplash.com/...',
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _descriptionController,
                label: 'Description / Abstract',
                hint: 'Overview of topics covered in this textbook...',
                maxLines: 4,
              ),
              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(isEditing ? 'Save Changes' : 'Add Book to Catalog'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
