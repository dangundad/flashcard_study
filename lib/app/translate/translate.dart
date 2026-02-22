// ================================================
// DangunDad Flutter App - translate.dart Template
// ================================================
// mbti_pro 프로덕션 패턴 기반
// 개발 시 한국어(ko)만 정의, 다국어는 추후 추가

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Languages extends Translations {
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ko'),
  ];

  @override
  Map<String, Map<String, String>> get keys => {
    'en': {
      // Common
      'settings': 'Settings',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'share': 'Share',
      'reset': 'Reset',
      'done': 'Done',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'error': 'Error',
      'success': 'Success',
      'loading': 'Loading...',
      'no_data': 'No data',

      // Settings
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'about': 'About',
      'version': 'Version',
      'rate_app': 'Rate App',
      'privacy_policy': 'Privacy Policy',
      'remove_ads': 'Remove Ads',

      // Feedback
      'send_feedback': 'Send Feedback',
      'more_apps': 'More Apps',

      // App-specific
      'app_name': 'Flashcard Study',
      'no_decks': 'No decks yet',
      'no_decks_sub': 'Create a deck to start studying!',
      'new_deck': 'New Deck',
      'edit_deck': 'Edit Deck',
      'delete_deck': 'Delete Deck',
      'delete_deck_confirm': 'Delete "{title}" and all its cards?',
      'deck_title': 'Deck Title',
      'deck_desc': 'Description (optional)',
      'deck': 'Deck',
      'cards': 'cards',
      'due': 'due',
      'due_today': 'Due Today',
      'total_cards': 'Total',
      'mastered': 'Mastered',
      'no_cards': 'No cards yet',
      'add_card': 'Add Card',
      'edit_card': 'Edit Card',
      'delete_card': 'Delete Card',
      'delete_card_confirm': 'Delete this card?',
      'front': 'Front',
      'back': 'Back',
      'study_due': 'Study (@{n} due)',
      'card_front': 'QUESTION',
      'card_back': 'ANSWER',
      'tap_to_flip': 'Tap to reveal answer',
      'tap_card_to_flip': 'Tap the card to flip',
      'studying': 'Card',
      'cards_left': 'left',
      'how_well': 'How well did you know this?',
      'rate_again': 'Again',
      'rate_hard': 'Hard',
      'rate_good': 'Good',
      'rate_easy': 'Easy',
      'session_done': 'Session Complete!',
      'result_correct': 'Correct',
      'result_accuracy': 'Accuracy',
      'back_to_deck': 'Back to Deck',
      'study_again': 'Study Again',
    },
    'ko': {
      // 공통
      'settings': '설정',
      'save': '저장',
      'cancel': '취소',
      'delete': '삭제',
      'edit': '편집',
      'share': '공유',
      'reset': '초기화',
      'done': '완료',
      'ok': '확인',
      'yes': '예',
      'no': '아니오',
      'error': '오류',
      'success': '성공',
      'loading': '로딩 중...',
      'no_data': '데이터 없음',

      // 설정
      'dark_mode': '다크 모드',
      'language': '언어',
      'about': '앱 정보',
      'version': '버전',
      'rate_app': '앱 평가',
      'privacy_policy': '개인정보처리방침',
      'remove_ads': '광고 제거',

      // 피드백
      'send_feedback': '피드백 보내기',
      'more_apps': '더 많은 앱',

      // 앱별
      'app_name': '플래시카드 학습',
      'no_decks': '덱이 없습니다',
      'no_decks_sub': '덱을 만들어 공부를 시작해보세요!',
      'new_deck': '새 덱 만들기',
      'edit_deck': '덱 편집',
      'delete_deck': '덱 삭제',
      'delete_deck_confirm': '"{title}" 덱과 모든 카드를 삭제할까요?',
      'deck_title': '덱 이름',
      'deck_desc': '설명 (선택)',
      'deck': '덱',
      'cards': '장',
      'due': '복습',
      'due_today': '오늘 복습',
      'total_cards': '전체',
      'mastered': '완료',
      'no_cards': '카드가 없습니다',
      'add_card': '카드 추가',
      'edit_card': '카드 편집',
      'delete_card': '카드 삭제',
      'delete_card_confirm': '이 카드를 삭제할까요?',
      'front': '앞면',
      'back': '뒷면',
      'study_due': '학습 시작 (@{n}장 복습)',
      'card_front': '질문',
      'card_back': '정답',
      'tap_to_flip': '탭해서 답 보기',
      'tap_card_to_flip': '카드를 탭해서 뒤집기',
      'studying': '카드',
      'cards_left': '남음',
      'how_well': '얼마나 잘 알고 있었나요?',
      'rate_again': '다시',
      'rate_hard': '어려움',
      'rate_good': '보통',
      'rate_easy': '쉬움',
      'session_done': '학습 완료!',
      'result_correct': '정답',
      'result_accuracy': '정확도',
      'back_to_deck': '덱으로',
      'study_again': '다시 학습',
    },
  };
}
