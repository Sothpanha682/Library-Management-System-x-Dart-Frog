import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:library_management_frontend/widgets/status_badge.dart';

void main() {
  group('UI Components Widget Tests', () {
    testWidgets('StatusBadge displays Available and Borrowed states accurately', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusBadge.available(),
                StatusBadge.unavailable(),
                StatusBadge.borrowed(isOverdue: false),
                StatusBadge.borrowed(isOverdue: true),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Available'), findsOneWidget);
      expect(find.text('Checked Out'), findsOneWidget);
      expect(find.text('Borrowed'), findsOneWidget);
      expect(find.text('Overdue'), findsOneWidget);
    });
  });
}
