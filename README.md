# Flashcard Study

플래시카드 학습 앱 - SM-2 간격 반복 알고리즘으로 효율적인 암기 학습을 지원합니다.

## 주요 기능
- 덱(Deck) 기반 카드 관리 (생성/수정/삭제)
- 3D 플립 애니메이션 카드
- SM-2 간격 반복 알고리즘 (Again/Hard/Good/Easy)
- 복습 대상 카드 자동 필터링
- 학습 세션 진행률 및 정확도
- 기본 덱 템플릿 제공
- 학습 통계 (fl_chart)
- 마스터 판정 (21일+ interval, 3회+ 연속 정답)
- AdMob 광고 (배너/전면/보상형)

## 기술 스택
- **Framework**: Flutter 3.x / Dart 3.8+
- **State Management**: GetX
- **Local Storage**: Hive_CE (@HiveType: FlashDeck, FlashCard)
- **UI**: flutter_screenutil, flex_color_scheme, google_fonts
- **Chart**: fl_chart
- **Ads**: google_mobile_ads + AppLovin/Pangle/Unity Mediation
- **Analytics**: Firebase Analytics & Crashlytics

## 설치 및 실행
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

## 프로젝트 구조
```
lib/
├── main.dart
├── hive_registrar.g.dart
├── app/
│   ├── admob/          # 광고 관리
│   ├── bindings/       # GetX 바인딩
│   ├── controllers/    # 덱/학습/설정/통계 컨트롤러
│   ├── data/
│   │   ├── models/     # FlashDeck, FlashCard (Hive 모델)
│   │   └── deck_templates.dart
│   ├── pages/          # 화면별 위젯
│   ├── routes/         # 라우팅
│   ├── services/       # Hive, 구매, 평가 서비스
│   ├── theme/          # FlexColorScheme 테마
│   ├── translate/      # 다국어 번역
│   ├── utils/          # 상수
│   └── widgets/        # 공용 위젯
```

## 라이선스
Copyright (c) 2026 DangunDad. All rights reserved.
