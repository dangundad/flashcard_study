import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:flashcard_study/app/admob/ads_banner.dart';
import 'package:flashcard_study/app/admob/ads_helper.dart';
import 'package:flashcard_study/app/controllers/deck_controller.dart';
import 'package:flashcard_study/app/data/models/flash_deck.dart';
import 'package:flashcard_study/app/routes/app_pages.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DeckController>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('app_name'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showCreateDeckDialog(context),
            tooltip: 'new_deck'.tr,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.decks.isEmpty) {
                return _EmptyState(cs: cs);
              }
              return ListView.builder(
                padding: EdgeInsets.all(16.r),
                itemCount: controller.decks.length,
                itemBuilder: (context, i) {
                  return _DeckCard(
                    deck: controller.decks[i],
                    controller: controller,
                    cs: cs,
                    index: i,
                  );
                },
              );
            }),
          ),
          BannerAdWidget(
            adUnitId: AdHelper.bannerAdUnitId,
            type: AdHelper.banner,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'home_fab',
        onPressed: () => _showCreateDeckDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: Text('new_deck'.tr),
      ),
    );
  }

  void _showCreateDeckDialog(BuildContext context, {FlashDeck? editing}) {
    final titleCtrl = TextEditingController(text: editing?.title ?? '');
    final descCtrl = TextEditingController(text: editing?.description ?? '');

    Get.dialog(
      AlertDialog(
        title: Text(editing == null ? 'new_deck'.tr : 'edit_deck'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: 'deck_title'.tr,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: descCtrl,
              decoration: InputDecoration(
                labelText: 'deck_desc'.tr,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          FilledButton(
            onPressed: () async {
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
            child: Text('save'.tr),
          ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (ctx, v, child) => Transform.scale(scale: v, child: child),
            child: Text('📚', style: TextStyle(fontSize: 64.sp)),
          ),
          SizedBox(height: 16.h),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (ctx, v, child) => Opacity(opacity: v, child: child),
            child: Text(
              'no_decks'.tr,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (ctx, v, child) => Opacity(opacity: v, child: child),
            child: Text(
              'no_decks_sub'.tr,
              style: TextStyle(fontSize: 13.sp, color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeckCard extends StatefulWidget {
  final FlashDeck deck;
  final DeckController controller;
  final ColorScheme cs;
  final int index;

  const _DeckCard({
    required this.deck,
    required this.controller,
    required this.cs,
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
      duration: const Duration(milliseconds: 200),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 60), () {
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
    final total = widget.controller.getTotalCount(widget.deck.id);
    final due = widget.controller.getDueCount(widget.deck.id);
    final progress = widget.controller.getProgress(widget.deck.id);
    final cs = widget.cs;

    final progressColor = progress >= 0.8
        ? const Color(0xFF2E7D32)
        : progress >= 0.4
            ? Colors.orange
            : cs.error;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Card(
          margin: EdgeInsets.only(bottom: 12.h),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
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
                        ),
                      ),
                      PopupMenuButton<String>(
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
                              leading: Icon(
                                Icons.delete_outline,
                                color: cs.error,
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
                  if (widget.deck.description.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      widget.deck.description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: cs.onSurfaceVariant,
                      ),
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
                  SizedBox(height: 8.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4.h,
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
    );
  }

  void _editDeck(BuildContext context, FlashDeck deck) {
    final titleCtrl = TextEditingController(text: deck.title);
    final descCtrl = TextEditingController(text: deck.description);
    Get.dialog(
      AlertDialog(
        title: Text('edit_deck'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(
                labelText: 'deck_title'.tr,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: descCtrl,
              decoration: InputDecoration(
                labelText: 'deck_desc'.tr,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          FilledButton(
            onPressed: () async {
              final t = titleCtrl.text.trim();
              if (t.isEmpty) return;
              await DeckController.to.updateDeck(
                deck,
                title: t,
                description: descCtrl.text.trim(),
              );
              Get.back();
            },
            child: Text('save'.tr),
          ),
        ],
      ),
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
        color: filled ? color.withValues(alpha: 0.15) : Colors.transparent,
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
