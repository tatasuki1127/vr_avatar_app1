// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vr_avatar_app/main.dart';

void main() {
  testWidgets('VR Avatar App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VRAvatarApp());

    // Verify that our app starts with the correct title.
    expect(find.text('VR Avatar App'), findsOneWidget);
    expect(find.text('GPU最適化リアルタイムVR化'), findsOneWidget);

    // Wait for splash screen animation
    await tester.pump(const Duration(seconds: 3));

    // Verify we can find the VR start button
    expect(find.text('VR体験を開始'), findsOneWidget);
  });
}
