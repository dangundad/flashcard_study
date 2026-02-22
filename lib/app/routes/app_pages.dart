// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

import 'package:flashcard_study/app/bindings/app_binding.dart';
import 'package:flashcard_study/app/controllers/study_controller.dart';
import 'package:flashcard_study/app/pages/deck/deck_page.dart';
import 'package:flashcard_study/app/pages/home/home_page.dart';
import 'package:flashcard_study/app/pages/study/study_page.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomePage(),
      binding: AppBinding(),
    ),
    GetPage(
      name: _Paths.DECK,
      page: () => const DeckPage(),
    ),
    GetPage(
      name: _Paths.STUDY,
      page: () => const StudyPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<StudyController>()) {
          Get.put(StudyController(), permanent: true);
        }
      }),
    ),
  ];
}
