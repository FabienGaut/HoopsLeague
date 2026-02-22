import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _testSupabaseUrl = 'https://test.supabase.co';
const _testSupabaseKey = 'test-anon-key';

/// Helper to initialize Supabase for testing
///
/// Usage in tests:
/// ```dart
/// setUp(() async {
///   await initializeSupabaseForTest();
/// });
/// ```
Future<void> initializeSupabaseForTest() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/shared_preferences'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{};
      }
      return null;
    },
  );

  try {
    final _ = Supabase.instance;
  } catch (e) {
    await Supabase.initialize(
      url: _testSupabaseUrl,
      anonKey: _testSupabaseKey,
    );
  }
}

/// Helper to reset Supabase between tests
Future<void> resetSupabaseForTest() async {
  // Note: Supabase doesn't provide a way to un-initialize
  // So we just ensure the client is ready for the next test
  try {
    await Supabase.instance.client.auth.signOut();
  } catch (e) {
    // Ignore errors during cleanup
  }
}
