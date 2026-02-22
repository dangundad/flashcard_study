import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:flashcard_study/app/data/models/flash_card.dart';

class CardItem extends StatelessWidget {
  final FlashCard card;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CardItem({
    super.key,
    required this.card,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        title: Text(
          card.front,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          card.back,
          style: TextStyle(fontSize: 12.sp, color: cs.onSurfaceVariant),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _IntervalBadge(card: card, cs: cs),
            SizedBox(width: 4.w),
            IconButton(
              icon: Icon(Icons.edit_outlined, size: 18.r),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 18.r, color: cs.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _IntervalBadge extends StatelessWidget {
  final FlashCard card;
  final ColorScheme cs;

  const _IntervalBadge({required this.card, required this.cs});

  @override
  Widget build(BuildContext context) {
    if (card.isMastered) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          '✓',
          style: TextStyle(
            fontSize: 11.sp,
            color: const Color(0xFF2E7D32),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    if (card.isDue) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          'due'.tr,
          style: TextStyle(
            fontSize: 10.sp,
            color: cs.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        '${card.interval}d',
        style: TextStyle(fontSize: 10.sp, color: cs.onSurfaceVariant),
      ),
    );
  }
}
