// This is a basic Flutter widget test for Food Dash game.

import 'package:flutter_test/flutter_test.dart';

import 'package:food_dash/main.dart';

void main() {
  testWidgets('Food Dash app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FoodDashApp());

    // Verify that the app loads without errors
    expect(find.byType(FoodDashApp), findsOneWidget);
  });
}
