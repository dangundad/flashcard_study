# CLAUDE.md - Flashcard Study

## 프로젝트 개요
플래시카드 학습 앱. 덱 기반 카드 생성, 3D 플립 애니메이션, SM-2 간격 반복 알고리즘을 활용한 효율적 암기 도구.
- **패키지명**: `com.dangundad.flashcardstudy`
- **퍼블리셔**: DangunDad
- **수익 모델**: 완전 무료 + AdMob 광고 (배너 + 전면 + 보상형)

## 기술 스택
- **Flutter** 3.x / Dart 3.8+
- **상태 관리**: GetX (`GetxController`, `.obs`, `Obx()`)
- **로컬 저장**: Hive_CE (`@HiveType` 어댑터 - FlashDeck, FlashCard)
- **UI**: flutter_screenutil, flex_color_scheme (FlexScheme.purpleM3), google_fonts, lucide_icons_flutter
- **차트**: fl_chart (학습 통계)
- **광고**: google_mobile_ads + AppLovin/Pangle/Unity 미디에이션
- **기타**: vibration, flutter_animate, firebase_core/analytics/crashlytics, in_app_purchase, in_app_review

## 개발 명령어
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

## 아키텍처 (프로젝트 구조)
```
lib/
├── main.dart                          # 앱 진입점
├── hive_registrar.g.dart              # Hive 어댑터 등록
├── app/
│   ├── admob/                         # 광고 (배너/전면/보상형)
│   ├── bindings/app_binding.dart      # GetX 바인딩
│   ├── controllers/
│   │   ├── deck_controller.dart       # 덱/카드 CRUD 관리
│   │   ├── study_controller.dart      # 학습 세션 진행
│   │   ├── history_controller.dart    # 기록 관리
│   │   ├── home_controller.dart       # 홈 화면
│   │   ├── premium_controller.dart    # 프리미엄
│   │   ├── setting_controller.dart    # 설정
│   │   └── stats_controller.dart      # 통계
│   ├── data/
│   │   ├── deck_templates.dart        # 기본 덱 템플릿 데이터
│   │   └── models/
│   │       ├── flash_card.dart        # 카드 모델 (SM-2 로직 포함)
│   │       ├── flash_card.g.dart
│   │       ├── flash_deck.dart        # 덱 모델
│   │       └── flash_deck.g.dart
│   ├── pages/
│   │   ├── deck/
│   │   │   ├── deck_page.dart         # 덱 상세 (카드 목록)
│   │   │   └── widgets/card_item.dart # 카드 아이템 위젯
│   │   ├── study/
│   │   │   ├── study_page.dart        # 학습 화면
│   │   │   └── widgets/flip_card_widget.dart # 3D 플립 카드
│   │   ├── history/history_page.dart
│   │   ├── home/home_page.dart
│   │   ├── premium/
│   │   ├── settings/settings_page.dart
│   │   └── stats/stats_page.dart
│   ├── routes/
│   ├── services/
│   │   ├── activity_log_service.dart
│   │   ├── app_rating_service.dart
│   │   ├── hive_service.dart          # Hive 서비스 (덱/카드 박스, 학습 세션 기록)
│   │   └── purchase_service.dart
│   ├── theme/app_flex_theme.dart
│   ├── translate/translate.dart
│   ├── utils/app_constants.dart
│   └── widgets/confetti_overlay.dart
```

## 데이터 모델
### FlashDeck (HiveType, typeId: 0)
| 필드 | 타입 | 설명 |
|------|------|------|
| id | String | 덱 고유 ID |
| title | String | 덱 제목 |
| description | String | 덱 설명 |
| createdAt | DateTime | 생성일 |

### FlashCard (HiveType, typeId: 1)
| 필드 | 타입 | 설명 |
|------|------|------|
| id | String | 카드 고유 ID |
| deckId | String | 소속 덱 ID |
| front | String | 앞면 텍스트 |
| back | String | 뒷면 텍스트 |
| interval | int | 다음 복습까지 일수 |
| easeFactor | double | SM-2 난이도 계수 (기본 2.5) |
| repetitions | int | 연속 정답 횟수 |
| nextReview | DateTime? | 다음 복습 예정일 |
| createdAt | DateTime | 생성일 |

## SM-2 간격 반복 알고리즘
카드 평가 시 quality (0~3):
- **0 (Again)**: 완전 초기화, interval=1, easeFactor -0.2
- **1 (Hard)**: 부분 점수, repetitions>0이면 interval x1.2
- **2 (Good)**: rep0=1일, rep1=6일, rep2+=interval x easeFactor
- **3 (Easy)**: rep0=4일, rep1=10일, rep2+=interval x easeFactor + 2, easeFactor +0.15
- isDue: nextReview가 null이거나 현재 시각 이전이면 복습 대상
- isMastered: interval >= 21일 && repetitions >= 3

## 개발 가이드라인
- 카드 삭제 중 학습 진행 시 `isInBox` 체크 후 `save()` 호출
- 학습 세션 완료 시 `HiveService.to.recordStudySession()` 호출
- 복습 대상 카드가 없으면 전체 카드로 폴백하여 재학습 가능
- 덱 템플릿: `deck_templates.dart`에 기본 샘플 덱 데이터 정의
