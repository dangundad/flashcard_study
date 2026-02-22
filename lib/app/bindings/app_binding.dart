import 'package:get/get.dart';

import 'package:flashcard_study/app/controllers/deck_controller.dart';
import 'package:flashcard_study/app/controllers/setting_controller.dart';
import 'package:flashcard_study/app/controllers/study_controller.dart';
import 'package:flashcard_study/app/services/hive_service.dart';

class AppBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HiveService>()) {
      Get.put(HiveService(), permanent: true);
    }

    if (!Get.isRegistered<SettingController>()) {
      Get.put(SettingController(), permanent: true);
    }

    if (!Get.isRegistered<DeckController>()) {
      Get.put(DeckController(), permanent: true);
    }

    if (!Get.isRegistered<StudyController>()) {
      Get.put(StudyController(), permanent: true);
    }
  }
}
