import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_cv/screens/splash_screen.dart';
import '../test_helper.dart';
import '../mocks/mocks.dart';

void main() {
  late MockNavigatorObserver mockObserver;

  setUpAll(() {
    // Register fallback values once for all tests
    registerMockFallbacks();
  });

  setUp(() {
    mockObserver = MockNavigatorObserver();
  });

  describe('SplashScreen with Mocks', () {
    testWidgets('it should render splash screen correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: const SplashScreen(),
          navigatorObservers: [mockObserver],
        ),
      );

      // Assert
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('Coffee CV'), findsOneWidget);
    });

    context('when testing navigation', () {
      testWidgets('it should be on splash screen initially', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: const SplashScreen(),
            navigatorObservers: [mockObserver],
          ),
        );

        // Assert
        expect(find.byType(SplashScreen), findsOneWidget);
      });
    });

    context('when testing animations', () {
      testWidgets('it should have animation controller running', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(home: SplashScreen()),
        );

        // Act - let animation run
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // Assert - screen still exists
        expect(find.byType(SplashScreen), findsOneWidget);
      });

      testWidgets('it should animate coffee cup scale', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          const MaterialApp(home: SplashScreen()),
        );

        // Act - advance time to see animation
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Assert - animated builder should be present
        expect(find.byType(AnimatedBuilder), findsWidgets);
      });
    });

    context('when testing widgets', () {
      testWidgets('it should display all required text elements', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(home: SplashScreen()),
        );

        // Assert
        expect(find.text('Coffee CV'), findsOneWidget);
        expect(find.text('Brewing your experience...'), findsOneWidget);
      });

      testWidgets('it should have correct background color', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(home: SplashScreen()),
        );

        // Assert
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, toEqual(const Color(0xFFFFF8E1)));
      });
    });
  });
}
