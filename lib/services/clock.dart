import 'package:flutter/foundation.dart';

/// A simple clock service that can be mocked for testing.
/// By default, it returns the current time, but it can be subclassed
/// to return a fixed time for tests.
class Clock {
  DateTime now() => DateTime.now();
}
