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
    refreshStats();
  }

  Future<void> refreshStats() async {
    _computeStreak();
    _computeDeckStats();
    _computeWeeklyData();
  }

  void _computeStreak() {
    final rawDates = HiveService.to.getStudyDates();
    if (rawDates.isEmpty) {
      currentStreak.value = 0;
      longestStreak.value = 0;
      return;
    }

    // Deduplicate dates (same day may be recorded multiple times)
    final dates = rawDates.map(_dateOnly).toSet().toList()..sort();

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
      } else if (diff > 1) {
        current = 1;
      }
      // diff == 0 means duplicate date (should not happen after dedup, but safe guard)
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
      int mastered = 0;
      int due = 0;
      for (final c in cards) {
        if (c.isMastered) mastered++;
        if (c.isDue) due++;
      }
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
    // Use actual recorded daily study counts when available,
    // falling back to the card-state estimate for historical data.
    final stored = HiveService.to.getDailyStudyCounts(7);
    final hasStoredData = stored.any((c) => c > 0);

    if (hasStoredData) {
      weeklyData.assignAll(stored);
      todayStudied.value = stored.last;
    } else {
      // Fallback: estimate from card state (legacy data before tracking)
      final today = _dateOnly(DateTime.now());
      final dc = Get.find<DeckController>();
      final Map<DateTime, int> reviewedPerDay = {};

      for (final deck in dc.decks) {
        for (final card in dc.getCards(deck.id)) {
          if (card.nextReview != null) {
            final reviewedOn = _dateOnly(
              card.nextReview!.subtract(Duration(days: card.interval)),
            );
            reviewedPerDay[reviewedOn] =
                (reviewedPerDay[reviewedOn] ?? 0) + 1;
          }
        }
      }

      final weekly = <int>[];
      for (int i = 6; i >= 0; i--) {
        final day = today.subtract(Duration(days: i));
        weekly.add(reviewedPerDay[day] ?? 0);
      }
      weeklyData.assignAll(weekly);
      todayStudied.value = reviewedPerDay[today] ?? 0;
    }
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
