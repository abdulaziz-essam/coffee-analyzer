import 'package:flutter_test/flutter_test.dart' as flutter_test;

/// BDD-style test helper functions for JavaScript-like testing syntax
/// Usage: describe, context, it instead of group, group, test

/// Describes a test suite (equivalent to describe in JS)
void describe(String description, Function() body) {
  flutter_test.group(description, body);
}

/// Adds context to a test suite (equivalent to context in JS)
void context(String description, Function() body) {
  flutter_test.group(description, body);
}

/// Defines a test case (equivalent to it in JS)
void it(String description, dynamic Function() body) {
  flutter_test.test(description, body);
}

// Matcher aliases for more JS-like syntax
const toEqual = flutter_test.equals;
const toBeTrue = flutter_test.isTrue;
const toBeFalse = flutter_test.isFalse;
const toBeNull = flutter_test.isNull;
const toBeNotNull = flutter_test.isNotNull;
