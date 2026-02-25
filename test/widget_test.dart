import 'package:flutter_test/flutter_test.dart';
import 'package:flashcard_study/main.dart';

void main() {
  testWidgets('flashcard_study smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FlashcardStudyApp());

    expect(find.byType(FlashcardStudyApp), findsOneWidget);
  });
}
