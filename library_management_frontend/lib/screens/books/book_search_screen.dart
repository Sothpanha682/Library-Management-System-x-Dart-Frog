import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/book_provider.dart';
import '../../widgets/book_card.dart';
import '../../widgets/empty_state_view.dart';
import 'book_details_screen.dart';

class BookSearchScreen extends StatefulWidget {
  const BookSearchScreen({super.key});

  @override
  State<BookSearchScreen> createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<BookProvider>().search(query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookProvider = context.watch<BookProvider>();
    final isSearching = bookProvider.isSearching;
    final results = bookProvider.searchResults;

    final filteredResults = _selectedCategory == 'All'
        ? results
        : results.where((b) => b.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _searchController,
            autofocus: false,
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            style: TextStyle(
              fontSize: 14.5,
              color: isDark ? Colors.white : AppTheme.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: 'Search title, author, category, ISBN...',
              hintStyle: TextStyle(
                fontSize: 13.5,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                size: 20,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips Row
          if (_searchController.text.trim().isNotEmpty) ...[
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: AppConstants.bookCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = AppConstants.bookCategories[index];
                  final isSelected = cat == _selectedCategory;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                  );
                },
              ),
            ),
            const Divider(height: 8),
          ],

          // Content
          Expanded(
            child: Builder(
              builder: (context) {
                if (isSearching) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_searchController.text.trim().isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.travel_explore_rounded,
                    title: 'Discover Academic Resources',
                    subtitle: 'Search any book title, professor or author, academic subject, or ISBN barcode.',
                  );
                }

                if (filteredResults.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.menu_book_outlined,
                    title: 'No Matching Books Found',
                    subtitle: 'No catalog entries matched "${_searchController.text.trim()}". Check for typos or broaden your query.',
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Found ${filteredResults.length} matching result${filteredResults.length == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: filteredResults.length,
                        itemBuilder: (context, index) {
                          final book = filteredResults[index];
                          return BookCard(
                            book: book,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BookDetailsScreen(bookId: book.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
