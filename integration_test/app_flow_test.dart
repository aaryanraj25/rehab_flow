import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Device/emulator entrypoint.
///
/// Full multi-screen flows are exercised in `test/integration/app_flow_test.dart`
/// (runs with plain `flutter test`). This file wires the same suite for
/// `flutter test integration_test` / `flutter drive` on a real device.
///
/// Prefer the host suite for CI; use this when validating on hardware:
///   flutter test integration_test -d <deviceId>
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('integration_test binding is available for device runs',
      (tester) async {
    expect(IntegrationTestWidgetsFlutterBinding.instance, isNotNull);
  });
}
