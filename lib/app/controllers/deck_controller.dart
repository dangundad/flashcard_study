import 'package:get/get.dart';

import 'package:flashcard_study/app/admob/ads_rewarded.dart';
import 'package:flashcard_study/app/data/deck_templates.dart';
import 'package:flashcard_study/app/data/models/flash_card.dart';
import 'package:flashcard_study/app/data/models/flash_deck.dart';
import 'package:flashcard_study/app/services/hive_service.dart';

class DeckController extends GetxController {
  static DeckController get to => Get.find();

  final decks = <FlashDeck>[].obs;
  final currentDeckId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDecks();
  }

  // ─── Deck operations ─────────────────────────────────
  void _loadDecks() {
    decks.value = HiveService.to.decksBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> createDeck({required String title, required String description}) async {
    final deck = FlashDeck(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
    await HiveService.to.decksBox.put(deck.id, deck);
    _loadDecks();
  }

  Future<void> updateDeck(FlashDeck deck, {required String title, required String description}) async {
    deck.title = title;
    deck.description = description;
    await deck.save();
    _loadDecks();
  }

  Future<void> deleteDeck(String deckId) async {
    // Delete all cards in deck
    final cardKeys = HiveService.to.cardsBox.values
        .where((c) => c.deckId == deckId)
        .map((c) => c.id)
        .toList();
    for (final key in cardKeys) {
      await HiveService.to.cardsBox.delete(key);
    }
    await HiveService.to.decksBox.delete(deckId);
    _loadDecks();
  }

  FlashDeck? getDeck(String deckId) =>
      HiveService.to.decksBox.get(deckId);

  // ─── Card operations ──────────────────────────────────
  List<FlashCard> getCards(String deckId) =>
      HiveService.to.cardsBox.values
          .where((c) => c.deckId == deckId)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  List<FlashCard> getDueCards(String deckId) =>
      getCards(deckId).where((c) => c.isDue).toList();

  Future<void> addCard({
    required String deckId,
    required String front,
    required String back,
  }) async {
    final card = FlashCard(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      deckId: deckId,
      front: front,
      back: back,
      createdAt: DateTime.now(),
    );
    await HiveService.to.cardsBox.put(card.id, card);
  }

  Future<void> updateCard(FlashCard card, {required String front, required String back}) async {
    card.front = front;
    card.back = back;
    await card.save();
  }

  Future<void> deleteCard(FlashCard card) async {
    await card.delete();
  }

  // ─── Stats ────────────────────────────────────────────
  double getProgress(String deckId) {
    final cards = getCards(deckId);
    if (cards.isEmpty) return 0;
    final mastered = cards.where((c) => c.isMastered).length;
    return mastered / cards.length;
  }

  int getDueCount(String deckId) => getDueCards(deckId).length;
  int getTotalCount(String deckId) => getCards(deckId).length;

  // ─── Template operations ──────────────────────────────────

  /// 보상형 광고 시청 후 템플릿 덱 추가
  void addTemplateWithAd(DeckTemplate template) {
    final adManager = Get.isRegistered<RewardedAdManager>()
        ? RewardedAdManager.to
        : null;
    if (adManager == null || !adManager.isAdReady.value) {
      Get.snackbar('get_item_ad'.tr, 'loading'.tr);
      return;
    }
    adManager.showAdIfAvailable(
      onUserEarnedReward: (_) => _installTemplate(template),
    );
  }

  Future<void> _installTemplate(DeckTemplate template) async {
    final deckId = DateTime.now().microsecondsSinceEpoch.toString();
    final deck = FlashDeck(
      id: deckId,
      title: template.titleKey.tr,
      description: template.descKey.tr,
      createdAt: DateTime.now(),
    );
    await HiveService.to.decksBox.put(deck.id, deck);

    int offset = 0;
    for (final entry in template.cards) {
      final card = FlashCard(
        id: '${deckId}_$offset',
        deckId: deckId,
        front: entry.front,
        back: entry.back,
        createdAt: DateTime.now().add(Duration(microseconds: offset)),
      );
      await HiveService.to.cardsBox.put(card.id, card);
      offset++;
    }
    _loadDecks();
    Get.snackbar('success'.tr, template.titleKey.tr);
  }
}
