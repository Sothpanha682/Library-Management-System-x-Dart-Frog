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
  final _searchController = TextEditingController();
  List<Borrowing> _borrowings = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _filter = 'All'; // All, Active, Returned
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBorrowings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM dd, yyyy');

    final filtered = _borrowings.where((item) {
      if (_filter == 'Active' && item.isReturned) return false;
      if (_filter == 'Returned' && !item.isReturned) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final title = (item.bookTitle ?? '').toLowerCase();
        final name = (item.userName ?? '').toLowerCase();
        final email = (item.userEmail ?? '').toLowerCase();
        return title.contains(q) || name.contains(q) || email.contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All University Loans'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadBorrowings,
        child: Column(
          children: [
            // Search & Filter
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                decoration: InputDecoration(
                  hintText: 'Filter by student name, email, or book title...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _filter == 'All',
                    onSelected: (val) => setState(() => _filter = 'All'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Active Loans'),
                    selected: _filter == 'Active',
                    onSelected: (val) => setState(() => _filter = 'Active'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Returned'),
                    selected: _filter == 'Returned',
                    onSelected: (val) => setState(() => _filter = 'Returned'),
                  ),
                ],
              ),
            ),
            const Divider(height: 12),

            Expanded(
              child: Builder(
                builder: (context) {
                  if (_isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_errorMessage != null) {
                    return EmptyStateView(
                      icon: Icons.error_outline_rounded,
                      title: 'Failed to Load Records',
                      subtitle: _errorMessage!,
                      actionLabel: 'Try Again',
                      onAction: _loadBorrowings,
                    );
                  }

                  if (filtered.isEmpty) {
                    return EmptyStateView(
                      icon: Icons.assignment_turned_in_outlined,
                      title: 'No Loans Found',
                      subtitle: _searchQuery.isNotEmpty || _filter != 'All'
                          ? 'No borrowing records match your current filter.'
                          : 'There are no active or historic book borrowings in the system yet.',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
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
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.bookTitle ?? 'Book #${item.bookId}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: isDark ? Colors.white : AppTheme.textPrimaryLight,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (item.isReturned)
                                    StatusBadge.returned()
                                  else
                                    StatusBadge.borrowed(isOverdue: item.isOverdue),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.person_outline_rounded,
                                        size: 15,
                                        color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondaryLight),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        '${item.userName ?? 'User #${item.userId}'} • ${item.userEmail ?? ''}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Borrowed: ${dateFormat.format(item.borrowedAt)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondaryLight,
                                    ),
                                  ),
                                  Text(
                                    item.isReturned && item.returnedAt != null
                                        ? 'Returned: ${dateFormat.format(item.returnedAt!)}'
                                        : 'Due: ${dateFormat.format(item.dueDate)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: item.isOverdue && !item.isReturned
                                          ? AppTheme.errorRed
                                          : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155)),
                                    ),
                                  ),
                                ],
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
          ],
        ),
      ),
    );
  }
}
