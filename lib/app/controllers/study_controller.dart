import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:flashcard_study/app/admob/ads_interstitial.dart';
import 'package:flashcard_study/app/controllers/deck_controller.dart';
import 'package:flashcard_study/app/data/models/flash_card.dart';
import 'package:flashcard_study/app/services/hive_service.dart';

class StudyController extends GetxController {
  static StudyController get to => Get.find();

  final cards = <FlashCard>[].obs;
  final currentIndex = 0.obs;
  final isFlipped = false.obs;
  final sessionCorrect = 0.obs;
  final sessionTotal = 0.obs;
  final isDone = false.obs;
  final showConfetti = false.obs;

  String _deckId = '';

  void startSession(String deckId) {
    _deckId = deckId;
    final due = DeckController.to.getDueCards(deckId);
    due.shuffle();
    cards.value = due;
    currentIndex.value = 0;
    isFlipped.value = false;
    sessionCorrect.value = 0;
    sessionTotal.value = 0;
    isDone.value = false;
    showConfetti.value = false;
  }

  FlashCard? get currentCard {
    if (cards.isEmpty || currentIndex.value >= cards.length) return null;
    return cards[currentIndex.value];
  }

  int get remaining => cards.length - currentIndex.value;

  void flip() {
    HapticFeedback.selectionClick();
    isFlipped.value = !isFlipped.value;
  }

  /// quality: 0=Again, 1=Hard, 2=Good, 3=Easy
  void rateCard(int quality) {
    final card = currentCard;
    if (card == null) return;

    if (quality >= 2) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.selectionClick();
    }

    card.applyReview(quality);
    sessionTotal.value++;
    if (quality >= 2) sessionCorrect.value++;

    isFlipped.value = false;

    final next = currentIndex.value + 1;
    if (next >= cards.length) {
      HapticFeedback.mediumImpact();
      isDone.value = true;
      showConfetti.value = true;
      HiveService.to.recordStudySession();
      InterstitialAdManager.to.showAdIfAvailable();
    } else {
      currentIndex.value = next;
    }
  }

  void restartSession() => startSession(_deckId);

  double get accuracy {
    if (sessionTotal.value == 0) return 0;
    return sessionCorrect.value / sessionTotal.value;
  }
}
