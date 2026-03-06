# Flashcard Study - TODO

## 구현 완료 기능
- [x] 덱(Deck) 생성/수정/삭제 (FlashDeck HiveType)
- [x] 카드(Card) 생성/수정/삭제 (FlashCard HiveType)
- [x] 3D 플립 카드 애니메이션
- [x] SM-2 간격 반복 알고리즘 (Again/Hard/Good/Easy)
- [x] 복습 대상 카드 자동 필터링 (isDue)
- [x] 마스터 판정 (interval >= 21일 && repetitions >= 3)
- [x] easeFactor 조정 (1.3 ~ 3.0 범위)
- [x] 학습 세션 진행 (셔플, 진행률)
- [x] 세션 완료 시 정확도 표시
- [x] 복습 대상 없을 때 전체 카드 폴백
- [x] 기본 덱 템플릿 제공
- [x] 학습 세션 기록 저장
- [x] 삭제된 카드 안전 처리 (isInBox 체크)
- [x] Confetti 애니메이션
- [x] 진동 피드백 (플립, 평가)
- [x] 배너/전면/보상형 광고 통합
- [x] 학습 통계 차트 (fl_chart)
- [x] 설정 (햅틱, 사운드)
- [x] 다국어 번역 (ko)
- [x] FlexColorScheme 테마
- [x] Firebase Analytics/Crashlytics
- [x] 인앱 구매 서비스
- [x] 앱 평가 서비스

## 출시 전 남은 작업
- [ ] 앱 아이콘 디자인 및 적용 (`dart run flutter_launcher_icons`)
- [ ] 스플래시 화면 디자인 및 적용 (`dart run flutter_native_splash:create`)
- [ ] Google Play Console 앱 등록
- [ ] Apple App Store Connect 앱 등록
- [ ] AdMob 광고 단위 ID 실제 값으로 교체
- [ ] Firebase 프로젝트 연동 (google-services.json / GoogleService-Info.plist)
- [ ] 개인정보처리방침 URL 생성
- [ ] 스토어 스크린샷 및 그래픽 이미지 제작
- [ ] 릴리스 빌드 테스트
- [ ] 실기기 테스트 (다양한 해상도)
- [ ] 덱/카드 대량 데이터 성능 테스트
- [ ] ProGuard 규칙 확인
