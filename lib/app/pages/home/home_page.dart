import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:flashcard_study/app/admob/ads_banner.dart';
import 'package:flashcard_study/app/admob/ads_helper.dart';
import 'package:flashcard_study/app/admob/ads_rewarded.dart';
import 'package:flashcard_study/app/controllers/deck_controller.dart';
import 'package:flashcard_study/app/data/deck_templates.dart';
import 'package:flashcard_study/app/data/models/flash_deck.dart';
import 'package:flashcard_study/app/routes/app_pages.dart';

class HomePage extends GetView<DeckController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              '📚',
              style: TextStyle(fontSize: 22.sp),
            ),
            SizedBox(width: 8.w),
            Text(
              'app_name'.tr,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.chartBar, size: 20.r, color: cs.onSurfaceVariant),
            tooltip: 'stats'.tr,
            onPressed: () => Get.toNamed(Routes.STATS),
          ),
          IconButton(
            icon: Icon(LucideIcons.settings, size: 20.r, color: cs.onSurfaceVariant),
            tooltip: 'settings'.tr,
            onPressed: () => Get.toNamed(Routes.SETTINGS),
          ),
          SizedBox(width: 4.w),
        ],
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: cs.surface,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.tertiary],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primary.withValues(alpha: 0.08),
              cs.surface,
              cs.secondaryContainer.withValues(alpha: 0.12),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  if (controller.decks.isEmpty) {
                    return ListView(
                      padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 16.r),
                      children: [
                        _EmptyState(cs: cs),
                        SizedBox(height: 20.h),
                        _GradientButton(
                          label: 'new_deck'.tr,
                          icon: LucideIcons.plus,
                          onTap: () => _showCreateDeckDialog(context),
                        ),
                        SizedBox(height: 24.h),
                        _TemplateSectionWidget(controller: controller),
                      ],
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 16.r),
                    itemCount: controller.decks.length + 2,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: _TodaySummaryCard(controller: controller),
                        );
                      }
                      final deckIndex = i - 1;
                      if (deckIndex < controller.decks.length) {
                        return _DeckCard(
                          deck: controller.decks[deckIndex],
                          controller: controller,
                          index: deckIndex,
                        );
                      }
                      return Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: _TemplateSectionWidget(controller: controller),
                      );
                    },
                  );
                }),
              ),
              Container(
                color: cs.surface.withValues(alpha: 0.92),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 12.w,
                      right: 12.w,
                      top: 8.h,
                      bottom: 10.h,
                    ),
                    child: BannerAdWidget(
                      adUnitId: AdHelper.bannerAdUnitId,
                      type: AdHelper.banner,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Obx(() {
        if (controller.decks.isEmpty) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          heroTag: 'home_fab',
          onPressed: () => _showCreateDeckDialog(context),
          icon: const Icon(LucideIcons.plus),
          label: Text('new_deck'.tr),
        );
      }),
    );
  }

  void _showCreateDeckDialog(
    BuildContext context, {
    FlashDeck? editing,
  }) {
    final titleCtrl = TextEditingController(text: editing?.title ?? '');
    final descCtrl = TextEditingController(text: editing?.description ?? '');

    Get.dialog(
      _DeckDialog(
        titleController: titleCtrl,
        descController: descCtrl,
        title: editing == null ? 'new_deck'.tr : 'edit_deck'.tr,
        titleHint: 'deck_title'.tr,
        descHint: 'deck_desc'.tr,
        confirmText: editing == null ? 'save'.tr : 'edit'.tr,
        onConfirm: () async {
          final t = titleCtrl.text.trim();
          if (t.isEmpty) return;
          if (editing == null) {
            await DeckController.to.createDeck(
              title: t,
              description: descCtrl.text.trim(),
            );
          } else {
            await DeckController.to.updateDeck(
              editing,
              title: t,
              description: descCtrl.text.trim(),
            );
          }
          Get.back();
        },
      ),
      barrierDismissible: true,
    );
  }
}

