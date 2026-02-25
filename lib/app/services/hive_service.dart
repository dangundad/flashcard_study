// ================================================
// DangunDad Flutter App - hive_service.dart Template
// ================================================
// flashcard_study 치환 후 사용
// mbti_pro 프로덕션 패턴 기반

// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:flashcard_study/app/data/models/flash_card.dart';
import 'package:flashcard_study/app/data/models/flash_deck.dart';
import 'package:flashcard_study/hive_registrar.g.dart';


class HiveService extends GetxService {
  static HiveService get to => Get.find();

  // Box 이름 상수
  static const String SETTINGS_BOX = 'settings';
  static const String APP_DATA_BOX = 'app_data';
  static const String DECKS_BOX = 'decks';
  static const String CARDS_BOX = 'cards';

  // Box Getters
  Box get settingsBox => Hive.box(SETTINGS_BOX);
  Box get appDataBox => Hive.box(APP_DATA_BOX);
  Box<FlashDeck> get decksBox => Hive.box<FlashDeck>(DECKS_BOX);
  Box<FlashCard> get cardsBox => Hive.box<FlashCard>(CARDS_BOX);

  /// Hive 초기화 (main.dart에서 await 호출)
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapters();

    await Future.wait([
      Hive.openBox(SETTINGS_BOX),
      Hive.openBox(APP_DATA_BOX),
      Hive.openBox<FlashDeck>(DECKS_BOX),
      Hive.openBox<FlashCard>(CARDS_BOX),
    ]);

    Get.log('Hive 초기화 완료');
  }

  // ============================================
  // 설정 관리 (generic key-value)
  // ============================================

  T? getSetting<T>(String key, {T? defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  Future<void> setSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  // ============================================
  // 앱 데이터 관리 (generic key-value)
  // ============================================

  T? getAppData<T>(String key, {T? defaultValue}) {
    return appDataBox.get(key, defaultValue: defaultValue) as T?;
  }

  Future<void> setAppData(String key, dynamic value) async {
    await appDataBox.put(key, value);
  }

  // ============================================
  // 앱별 데이터 CRUD 추가
  // ============================================
  // 캐싱 패턴 예시:
  //
  // List<MyModel>? _cache;
  //
  // void _invalidateCache() { _cache = null; }
  //
  // List<MyModel> getAllItems({bool forceRefresh = false}) {
  //   if (!forceRefresh && _cache != null) return List.from(_cache!);
  //   final items = myModelBox.values.toList();
  //   _cache = items;
  //   return List.from(items);
  // }
  //
  // Future<void> addItem(MyModel item) async {
  //   await myModelBox.put(item.id, item);
  //   _invalidateCache();
  // }

  // ============================================
  // 학습 세션 날짜 기록 (streak 계산용)
  // ============================================
  static const String _studyDatesKey = 'study_session_dates';

  /// 오늘 학습 세션 날짜를 기록
  Future<void> recordStudySession() async {
    final today = _dateOnly(DateTime.now());
    final raw = appDataBox.get(_studyDatesKey);
    final List<String> dates = raw is List
        ? List<String>.from(raw.map((e) => e.toString()))
        : <String>[];
    final todayStr = today.toIso8601String();
    if (!dates.contains(todayStr)) {
      dates.add(todayStr);
      // Keep only last 365 days
      if (dates.length > 365) {
        dates.removeAt(0);
      }
      await appDataBox.put(_studyDatesKey, dates);
    }
  }

  /// 학습 날짜 목록 반환 (정렬됨)
  List<DateTime> getStudyDates() {
    final raw = appDataBox.get(_studyDatesKey);
    if (raw == null || raw is! List) return [];
    return raw
        .map((e) => DateTime.tryParse(e.toString()))
        .whereType<DateTime>()
        .toList()
      ..sort();
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  // ============================================
  // 데이터 관리
  // ============================================

  Future<void> clearAllData() async {
    await Future.wait([
      settingsBox.clear(),
      appDataBox.clear(),
    ]);
    Get.log('모든 데이터 삭제 완료');
  }
}
