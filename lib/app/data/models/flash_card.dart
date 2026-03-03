import 'package:hive_ce/hive_ce.dart';

part 'flash_card.g.dart';

@HiveType(typeId: 1)
class FlashCard extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String deckId;

  @HiveField(2)
  String front;

  @HiveField(3)
  String back;

  @HiveField(4)
  int interval; // days until next review

  @HiveField(5)
  double easeFactor; // SM-2 ease factor (starts at 2.5)

  @HiveField(6)
  int repetitions; // consecutive correct reviews

  @HiveField(7)
  DateTime? nextReview;

  @HiveField(8)
  DateTime createdAt;

  FlashCard({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.interval = 1,
    this.easeFactor = 2.5,
    this.repetitions = 0,
    this.nextReview,
    required this.createdAt,
  });

  /// Card is considered "due" if nextReview is null or <= now
  bool get isDue {
    if (nextReview == null) return true;
    return !nextReview!.isAfter(DateTime.now());
  }

  /// Card is "mastered" if interval >= 21 days and enough repetitions
  bool get isMastered => interval >= 21 && repetitions >= 3;

  /// Apply SM-2 algorithm: quality 0=Again, 1=Hard, 2=Good, 3=Easy
  ///
  /// Repetition steps (SM-2 inspired):
  ///   rep 0 (first review)  → Good/Easy: interval = 1 day
  ///   rep 1                 → Good/Easy: interval = 6 days
  ///   rep 2+                → interval × easeFactor
  ///
  /// "Hard" keeps the card in the learning phase (no rep advancement when
  /// the card has not yet been correctly learned once, i.e. repetitions == 0).
  void applyReview(int quality) {
    assert(quality >= 0 && quality <= 3);

    if (quality == 0) {
      // Again – full reset: restart the learning phase.
      repetitions = 0;
      interval = 1;
      easeFactor = (easeFactor - 0.2).clamp(1.3, 3.0);
    } else if (quality == 1) {
      // Hard – partial credit.
      // Only advance repetitions if the card has already been correctly
      // learned at least once so we do not artificially inflate the counter
      // for cards that were never properly recalled.
      if (repetitions > 0) {
        interval = (interval * 1.2).round().clamp(1, 365);
        repetitions++;
      }
      // When repetitions == 0 the interval stays at 1 so the card is shown
      // again tomorrow (same as "Again" but without the ease penalty).
      easeFactor = (easeFactor - 0.15).clamp(1.3, 3.0);
    } else if (quality == 2) {
      // Good
      if (repetitions == 0) {
        interval = 1;
      } else if (repetitions == 1) {
        interval = 6;
      } else {
        interval = (interval * easeFactor).round().clamp(1, 365);
      }
      repetitions++;
    } else {
      // Easy
      if (repetitions == 0) {
        interval = 4;
      } else if (repetitions == 1) {
        interval = 10;
      } else {
        interval = (interval * easeFactor + 2).round().clamp(1, 365);
      }
      easeFactor = (easeFactor + 0.15).clamp(1.3, 3.0);
      repetitions++;
    }

    nextReview = DateTime.now().add(Duration(days: interval));
    // Guard: the card may have been deleted while a study session was in
    // progress.  Calling save() on a deleted HiveObject throws, so we check
    // isInBox first.
    if (isInBox) save();
  }
}