// ─── Today Summary Card ───────────────────────────────────────────────────────

class _TodaySummaryCard extends StatelessWidget {
  final DeckController controller;
  const _TodaySummaryCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final totalDue = controller.decks.fold<int>(
      0,
      (sum, d) => sum + controller.getDueCount(d.id),
    );
    final totalCards = controller.decks.fold<int>(
      0,
      (sum, d) => sum + controller.getTotalCount(d.id),
    );
    final totalDecks = controller.decks.length;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primaryContainer,
            cs.secondaryContainer.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              icon: LucideIcons.layers,
              value: '$totalDecks',
              label: 'stats_total_decks'.tr,
              cs: cs,
            ),
          ),
          _VerticalDivider(cs: cs),
          Expanded(
            child: _SummaryItem(
              icon: LucideIcons.creditCard,
              value: '$totalCards',
              label: 'total_cards'.tr,
              cs: cs,
            ),
          ),
          _VerticalDivider(cs: cs),
          Expanded(
            child: _SummaryItem(
              icon: LucideIcons.refreshCcw,
              value: '$totalDue',
              label: 'due_today'.tr,
              cs: cs,
              highlight: totalDue > 0,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.05, curve: Curves.easeOut);
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final ColorScheme cs;
  final bool highlight;

  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.cs,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final valueColor = highlight ? cs.error : cs.onPrimaryContainer;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20.r, color: cs.onPrimaryContainer.withValues(alpha: 0.75)),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: cs.onPrimaryContainer.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final ColorScheme cs;
  const _VerticalDivider({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48.h,
      color: cs.onPrimaryContainer.withValues(alpha: 0.15),
      margin: EdgeInsets.symmetric(horizontal: 4.w),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final ColorScheme cs;
  const _EmptyState({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 650),
              curve: Curves.elasticOut,
              builder: (ctx, v, child) => Transform.scale(scale: v, child: child),
              child: Text('🧠', style: TextStyle(fontSize: 64.sp)),
            ),
            SizedBox(height: 16.h),
            Text(
              'no_decks'.tr,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              'no_decks_sub'.tr,
              style: TextStyle(fontSize: 13.sp, color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Gradient CTA Button ──────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Get.theme.colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.tertiary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22.r, color: cs.onPrimary),
                SizedBox(width: 10.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Deck Card ────────────────────────────────────────────────────────────────

class _DeckCard extends StatelessWidget {
  final FlashDeck deck;
  final DeckController controller;
  final int index;

  const _DeckCard({
    required this.deck,
    required this.controller,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = controller.getTotalCount(deck.id);
    final due = controller.getDueCount(deck.id);
    final progress = controller.getProgress(deck.id);
    final progressColor = progress >= 0.8
        ? const Color(0xFF2E7D32)
        : progress >= 0.4
            ? Colors.orange
            : cs.error;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(20.r),
            onTap: () => Get.toNamed(Routes.DECK, arguments: deck.id),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40.r,
                        height: 40.r,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              cs.primary.withValues(alpha: 0.15),
                              cs.tertiary.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          LucideIcons.bookOpen,
                          size: 20.r,
                          color: cs.primary,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              deck.title,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (deck.description.isNotEmpty) ...[
                              SizedBox(height: 2.h),
                              Text(
                                deck.description,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: cs.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          LucideIcons.ellipsis,
                          color: cs.onSurfaceVariant,
                          size: 20.r,
                        ),
                        onSelected: (v) {
                          if (v == 'edit') {
                            _editDeck(context, deck);
                          } else if (v == 'delete') {
                            _deleteDeck(deck);
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(LucideIcons.pencil, size: 18.r),
                              title: Text('edit'.tr),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(
                                LucideIcons.trash2,
                                color: cs.error,
                                size: 18.r,
                              ),
                              title: Text(
                                'delete'.tr,
                                style: TextStyle(color: cs.error),
                              ),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      _Badge(
                        label: '$total ${'cards'.tr}',
                        color: cs.onSurfaceVariant,
                      ),
                      SizedBox(width: 8.w),
                      if (due > 0)
                        _Badge(
                          label: '$due ${'due'.tr}',
                          color: cs.primary,
                          filled: true,
                        ),
                      const Spacer(),
                      Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: progressColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6.h,
                      backgroundColor: cs.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate(delay: (index * 50).ms)
        .fadeIn()
        .slideX(begin: -0.1, curve: Curves.easeOut);
  }

  void _editDeck(BuildContext context, FlashDeck deck) {
    final titleCtrl = TextEditingController(text: deck.title);
    final descCtrl = TextEditingController(text: deck.description);

    Get.dialog(
      _DeckDialog(
        titleController: titleCtrl,
        descController: descCtrl,
        title: 'edit_deck'.tr,
        titleHint: 'deck_title'.tr,
        descHint: 'deck_desc'.tr,
        confirmText: 'save'.tr,
        onConfirm: () async {
          final t = titleCtrl.text.trim();
          if (t.isEmpty) return;
          await DeckController.to.updateDeck(
            deck,
            title: t,
            description: descCtrl.text.trim(),
          );
          Get.back();
        },
      ),
      barrierDismissible: true,
    );
  }

  void _deleteDeck(FlashDeck deck) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_deck'.tr),
        content: Text('delete_deck_confirm'.trParams({'title': deck.title})),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          FilledButton(
            onPressed: () async {
              await DeckController.to.deleteDeck(deck.id);
              Get.back();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(Get.context!).colorScheme.error,
            ),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }
}

// ─── Deck Dialog ──────────────────────────────────────────────────────────────

class _DeckDialog extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descController;
  final String title;
  final String titleHint;
  final String descHint;
  final String confirmText;
  final VoidCallback onConfirm;

  const _DeckDialog({
    required this.titleController,
    required this.descController,
    required this.title,
    required this.titleHint,
    required this.descHint,
    required this.confirmText,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 340.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: titleHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              autofocus: true,
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: descHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
        FilledButton(
          onPressed: onConfirm,
          child: Text(confirmText),
        ),
      ],
      backgroundColor: cs.surface,
    );
  }
}

// ─── Badge ────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;

  const _Badge({required this.label, required this.color, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.16) : Colors.transparent,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─── Template Section ─────────────────────────────────────────────────────────

class _TemplateSectionWidget extends StatelessWidget {
  final DeckController controller;
  const _TemplateSectionWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.sparkles, size: 18.r, color: cs.tertiary),
            SizedBox(width: 8.w),
            Text(
              'templates'.tr,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Text(
          'templates_desc'.tr,
          style: TextStyle(fontSize: 12.sp, color: cs.onSurfaceVariant),
        ),
        SizedBox(height: 12.h),
        ...DeckTemplates.all.map(
          (tpl) => _TemplateCard(template: tpl, controller: controller),
        ),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final DeckTemplate template;
  final DeckController controller;

  const _TemplateCard({
    required this.template,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final adManager = Get.isRegistered<RewardedAdManager>()
        ? RewardedAdManager.to
        : null;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.45),
          ),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: Row(
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.tertiary.withValues(alpha: 0.2),
                      cs.secondary.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  LucideIcons.bookMarked,
                  size: 20.r,
                  color: cs.tertiary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.titleKey.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      template.descKey.tr,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              adManager != null
                  ? Obx(() {
                      final ready = adManager.isAdReady.value;
                      return FilledButton.tonal(
                        onPressed: ready
                            ? () => controller.addTemplateWithAd(template)
                            : null,
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 8.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.play, size: 14.r),
                            SizedBox(width: 4.w),
                            Text(
                              'add_with_ad'.tr,
                              style: TextStyle(fontSize: 11.sp),
                            ),
                          ],
                        ),
                      );
                    })
                  : FilledButton.tonal(
                      onPressed: null,
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'loading'.tr,
                        style: TextStyle(fontSize: 11.sp),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
