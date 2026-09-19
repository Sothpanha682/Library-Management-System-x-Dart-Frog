import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/book.dart';
import '../../providers/book_provider.dart';
import '../../widgets/confirm_dialog.dart';
import 'add_edit_book_screen.dart';

class ManageBooksScreen extends StatelessWidget {
  const ManageBooksScreen({super.key});

  Future<void> _handleDelete(BuildContext context, Book book) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Book',
      message: 'Are you sure you want to delete "${book.title}" (ISBN: ${book.isbn})? This action cannot be undone.',
      confirmLabel: 'Delete Book',
      isDestructive: true,
    );

    if (!confirmed || !context.mounted) return;

    final bookProvider = context.read<BookProvider>();
    final success = await bookProvider.deleteBook(book.id);

    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book removed from catalog.'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookProvider.errorMessage ?? 'Could not delete book'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<BookProvider>();
    final books = bookProvider.books;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Books'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Book'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditBookScreen()),
          );
        },
      ),
      body: books.isEmpty
          ? const Center(child: Text('No books in catalog yet'))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      book.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text('${book.author} • ${book.category}'),
                        const SizedBox(height: 2),
                        Text(
                          'Stock: ${book.availableQuantity}/${book.quantity} available • ISBN: ${book.isbn}',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddEditBookScreen(book: book),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                          onPressed: () => _handleDelete(context, book),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
