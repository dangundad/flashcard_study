import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:flashcard_study/app/controllers/study_controller.dart';
import 'package:flashcard_study/app/pages/study/widgets/flip_card_widget.dart';

class StudyPage extends GetView<StudyController> {
  const StudyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Obx(
          () => Text(
            '${'studying'.tr} ${controller.currentIndex.value + 1}/${controller.cards.length}',
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isDone.value) {
          return _SessionComplete(controller: controller, cs: cs);
        }

        final card = controller.currentCard;
        if (card == null) return const SizedBox.shrink();

        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.surface, cs.primary.withValues(alpha: 0.05), cs.surface],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  _ProgressBar(controller: controller, cs: cs),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: FlipCardWidget(
                      front: card.front,
                      back: card.back,
                      isFlipped: controller.isFlipped.value,
                      onTap: controller.flip,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: controller.isFlipped.value
                        ? _RatingButtons(onRate: controller.rateCard)
                        : _FlipPrompt(),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final StudyController controller;
  final ColorScheme cs;

  const _ProgressBar({required this.controller, required this.cs});

  @override
  Widget build(BuildContext context) {
    final total = controller.cards.length;
    final done = controller.currentIndex.value;
    final progress = total > 0 ? done / total : 0.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${controller.remaining} ${'cards_left'.tr}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: cs.onSurfaceVariant,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.h,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlipPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('prompt'),
      height: 112.h,
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app_rounded, size: 20.r, color: cs.onSurfaceVariant),
          SizedBox(width: 6.w),
          Text(
            'tap_card_to_flip'.tr,
            style: TextStyle(fontSize: 14.sp, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _RatingButtons extends StatelessWidget {
  final void Function(int quality) onRate;

  const _RatingButtons({required this.onRate});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('ratings'),
      height: 112.h,
      child: Column(
        children: [
          Text(
            'how_well'.tr,
            style: TextStyle(
              fontSize: 13.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _RateBtn(
                label: 'rate_again'.tr,
                color: const Color(0xFFC62828),
                onTap: () => onRate(0),
              ),
              SizedBox(width: 6.w),
              _RateBtn(
                label: 'rate_hard'.tr,
                color: const Color(0xFFE65100),
                onTap: () => onRate(1),
              ),
              SizedBox(width: 6.w),
              _RateBtn(
                label: 'rate_good'.tr,
                color: const Color(0xFF1565C0),
                onTap: () => onRate(2),
              ),
              SizedBox(width: 6.w),
              _RateBtn(
                label: 'rate_easy'.tr,
                color: const Color(0xFF2E7D32),
                onTap: () => onRate(3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RateBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RateBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52.h,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: color, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _SessionComplete extends StatelessWidget {
  final StudyController controller;
  final ColorScheme cs;

  const _SessionComplete({required this.controller, required this.cs});

  @override
  Widget build(BuildContext context) {
    final correct = controller.sessionCorrect.value;
    final total = controller.sessionTotal.value;
    final pct = controller.accuracy * 100;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              pct >= 80 ? '?럦' : '?뮞',
              style: TextStyle(fontSize: 64.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              'session_done'.tr,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
                color: cs.primary,
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: cs.outline.withValues(alpha: 0.25)),
              ),
              child: Column(
                children: [
                  _Row(
                    label: 'result_correct'.tr,
                    value: '$correct / $total',
                    color: cs.primary,
                    bold: true,
                  ),
                  SizedBox(height: 8.h),
                  _Row(
                    label: 'result_accuracy'.tr,
                    value: '${pct.round()}%',
                    color: pct >= 80
                        ? const Color(0xFF2E7D32)
                        : pct >= 60
                            ? Colors.orange
                            : cs.error,
                  ),
                ],
              ),
            ),
            SizedBox(height: 28.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: Text('back_to_deck'.tr),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: FilledButton(
                    onPressed: controller.restartSession,
                    child: Text('study_again'.tr),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool bold;

  const _Row({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, color: cs.onSurfaceVariant)),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 20.sp : 16.sp,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
