import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:flashcard_study/app/admob/ads_banner.dart';
import 'package:flashcard_study/app/admob/ads_helper.dart';
import 'package:flashcard_study/app/controllers/deck_controller.dart';
import 'package:flashcard_study/app/data/models/flash_deck.dart';
import 'package:flashcard_study/app/routes/app_pages.dart';

class HomePage extends GetView<DeckController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primary.withValues(alpha: 0.12),
              cs.surface,
              cs.secondaryContainer.withValues(alpha: 0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.r),
                child: _Header(cs: cs, onCreate: () => _showCreateDeckDialog(context)),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.decks.isEmpty) {
                    return _EmptyState(cs: cs);
                  }
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.r, 0, 16.r, 16.r),
                    itemCount: controller.decks.length,
                    itemBuilder: (context, i) => _DeckCard(
                      deck: controller.decks[i],
                      controller: controller,
                      index: i,
                    ),
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'home_fab',
        onPressed: () => _showCreateDeckDialog(context),
        icon: const Icon(Icons.auto_awesome_rounded),
        label: Text('new_deck'.tr),
      ),
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

class _Header extends StatelessWidget {
  final ColorScheme cs;
  final VoidCallback onCreate;

  const _Header({required this.cs, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: cs.outline.withValues(alpha: 0.25)),
      ),
      padding: EdgeInsets.all(18.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.9, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutBack,
                builder: (context, value, child) => Transform.scale(
                  scale: value,
                  child: child,
                ),
                child: Text('📚', style: TextStyle(fontSize: 32.sp)),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'app_name'.tr,
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
              ),
              FilledButton.tonal(
                onPressed: onCreate,
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  'new_deck'.tr,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ColorScheme cs;
  const _EmptyState({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
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

class _DeckCard extends StatefulWidget {
  final FlashDeck deck;
  final DeckController controller;
  final int index;

  const _DeckCard({
    required this.deck,
    required this.controller,
    required this.index,
  });

  @override
  State<_DeckCard> createState() => _DeckCardState();
}

class _DeckCardState extends State<_DeckCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 55), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = widget.controller.getTotalCount(widget.deck.id);
    final due = widget.controller.getDueCount(widget.deck.id);
    final progress = widget.controller.getProgress(widget.deck.id);
    final progressColor = progress >= 0.8
        ? const Color(0xFF2E7D32)
        : progress >= 0.4
            ? Colors.orange
            : cs.error;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Card(
            elevation: 0,
            color: cs.surface.withValues(alpha: 0.9),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16.r),
              onTap: () => Get.toNamed(Routes.DECK, arguments: widget.deck.id),
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.deck.title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_horiz_rounded, color: cs.onSurfaceVariant),
                          onSelected: (v) {
                            if (v == 'edit') {
                              _editDeck(context, widget.deck);
                            } else if (v == 'delete') {
                              _deleteDeck(widget.deck);
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                leading: const Icon(Icons.edit_outlined),
                                title: Text('edit'.tr),
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete_outline, color: cs.error),
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
                    if (widget.deck.description.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        widget.deck.description,
                        style: TextStyle(fontSize: 12.sp, color: cs.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 12.h),
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
                      ],
                    ),
                    SizedBox(height: 10.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4.h,
                        backgroundColor: cs.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(fontSize: 11.sp, color: cs.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
