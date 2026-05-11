// ignore_for_file: must_call_super

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:flashcard_study/app/admob/ads_interstitial.dart';
import 'package:flashcard_study/app/controllers/deck_controller.dart';
import 'package:flashcard_study/app/controllers/setting_controller.dart';
import 'package:flashcard_study/app/controllers/study_controller.dart';
import 'package:flashcard_study/app/data/models/flash_card.dart';
import 'package:flashcard_study/app/services/hive_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const vibrationChannel = MethodChannel('vibration');

  setUp(() {
    Get.testMode = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(vibrationChannel, (call) async {
          if (call.method == 'hasVibrator') {
            return false;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(vibrationChannel, null);
    Get.reset();
  });

  test('session completion waits for study stats persistence', () async {
    final hive = _BlockingHiveService();
    Get.put<HiveService>(hive);
    Get.put<SettingController>(_FakeSettingController()).hapticEnabled.value =
        false;
    Get.put<DeckController>(_FakeDeckController([_card()]));
    Get.put<InterstitialAdManager>(_FakeInterstitialAdManager());

    final controller = Get.put(StudyController());
    controller.startSession('deck-1');

    final rating = Future<void>.sync(() => controller.rateCard(2));

    expect(hive.studySessionStarted, isTrue);
    expect(hive.dailyCountStarted, isTrue);
    expect(hive.studySessionCompleted, isFalse);
    expect(hive.dailyCountCompleted, isFalse);
    expect(controller.isDone.value, isFalse);

    hive.completeWrites();
    await rating;

    expect(controller.isDone.value, isTrue);

    controller.onClose();
  });

  test(
    'session completion does not require an interstitial ad manager',
    () async {
      Get.put<HiveService>(_FakeHiveService());
      Get.put<SettingController>(_FakeSettingController()).hapticEnabled.value =
          false;
      Get.put<DeckController>(_FakeDeckController([_card()]));

      final controller = Get.put(StudyController());
      controller.startSession('deck-1');

      await Future<void>.sync(() => controller.rateCard(2));

      expect(controller.isDone.value, isTrue);

      controller.onClose();
    },
  );
}

FlashCard _card() {
  return FlashCard(
    id: 'card-1',
    deckId: 'deck-1',
    front: '2 + 2',
    back: '4',
    createdAt: DateTime(2026),
  );
}

class _FakeHiveService extends HiveService {
  bool studySessionRecorded = false;
  int dailyCount = 0;

  @override
  Future<void> recordStudySession() async {
    studySessionRecorded = true;
  }

  @override
  Future<void> addDailyStudyCount(int count) async {
    dailyCount += count;
  }
}

class _BlockingHiveService extends _FakeHiveService {
  final Completer<void> _studySessionCompleter = Completer<void>();
  final Completer<void> _dailyCountCompleter = Completer<void>();

  bool studySessionStarted = false;
  bool studySessionCompleted = false;
  bool dailyCountStarted = false;
  bool dailyCountCompleted = false;

  @override
  Future<void> recordStudySession() async {
    studySessionStarted = true;
    await _studySessionCompleter.future;
    await super.recordStudySession();
    studySessionCompleted = true;
  }

  @override
  Future<void> addDailyStudyCount(int count) async {
    dailyCountStarted = true;
    await _dailyCountCompleter.future;
    await super.addDailyStudyCount(count);
    dailyCountCompleted = true;
  }

  void completeWrites() {
    if (!_studySessionCompleter.isCompleted) {
      _studySessionCompleter.complete();
    }
    if (!_dailyCountCompleter.isCompleted) {
      _dailyCountCompleter.complete();
    }
  }
}

class _FakeDeckController extends DeckController {
  _FakeDeckController(this._cards);

  final List<FlashCard> _cards;

  @override
  void onInit() {}

  @override
  List<FlashCard> getDueCards(String deckId) => List<FlashCard>.from(_cards);

  @override
  List<FlashCard> getCards(String deckId) => List<FlashCard>.from(_cards);
}

class _FakeSettingController extends SettingController {
  @override
  void onInit() {}
}

class _FakeInterstitialAdManager extends InterstitialAdManager {
  @override
  void onInit() {}

  @override
  void showAdIfAvailable() {}
}
