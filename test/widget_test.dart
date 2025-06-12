// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:interval_timer/main.dart';

void main() {
  testWidgets('Interval timer app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const IntervalTimerApp());

    // Verify that our timer app loads with initial state.
    expect(find.text('インターバルタイマー'), findsOneWidget);
    expect(find.text('カウントダウン'), findsOneWidget);
    expect(find.text('インターバル'), findsOneWidget);
    expect(find.text('開始'), findsOneWidget);
  });
}
