import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/borrowing.dart';
import '../../services/borrowing_service.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/status_badge.dart';

class AdminBorrowingsScreen extends StatefulWidget {
  const AdminBorrowingsScreen({super.key});

  @override
  State<AdminBorrowingsScreen> createState() => _AdminBorrowingsScreenState();
}

class _AdminBorrowingsScreenState extends State<AdminBorrowingsScreen> {
  final _borrowingService = BorrowingService();
  List<Borrowing> _borrowings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBorrowings();
  }

  Future<void> _loadBorrowings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _borrowingService.getAllBorrowings();
      if (mounted) {
        setState(() {
          _borrowings = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('All University Borrowings'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBorrowings,
        child: Builder(
          builder: (context) {
            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_errorMessage != null) {
              return EmptyStateView(
                icon: Icons.error_outline,
                title: 'Failed to Load Records',
                subtitle: _errorMessage!,
                actionLabel: 'Try Again',
                onAction: _loadBorrowings,
              );
            }

            if (_borrowings.isEmpty) {
              return const EmptyStateView(
                icon: Icons.assignment_turned_in_outlined,
                title: 'No Borrowing Records',
                subtitle: 'There are no active or historic book borrowings in the system yet.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _borrowings.length,
              itemBuilder: (context, index) {
                final item = _borrowings[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.bookTitle ?? 'Book #${item.bookId}',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                            ),
                            if (item.isReturned)
                              StatusBadge.returned()
                            else
                              StatusBadge.borrowed(isOverdue: item.isOverdue),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 14, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${item.userName ?? 'User #${item.userId}'} (${item.userEmail ?? ''})',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Borrowed: ${dateFormat.format(item.borrowedAt)} • Due: ${dateFormat.format(item.dueDate)}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
