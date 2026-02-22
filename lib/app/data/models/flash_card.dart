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
    return DateTime.now().isAfter(nextReview!);
  }

  /// Card is "mastered" if interval >= 21 days and enough repetitions
  bool get isMastered => interval >= 21 && repetitions >= 3;

  /// Apply SM-2 algorithm: quality 0=Again, 1=Hard, 2=Good, 3=Easy
  void applyReview(int quality) {
    assert(quality >= 0 && quality <= 3);

    if (quality == 0) {
      // Again – reset
      repetitions = 0;
      interval = 1;
      easeFactor = (easeFactor - 0.2).clamp(1.3, 3.0);
    } else if (quality == 1) {
      // Hard
      interval = (interval * 1.2).round().clamp(1, 365);
      easeFactor = (easeFactor - 0.15).clamp(1.3, 3.0);
      repetitions++;
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
        interval = 1;
      } else if (repetitions == 1) {
        interval = 6;
      } else {
        interval = (interval * easeFactor + 2).round().clamp(1, 365);
      }
      easeFactor = (easeFactor + 0.15).clamp(1.3, 3.0);
      repetitions++;
    }

    nextReview = DateTime.now().add(Duration(days: interval));
    save();
  }
}
