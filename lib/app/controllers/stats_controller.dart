import 'package:get/get.dart';

import 'package:flashcard_study/app/controllers/deck_controller.dart';
import 'package:flashcard_study/app/data/models/flash_deck.dart';
import 'package:flashcard_study/app/services/hive_service.dart';

class DeckStats {
  final FlashDeck deck;
  final int total;
  final int mastered;
  final int due;
  final double progress;

  const DeckStats({
    required this.deck,
    required this.total,
    required this.mastered,
    required this.due,
    required this.progress,
  });
}

class StatsController extends GetxController {
  static StatsController get to => Get.find();

  // Today stats
  final RxInt todayStudied = 0.obs;
  final RxDouble todayAccuracy = 0.0.obs;

  // Streak
  final RxInt currentStreak = 0.obs;
  final RxInt longestStreak = 0.obs;

  // Overall
  final RxInt totalDecks = 0.obs;
  final RxInt totalCards = 0.obs;
  final RxInt masteredCards = 0.obs;

  // Deck stats list
  final deckStats = <DeckStats>[].obs;

  // Weekly chart: last 7 days card count (index 0 = 6 days ago, index 6 = today)
  final weeklyData = <int>[0, 0, 0, 0, 0, 0, 0].obs;

  @override
  void onInit() {
    super.onInit();
    refresh();
  }

  @override
  Future<void> refresh() async {
    _computeStreak();
    _computeDeckStats();
    _computeWeeklyData();
  }

  void _computeStreak() {
    final dates = HiveService.to.getStudyDates();
    if (dates.isEmpty) {
      currentStreak.value = 0;
      longestStreak.value = 0;
      return;
    }

    final today = _dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    // Calculate current streak (consecutive days ending today or yesterday)
    int streak = 0;
    DateTime check = dates.last;
    if (check == today || check == yesterday) {
      streak = 1;
      for (int i = dates.length - 2; i >= 0; i--) {
        final expected = check.subtract(const Duration(days: 1));
        if (dates[i] == expected) {
          streak++;
          check = dates[i];
        } else {
          break;
        }
      }
    }
    currentStreak.value = streak;

    // Calculate longest streak
    int longest = 1;
    int current = 1;
    for (int i = 1; i < dates.length; i++) {
      final diff = dates[i].difference(dates[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    longestStreak.value = longest;
  }

  void _computeDeckStats() {
    final dc = Get.find<DeckController>();
    final decks = dc.decks;

    int totalC = 0;
    int masteredC = 0;
    final stats = <DeckStats>[];

    for (final deck in decks) {
      final cards = dc.getCards(deck.id);
      final mastered = cards.where((c) => c.isMastered).length;
      final due = cards.where((c) => c.isDue).length;
      final progress = cards.isEmpty ? 0.0 : mastered / cards.length;
      totalC += cards.length;
      masteredC += mastered;
      stats.add(DeckStats(
        deck: deck,
        total: cards.length,
        mastered: mastered,
        due: due,
        progress: progress,
      ));
    }

    totalDecks.value = decks.length;
    totalCards.value = totalC;
    masteredCards.value = masteredC;
    deckStats.assignAll(stats);
  }

  void _computeWeeklyData() {
    // We use FlashCard nextReview update pattern:
    // Cards studied today have their nextReview set to today+interval.
    // We track study dates from HiveService.
    final studyDates = HiveService.to.getStudyDates();
    final today = _dateOnly(DateTime.now());

    // Build a map of date -> studied count using FlashCard.repetitions changes
    // Since we don't store per-day card counts, we use study date presence
    // as a binary signal per deck session. For weekly bars, count sessions per day.
    final Map<DateTime, int> dateSessionCount = {};
    for (final d in studyDates) {
      dateSessionCount[d] = (dateSessionCount[d] ?? 0) + 1;
    }

    // For a more useful chart, count cards reviewed per day using nextReview dates.
    // Cards that were reviewed on day D have nextReview set to D+interval.
    // We approximate: if card's nextReview - interval = D, it was reviewed on D.
    final dc = Get.find<DeckController>();
    final Map<DateTime, int> reviewedPerDay = {};

    for (final deck in dc.decks) {
      for (final card in dc.getCards(deck.id)) {
        if (card.nextReview != null && card.repetitions > 0) {
          final reviewedOn = _dateOnly(
            card.nextReview!.subtract(Duration(days: card.interval)),
          );
          reviewedPerDay[reviewedOn] = (reviewedPerDay[reviewedOn] ?? 0) + 1;
        }
      }
    }

    // Fill last 7 days
    final weekly = <int>[];
    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      weekly.add(reviewedPerDay[day] ?? 0);
    }
    weeklyData.assignAll(weekly);

    // Today's studied count
    todayStudied.value = reviewedPerDay[today] ?? 0;
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
