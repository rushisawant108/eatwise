import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eatwise/main.dart';

void main() {
  testWidgets('EatWise app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EatWiseApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
