import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

import 'package:flashcard_study/app/services/activity_log_service.dart';

class SettingController extends GetxController {
  static SettingController get to => Get.find<SettingController>();
  static const String appId = 'flashcard_study';

  static const String _kSettingBox = 'phase1_setting_core';
  static const String _kSoundKey = 'sound_enabled';
  static const String _kHapticKey = 'haptic_enabled';
  static const String _kAdsKey = 'ads_consent';
  static const String _kLanguageKey = 'language';
  static const String _kDarkModeKey = 'dark_mode';

  final RxBool soundEnabled = true.obs;
  final RxBool hapticEnabled = true.obs;
  final RxBool adsConsent = true.obs;
  final RxString language = 'en'.obs;
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<Box<dynamic>> _openSettingBox() async {
    if (Hive.isBoxOpen(_kSettingBox)) {
      return Hive.box(_kSettingBox);
    }
    return await Hive.openBox(_kSettingBox);
  }

  Future<void> _load() async {
    final box = await _openSettingBox();
    soundEnabled.value = _readBool(box, _kSoundKey, true);
    hapticEnabled.value = _readBool(box, _kHapticKey, true);
    adsConsent.value = _readBool(box, _kAdsKey, true);
    language.value = _readString(box, _kLanguageKey, 'en');
    isDarkMode.value = _readBool(box, _kDarkModeKey, false);
    Get.updateLocale(language.value == 'ko' ? const Locale('ko') : const Locale('en'));
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setSoundEnabled(bool value) async {
    final box = await _openSettingBox();
    await box.put(_kSoundKey, value);
    soundEnabled.value = value;
  }

  Future<void> setHapticEnabled(bool value) async {
    final box = await _openSettingBox();
    await box.put(_kHapticKey, value);
    hapticEnabled.value = value;
  }

  Future<void> setAdsConsent(bool value) async {
    final box = await _openSettingBox();
    await box.put(_kAdsKey, value);
    adsConsent.value = value;
  }

  Future<void> setLanguage(String value) async {
    final box = await _openSettingBox();
    await box.put(_kLanguageKey, value);
    language.value = value;
    Get.updateLocale(value == 'ko' ? const Locale('ko') : const Locale('en'));
  }

  Future<void> toggleDarkMode() async {
    final newValue = !isDarkMode.value;
    final box = await _openSettingBox();
    await box.put(_kDarkModeKey, newValue);
    isDarkMode.value = newValue;
    Get.changeThemeMode(newValue ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> clearAppSettings() async {
    final box = await _openSettingBox();
    await box.clear();
    soundEnabled.value = true;
    hapticEnabled.value = true;
    adsConsent.value = true;
    language.value = 'en';
    isDarkMode.value = false;
    Get.updateLocale(const Locale('en'));
    Get.changeThemeMode(ThemeMode.light);
  }

  void logEvent(
    String eventName,
    String screen, {
    Map<String, dynamic> metadata = const {},
  }) {
    if (!Get.isRegistered<ActivityLogService>()) {
      return;
    }
    unawaited(
      ActivityLogService.to.logEvent(
        appId: appId,
        eventName: eventName,
        screen: screen,
        route: Get.currentRoute,
        metadata: metadata,
      ),
    );
  }

  bool _readBool(Box box, String key, bool fallback) {
    final value = box.get(key, defaultValue: fallback);
    return value is bool ? value : fallback;
  }

  String _readString(Box box, String key, String fallback) {
    final value = box.get(key, defaultValue: fallback);
    return value is String ? value : fallback;
  }
}
