import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/borrowing.dart';
import '../../providers/book_provider.dart';
import '../../providers/borrowing_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/status_badge.dart';

class MyBorrowingsScreen extends StatefulWidget {
  const MyBorrowingsScreen({super.key});

  @override
  State<MyBorrowingsScreen> createState() => _MyBorrowingsScreenState();
}

class _MyBorrowingsScreenState extends State<MyBorrowingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BorrowingProvider>().fetchMyBorrowings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleReturn(Borrowing borrowing) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Return Book',
      message: 'Are you sure you want to return "${borrowing.bookTitle ?? 'this book'}"? The library inventory will update immediately.',
      confirmLabel: 'Confirm Return',
    );

    if (!confirmed || !mounted) return;

    final borrowingProvider = context.read<BorrowingProvider>();
    final success = await borrowingProvider.returnBook(borrowing.id);

    if (!mounted) return;
    if (success) {
      // Also refresh books inventory
      context.read<BookProvider>().fetchBooks();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book returned successfully! Thank you.'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(borrowingProvider.errorMessage ?? 'Return failed'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final borrowingProvider = context.watch<BorrowingProvider>();
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Borrowed Books'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          indicatorColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: [
            Tab(text: 'Active Loans (${borrowingProvider.activeBorrowings.length})'),
            Tab(text: 'History (${borrowingProvider.historyBorrowings.length})'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => borrowingProvider.fetchMyBorrowings(),
        child: TabBarView(
          controller: _tabController,
          children: [
            // Active Loans Tab
            _buildBorrowingList(
              items: borrowingProvider.activeBorrowings,
              dateFormat: dateFormat,
              isActive: true,
              isLoading: borrowingProvider.isLoading,
            ),
            // History Tab
            _buildBorrowingList(
              items: borrowingProvider.historyBorrowings,
              dateFormat: dateFormat,
              isActive: false,
              isLoading: borrowingProvider.isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBorrowingList({
    required List<Borrowing> items,
    required DateFormat dateFormat,
    required bool isActive,
    required bool isLoading,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return EmptyStateView(
        icon: isActive ? Icons.bookmark_remove_outlined : Icons.history_rounded,
        title: isActive ? 'No Active Loans' : 'No Borrowing History',
        subtitle: isActive
            ? 'You currently have no active book loans. Explore the catalog to borrow textbooks.'
            : 'Returned books will appear here for your academic record.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isOverdue = item.isOverdue;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.bookTitle ?? 'Library Book #${item.bookId}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (item.bookAuthor != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.bookAuthor!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (item.isReturned)
                      StatusBadge.returned()
                    else
                      StatusBadge.borrowed(isOverdue: isOverdue),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isOverdue ? AppTheme.errorRed.withOpacity(0.06) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isOverdue ? AppTheme.errorRed.withOpacity(0.2) : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'BORROWED ON',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateFormat.format(item.borrowedAt),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.isReturned ? 'RETURNED ON' : 'DUE DATE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isOverdue ? AppTheme.errorRed : AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.isReturned && item.returnedAt != null
                                  ? dateFormat.format(item.returnedAt!)
                                  : dateFormat.format(item.dueDate),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isOverdue ? AppTheme.errorRed : AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isActive) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.secondaryTeal,
                        side: const BorderSide(color: AppTheme.secondaryTeal, width: 1.5),
                        minimumSize: const Size.fromHeight(42),
                      ),
                      onPressed: () => _handleReturn(item),
                      icon: const Icon(Icons.assignment_return_outlined, size: 18),
                      label: const Text('Return Book to Library'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
