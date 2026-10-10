import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/book.dart';
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
      message: 'Would you like to borrow "${_book!.title}" for a standard 14-day academic loan period?',
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
        SnackBar(
          content: const Text('Book borrowed successfully! Track it in "My Loans".'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _loadBook();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(borrowingProvider.errorMessage ?? 'Borrowing failed'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _handleReserve() async {
    if (_book == null) return;

    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Place Academic Hold',
      message: 'All physical copies are currently checked out. Would you like to reserve "${_book!.title}"? You will be notified when a copy is returned.',
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
        SnackBar(
          content: const Text('Reservation placed successfully! View in "Holds".'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      _loadBook();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(reservationProvider.errorMessage ?? 'Reservation failed'),
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

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_book == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book Details')),
        body: const Center(child: Text('Book record not found')),
      );
    }

    final book = _book!;
    final categoryStyle = AppTheme.getCategoryStyle(book.category, isDark: isDark);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: book.isAvailable
              ? FilledButton.icon(
                  onPressed: _isActionProcessing ? null : _handleBorrow,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.bookmark_add_rounded, size: 20),
                  label: _isActionProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Borrow Book (14 Days)', style: TextStyle(fontWeight: FontWeight.w700)),
                )
              : OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentAmber,
                    side: const BorderSide(color: AppTheme.accentAmber, width: 1.5),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isActionProcessing ? null : _handleReserve,
                  icon: const Icon(Icons.hourglass_top_rounded, size: 18),
                  label: _isActionProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentAmber),
                        )
                      : const Text('All Copies Out • Place Hold', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Book Cover & Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 124,
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          categoryStyle.backgroundColor,
                          categoryStyle.backgroundColor.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: book.coverImage != null && book.coverImage!.trim().isNotEmpty
                        ? Image.network(
                            book.coverImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildFallbackHero(categoryStyle),
                          )
                        : _buildFallbackHero(categoryStyle),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: categoryStyle.backgroundColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(categoryStyle.icon, size: 12, color: categoryStyle.textColor),
                            const SizedBox(width: 4),
                            Text(
                              book.category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                                color: categoryStyle.textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                          height: 1.25,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'by ${book.author}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (book.isAvailable)
                        StatusBadge.available()
                      else
                        StatusBadge.unavailable(),
                      const SizedBox(height: 8),
                      Text(
                        '${book.availableQuantity} of ${book.quantity} physical copies in library',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
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

            // Metadata Grid Tiles
            Row(
              children: [
                Expanded(
                  child: _buildDetailTile(
                    title: 'ISBN CODE',
                    value: book.isbn,
                    icon: Icons.qr_code_2_rounded,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDetailTile(
                    title: 'LOAN DURATION',
                    value: '14 Days standard',
                    icon: Icons.calendar_month_rounded,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDetailTile(
                    title: 'TOTAL COPIES',
                    value: '${book.quantity} copies in catalog',
                    icon: Icons.inventory_2_outlined,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDetailTile(
                    title: 'DEPARTMENT',
                    value: book.category,
                    icon: categoryStyle.icon,
                    isDark: isDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),
            Text(
              'Synopsis & Academic Abstract',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                book.description != null && book.description!.trim().isNotEmpty
                    ? book.description!
                    : 'No abstract provided for this academic title in the library catalog.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                  height: 1.55,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackHero(CategoryStyle style) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_rounded, color: style.textColor, size: 48),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              _book?.category ?? '',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: style.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile({
    required String title,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondaryLight,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondaryLight,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
