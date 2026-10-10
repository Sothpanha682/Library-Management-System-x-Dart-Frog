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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookProvider.errorMessage ?? 'Operation failed'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final categories = AppConstants.bookCategories.where((c) => c != 'All').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Book Record' : 'Add New Book'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextField(
                          controller: _titleController,
                          label: 'Book Title',
                          hint: 'Introduction to Algorithms',
                          prefixIcon: Icons.menu_book_rounded,
                          validator: (val) => val == null || val.trim().isEmpty ? 'Title is required' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _authorController,
                          label: 'Author(s)',
                          hint: 'Thomas H. Cormen, Charles E. Leiserson',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (val) => val == null || val.trim().isEmpty ? 'Author is required' : null,
                        ),
                        const SizedBox(height: 16),

                        // Category Dropdown
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Department / Category',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 7),
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                                label: 'ISBN Code',
                                hint: '978-0262033848',
                                prefixIcon: Icons.qr_code_2_rounded,
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
                                prefixIcon: Icons.inventory_2_outlined,
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
                          prefixIcon: Icons.image_outlined,
                          onChanged: (_) => setState(() {}),
                        ),
                        if (_coverImageController.text.trim().isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                _coverImageController.text.trim(),
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Text(
                                  'Preview unavailable (invalid image URL)',
                                  style: TextStyle(fontSize: 11, color: AppTheme.errorRed),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _descriptionController,
                          label: 'Academic Abstract / Synopsis',
                          hint: 'Detailed curriculum topics and book overview...',
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  FilledButton(
                    onPressed: _isLoading ? null : _handleSave,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            isEditing ? 'Save Book Changes' : 'Publish Book to Catalog',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
