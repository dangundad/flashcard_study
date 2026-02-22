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

class DeckPage extends StatefulWidget {
  const DeckPage({super.key});

  @override
  State<DeckPage> createState() => _DeckPageState();
}

class _DeckPageState extends State<DeckPage> {
  late final String deckId;
  final _cards = <FlashCard>[].obs;

  @override
  void initState() {
    super.initState();
    deckId = Get.arguments as String;
    _loadCards();
  }

  void _loadCards() {
    _cards.value = DeckController.to.getCards(deckId);
  }

  @override
  Widget build(BuildContext context) {
    final deck = DeckController.to.getDeck(deckId);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(deck?.title ?? 'deck'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showAddCardDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (_cards.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('📝', style: TextStyle(fontSize: 48.sp)),
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
                padding: EdgeInsets.all(16.r),
                children: [
                  _DeckStats(deckId: deckId),
                  SizedBox(height: 16.h),
                  Text(
                    'cards'.tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurfaceVariant,
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
      floatingActionButton: Obx(() {
        final due = DeckController.to.getDueCount(deckId);
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
    Get.find<StudyController>().startSession(deckId);
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
                await DeckController.to.addCard(
                  deckId: deckId,
                  front: f,
                  back: b,
                );
              } else {
                await DeckController.to.updateCard(editing, front: f, back: b);
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
              await DeckController.to.deleteCard(card);
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

  const _DeckStats({required this.deckId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final due = DeckController.to.getDueCount(deckId);
    final total = DeckController.to.getTotalCount(deckId);
    final progress = DeckController.to.getProgress(deckId);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
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
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.h,
              backgroundColor: cs.onPrimaryContainer.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(cs.onPrimaryContainer),
            ),
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
              color: color.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
