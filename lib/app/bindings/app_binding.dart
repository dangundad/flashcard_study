import 'package:hive_ce/hive.dart';
import 'package:get/get.dart';

import 'package:flashcard_study/app/admob/ads_interstitial.dart';
import 'package:flashcard_study/app/admob/ads_rewarded.dart';
import 'package:flashcard_study/app/controllers/deck_controller.dart';
import 'package:flashcard_study/app/controllers/setting_controller.dart';
import 'package:flashcard_study/app/controllers/study_controller.dart';
import 'package:flashcard_study/app/services/activity_log_service.dart';
import 'package:flashcard_study/app/services/hive_service.dart';
import 'package:flashcard_study/app/controllers/history_controller.dart';
import 'package:flashcard_study/app/controllers/stats_controller.dart';

import 'package:flashcard_study/app/services/purchase_service.dart';
import 'package:flashcard_study/app/services/app_rating_service.dart';
import 'package:flashcard_study/app/controllers/premium_controller.dart';

class AppBinding implements Bindings {
  static Future<void> initializeServices() async {
    if (!Get.isRegistered<HiveService>()) {
      await HiveService.init();
      Get.put(HiveService(), permanent: true);
    } else {
      try {
        if (!Hive.isBoxOpen('settings')) {
          await Hive.openBox('settings');
        }
        if (!Hive.isBoxOpen('app_data')) {
          await Hive.openBox('app_data');
        }
        if (!Hive.isBoxOpen('decks')) {
          await Hive.openBox('decks');
        }
        if (!Hive.isBoxOpen('cards')) {
          await Hive.openBox('cards');
        }
      } catch (e) {
        Get.log('[AppBinding] Hive reopen failed: $e');
      }
    }

    _ensureDependencyServices();
  }

  @override
  void dependencies() {
    if (!Get.isRegistered<PurchaseService>()) {
      Get.put(PurchaseService(), permanent: true);
    }

    if (!Get.isRegistered<PremiumController>()) {
      Get.lazyPut(() => PremiumController());
    }

    _ensureDependencyServices();
  }

  static void _ensureDependencyServices() {
    if (!Get.isRegistered<SettingController>()) {
      Get.put(SettingController(), permanent: true);
    }

    if (!Get.isRegistered<DeckController>()) {
      Get.put(DeckController(), permanent: true);
    }

    if (!Get.isRegistered<StudyController>()) {
      Get.put(StudyController(), permanent: true);
    }

    if (!Get.isRegistered<ActivityLogService>()) {
      Get.put(ActivityLogService(), permanent: true);
    }

    if (!Get.isRegistered<HistoryController>()) {
      Get.lazyPut(() => HistoryController());
    }

    if (!Get.isRegistered<StatsController>()) {
      Get.lazyPut(() => StatsController());
    }

    if (!Get.isRegistered<InterstitialAdManager>()) {
      Get.put(InterstitialAdManager(), permanent: true);
    }

    if (!Get.isRegistered<RewardedAdManager>()) {
      Get.put(RewardedAdManager(), permanent: true);
    }

    if (!Get.isRegistered<AppRatingService>()) {
      Get.put(AppRatingService(), permanent: true);
    }
  }
}
