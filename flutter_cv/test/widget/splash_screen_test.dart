import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_cv/screens/splash_screen.dart';
import '../test_helper.dart';

void main() {
  describe('SplashScreen', () {
    testWidgets('it should display Coffee CV text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SplashScreen()),
      );

      expect(find.text('Coffee CV'), findsOneWidget);
    });

    testWidgets('it should display brewing message', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const MaterialApp(home: SplashScreen()),
      );

      // Assert
      expect(find.text('Brewing your experience...'), findsOneWidget);
    });

    context('when animation is initialized', () {
      testWidgets('it should show animated builder', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(home: SplashScreen()),
        );

        // Assert - finds multiple AnimatedBuilders
        expect(find.byType(AnimatedBuilder), findsWidgets);
      });

      testWidgets('it should have cream background color', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(home: SplashScreen()),
        );

        // Assert
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, const Color(0xFFFFF8E1));
      });
    });

    context('when rendering coffee cup', () {
      testWidgets('it should display custom paint for coffee cup', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(home: SplashScreen()),
        );

        // Assert - finds at least one CustomPaint widget
        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('it should animate after pump', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(home: SplashScreen()),
        );

        // Act - advance animation
        await tester.pump(const Duration(milliseconds: 500));

        // Assert
        expect(find.byType(SplashScreen), findsOneWidget);
      });
    });
  });
}
