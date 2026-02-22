// ================================================
// DangunDad Flutter App - app_pages.dart Template
// ================================================
// flashcard_study 치환 후 사용
// mbti_pro 프로덕션 패턴 기반 (part 패턴)

// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

import 'package:flashcard_study/app/bindings/app_binding.dart';
import 'package:flashcard_study/app/pages/home/home_page.dart';
// import 'package:flashcard_study/app/pages/settings/settings_page.dart';

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
    // GetPage(
    //   name: _Paths.SETTINGS,
    //   page: () => const SettingsPage(),
    //   binding: BindingsBuilder(() {
    //     Get.lazyPut(() => SettingController());
    //   }),
    // ),
    // ---- 앱별 페이지 추가 ----
  ];
}
