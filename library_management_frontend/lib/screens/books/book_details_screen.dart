import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/book.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/borrowing_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/status_badge.dart';

class BookDetailsScreen extends StatefulWidget {
  const BookDetailsScreen({super.key, required this.bookId});

  final int bookId;

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  Book? _book;
  bool _isLoading = true;
  bool _isActionProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadBook();
  }

  Future<void> _loadBook() async {
    setState(() {
      _isLoading = true;
    });

    final book = await context.read<BookProvider>().getBookById(widget.bookId);

    if (mounted) {
      setState(() {
        _book = book;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleBorrow() async {
    if (_book == null) return;

    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Borrow Book',
      message: 'Would you like to borrow "${_book!.title}" for a standard 14-day loan period?',
      confirmLabel: 'Confirm Loan',
    );

    if (!confirmed || !mounted) return;

    setState(() => _isActionProcessing = true);
    final borrowingProvider = context.read<BorrowingProvider>();
    final success = await borrowingProvider.borrowBook(_book!.id);

    if (!mounted) return;
    setState(() => _isActionProcessing = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book borrowed successfully! Track it in "My Books".'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      _loadBook();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(borrowingProvider.errorMessage ?? 'Borrowing failed'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _handleReserve() async {
    if (_book == null) return;

    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Place Hold / Reservation',
      message: 'All physical copies are currently loaned out. Would you like to reserve "${_book!.title}"? You will receive priority when a copy is returned.',
      confirmLabel: 'Place Hold',
    );

    if (!confirmed || !mounted) return;

    setState(() => _isActionProcessing = true);
    final reservationProvider = context.read<ReservationProvider>();
    final success = await reservationProvider.createReservation(_book!.id);

    if (!mounted) return;
    setState(() => _isActionProcessing = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reservation placed successfully! View in "Holds".'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      _loadBook();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reservationProvider.errorMessage ?? 'Reservation failed'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_book == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Book not found')),
      );
    }

    final book = _book!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: book.isAvailable
              ? ElevatedButton.icon(
                  onPressed: _isActionProcessing ? null : _handleBorrow,
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: _isActionProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Borrow Book (14 Days)'),
                )
              : OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentAmber,
                    side: const BorderSide(color: AppTheme.accentAmber, width: 1.5),
                  ),
                  onPressed: _isActionProcessing ? null : _handleReserve,
                  icon: const Icon(Icons.hourglass_empty_rounded),
                  label: _isActionProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentAmber),
                        )
                      : const Text('All Copies Out • Reserve Book'),
                ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Book Cover and Primary Specs
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 120,
                    height: 175,
                    color: AppTheme.primaryBlue.withOpacity(0.08),
                    child: book.coverImage != null && book.coverImage!.isNotEmpty
                        ? Image.network(
                            book.coverImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.menu_book, color: AppTheme.primaryBlue, size: 48),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.menu_book, color: AppTheme.primaryBlue, size: 48),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          book.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'by ${book.author}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (book.isAvailable)
                        StatusBadge.available()
                      else
                        StatusBadge.unavailable(),
                      const SizedBox(height: 8),
                      Text(
                        '${book.availableQuantity} of ${book.quantity} copies in library',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Metadata Grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ISBN NUMBER',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.isbn,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 32, color: Colors.grey.shade300),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LOAN PERIOD',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '14 Days',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Synopsis & Description',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              book.description != null && book.description!.isNotEmpty
                  ? book.description!
                  : 'No detailed description provided for this academic catalog entry.',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
