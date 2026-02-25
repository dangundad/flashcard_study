import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:flashcard_study/app/admob/ads_banner.dart';
import 'package:flashcard_study/app/admob/ads_helper.dart';
import 'package:flashcard_study/app/controllers/deck_controller.dart';
import 'package:flashcard_study/app/controllers/study_controller.dart';
import 'package:flashcard_study/app/data/models/flash_card.dart';
import 'package:flashcard_study/app/pages/deck/widgets/card_item.dart';
import 'package:flashcard_study/app/routes/app_pages.dart';

class DeckPage extends GetView<DeckController> {
  const DeckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _DeckPageContent(controller: controller);
  }
}

class _DeckPageContent extends StatefulWidget {
  final DeckController controller;

  const _DeckPageContent({required this.controller});

  @override
  State<_DeckPageContent> createState() => _DeckPageState();
}

class _DeckPageState extends State<_DeckPageContent> {
  late final String deckId;
  final _cards = <FlashCard>[].obs;

  @override
  void initState() {
    super.initState();
    deckId = Get.arguments as String;
    _loadCards();
  }

  void _loadCards() {
    _cards.value = widget.controller.getCards(deckId);
  }

  @override
  Widget build(BuildContext context) {
    final deck = widget.controller.getDeck(deckId);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(deck?.title ?? 'deck'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showAddCardDialog,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.surface, cs.primary.withValues(alpha: 0.06), cs.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (_cards.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('?뱷', style: TextStyle(fontSize: 48.sp)),
                        SizedBox(height: 12.h),
                        Text(
                          'no_cards'.tr,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        TextButton.icon(
                          onPressed: _showAddCardDialog,
                          icon: const Icon(Icons.add_rounded),
                          label: Text('add_card'.tr),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 24.h),
                  children: [
                    _DeckStats(
                      deckId: deckId,
                      controller: widget.controller,
                    ),
                    SizedBox(height: 14.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        'cards'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ..._cards.map(
                      (card) => CardItem(
                        card: card,
                        onEdit: () => _showEditCardDialog(card),
                        onDelete: () => _deleteCard(card),
                      ),
                    ),
                  ],
                );
              }),
            ),
            BannerAdWidget(
              adUnitId: AdHelper.bannerAdUnitId,
              type: AdHelper.banner,
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        final due = widget.controller.getDueCount(deckId);
        if (due == 0 || _cards.isEmpty) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: _startStudy,
          icon: const Icon(Icons.school_rounded),
          label: Text('study_due'.trParams({'n': '$due'})),
        );
      }),
    );
  }

  void _startStudy() {
    StudyController.to.startSession(deckId);
    Get.toNamed(Routes.STUDY);
  }

  void _showAddCardDialog({FlashCard? editing}) {
    final frontCtrl = TextEditingController(text: editing?.front ?? '');
    final backCtrl = TextEditingController(text: editing?.back ?? '');

    Get.dialog(
      AlertDialog(
        title: Text(editing == null ? 'add_card'.tr : 'edit_card'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: frontCtrl,
              decoration: InputDecoration(
                labelText: 'front'.tr,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
              autofocus: true,
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: backCtrl,
              decoration: InputDecoration(
                labelText: 'back'.tr,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
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
              final f = frontCtrl.text.trim();
              final b = backCtrl.text.trim();
              if (f.isEmpty || b.isEmpty) return;
              if (editing == null) {
                await widget.controller.addCard(
                  deckId: deckId,
                  front: f,
                  back: b,
                );
              } else {
                await widget.controller.updateCard(editing, front: f, back: b);
              }
              _loadCards();
              Get.back();
            },
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }

  void _showEditCardDialog(FlashCard card) => _showAddCardDialog(editing: card);

  void _deleteCard(FlashCard card) {
    Get.dialog(
      AlertDialog(
        title: Text('delete_card'.tr),
        content: Text('delete_card_confirm'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          FilledButton(
            onPressed: () async {
              await widget.controller.deleteCard(card);
              _loadCards();
              Get.back();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }
}

class _DeckStats extends StatelessWidget {
  final String deckId;
  final DeckController controller;

  const _DeckStats({
    required this.deckId,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final due = controller.getDueCount(deckId);
    final total = controller.getTotalCount(deckId);
    final progress = controller.getProgress(deckId);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          _Stat(
            label: 'total_cards'.tr,
            value: '$total',
            color: cs.onPrimaryContainer,
          ),
          _Stat(
            label: 'due_today'.tr,
            value: '$due',
            color: due > 0 ? cs.primary : cs.onPrimaryContainer,
          ),
          _Stat(
            label: 'mastered'.tr,
            value: '${(progress * 100).round()}%',
            color: cs.onPrimaryContainer,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: color.withValues(alpha: 0.75),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
