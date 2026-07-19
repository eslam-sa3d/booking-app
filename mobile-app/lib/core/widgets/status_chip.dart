import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../../data/models/enums.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.status});

  final String label;
  final BookingStatus status;

  Color _color() {
    switch (status) {
      case BookingStatus.pending:
        return Colors.grey.shade600;
      case BookingStatus.confirmed:
        return AppColors.success;
      case BookingStatus.waitlisted:
        return AppColors.warning;
      case BookingStatus.cancelled:
        return AppColors.error;
      case BookingStatus.completed:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}
