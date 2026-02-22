import 'package:hive_ce/hive_ce.dart';

part 'flash_deck.g.dart';

@HiveType(typeId: 0)
class FlashDeck extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime createdAt;

  FlashDeck({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });
}
