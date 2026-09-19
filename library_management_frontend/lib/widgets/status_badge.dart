import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  factory StatusBadge.available() {
    return const StatusBadge(
      label: 'Available',
      color: Color(0xFF16A34A),
      icon: Icons.check_circle_outline,
    );
  }

  factory StatusBadge.unavailable() {
    return const StatusBadge(
      label: 'Checked Out',
      color: Color(0xFFDC2626),
      icon: Icons.remove_circle_outline,
    );
  }

  factory StatusBadge.borrowed({bool isOverdue = false}) {
    if (isOverdue) {
      return const StatusBadge(
        label: 'Overdue',
        color: Color(0xFFDC2626),
        icon: Icons.warning_amber_rounded,
      );
    }
    return const StatusBadge(
      label: 'Borrowed',
      color: Color(0xFF2563EB),
      icon: Icons.menu_book_rounded,
    );
  }

  factory StatusBadge.returned() {
    return const StatusBadge(
      label: 'Returned',
      color: Color(0xFF0D9488),
      icon: Icons.assignment_turned_in_outlined,
    );
  }

  factory StatusBadge.reservation(String status) {
    switch (status) {
      case 'available':
        return const StatusBadge(
          label: 'Ready for Pickup',
          color: Color(0xFF16A34A),
          icon: Icons.mark_email_read_outlined,
        );
      case 'cancelled':
        return const StatusBadge(
          label: 'Cancelled',
          color: Color(0xFF64748B),
          icon: Icons.cancel_outlined,
        );
      case 'expired':
        return const StatusBadge(
          label: 'Expired',
          color: Color(0xFFDC2626),
          icon: Icons.timer_off_outlined,
        );
      default:
        return const StatusBadge(
          label: 'Pending',
          color: Color(0xFFD97706),
          icon: Icons.hourglass_top_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
