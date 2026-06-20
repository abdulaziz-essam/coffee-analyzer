import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cv/screens/splash_screen.dart';

// Mock Navigator Observer - use to track navigation
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// Mock BuildContext
class MockBuildContext extends Mock implements BuildContext {}

// Mock SplashScreen - use this when you need to test navigation TO splash screen
class MockSplashScreen extends Mock implements SplashScreen {}

// Add your service mocks here
// Example:
// class MockUserService extends Mock implements UserService {}
// class MockAuthService extends Mock implements AuthService {}
// class MockApiClient extends Mock implements ApiClient {}

// Setup function to register fallback values (call this in setUpAll)
void registerMockFallbacks() {
  registerFallbackValue(MockBuildContext());
  registerFallbackValue(
    MaterialPageRoute(builder: (_) => const Scaffold()),
  );
}
