import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/borrowing_provider.dart';
import '../../providers/reservation_provider.dart';
import '../books/book_search_screen.dart';
import '../borrowing/my_borrowings_screen.dart';
import '../profile/profile_screen.dart';
import '../reservations/my_reservations_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    BookSearchScreen(),
    MyBorrowingsScreen(),
    MyReservationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final borrowingProvider = context.watch<BorrowingProvider>();
    final reservationProvider = context.watch<ReservationProvider>();
    final isAdmin = authProvider.isAdmin;

    final activeLoansCount = borrowingProvider.activeBorrowings.length;
    final activeHoldsCount = reservationProvider.activeReservations.length;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) {
          setState(() => _currentIndex = idx);
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.search_rounded),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: activeLoansCount > 0,
              label: Text('$activeLoansCount'),
              child: const Icon(Icons.menu_book_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: activeLoansCount > 0,
              label: Text('$activeLoansCount'),
              child: const Icon(Icons.menu_book_rounded),
            ),
            label: 'My Loans',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: activeHoldsCount > 0,
              label: Text('$activeHoldsCount'),
              backgroundColor: theme.colorScheme.tertiary,
              child: const Icon(Icons.bookmark_border_rounded),
            ),
            selectedIcon: Badge(
              isLabelVisible: activeHoldsCount > 0,
              label: Text('$activeHoldsCount'),
              backgroundColor: theme.colorScheme.tertiary,
              child: const Icon(Icons.bookmark_rounded),
            ),
            label: 'Holds',
          ),
          NavigationDestination(
            icon: Icon(isAdmin ? Icons.admin_panel_settings_outlined : Icons.person_outline_rounded),
            selectedIcon: Icon(isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded),
            label: isAdmin ? 'Admin' : 'Profile',
          ),
        ],
      ),
    );
  }
}
