import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/book.dart';
import '../../providers/book_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state_view.dart';
import 'add_edit_book_screen.dart';

class ManageBooksScreen extends StatefulWidget {
  const ManageBooksScreen({super.key});

  @override
  State<ManageBooksScreen> createState() => _ManageBooksScreenState();
}

class _ManageBooksScreenState extends State<ManageBooksScreen> {
  final _searchController = TextEditingController();
  String _filterQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete(BuildContext context, Book book) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Book Title',
      message: 'Are you sure you want to remove "${book.title}" (ISBN: ${book.isbn}) from the library catalog? This action cannot be undone.',
      confirmLabel: 'Delete Book',
      isDestructive: true,
    );

    if (!confirmed || !context.mounted) return;

    final bookProvider = context.read<BookProvider>();
    final success = await bookProvider.deleteBook(book.id);

    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Book removed from catalog.'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookProvider.errorMessage ?? 'Could not delete book'),
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
    final bookProvider = context.watch<BookProvider>();
    final books = bookProvider.books;

    final filteredBooks = _filterQuery.isEmpty
        ? books
        : books.where((b) {
            final q = _filterQuery.toLowerCase();
            return b.title.toLowerCase().contains(q) ||
                b.author.toLowerCase().contains(q) ||
                b.isbn.toLowerCase().contains(q) ||
                b.category.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Books Catalog'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add New Book', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditBookScreen()),
          );
        },
      ),
      body: Column(
        children: [
          // Filter Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _filterQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Filter catalog titles, authors, or ISBN...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _filterQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _filterQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),

          Expanded(
            child: filteredBooks.isEmpty
                ? (books.isEmpty
                    ? const EmptyStateView(
                        icon: Icons.menu_book_rounded,
                        title: 'Catalog is Empty',
                        subtitle: 'Use the button below to add your first textbook to the university library.',
                      )
                    : EmptyStateView(
                        icon: Icons.search_off_rounded,
                        title: 'No Matching Books',
                        subtitle: 'No books in the catalog match "$_filterQuery".',
                      ))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 84),
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];
                      final categoryStyle = AppTheme.getCategoryStyle(book.category, isDark: isDark);

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Category Icon Container
                              Container(
                                width: 44,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: categoryStyle.backgroundColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(categoryStyle.icon, color: categoryStyle.textColor, size: 24),
                              ),
                              const SizedBox(width: 12),

                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.5,
                                        color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${book.author} • ${book.category}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondaryLight,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: book.isAvailable
                                                ? AppTheme.successGreen.withValues(alpha: isDark ? 0.2 : 0.1)
                                                : AppTheme.errorRed.withValues(alpha: isDark ? 0.2 : 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Stock: ${book.availableQuantity}/${book.quantity}',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: book.isAvailable ? AppTheme.successGreen : AppTheme.errorRed,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'ISBN: ${book.isbn}',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Actions
                              IconButton(
                                icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary, size: 20),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AddEditBookScreen(book: book),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorRed, size: 20),
                                onPressed: () => _handleDelete(context, book),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
