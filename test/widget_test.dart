import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rehab_flow/core/storage/local_storage_service.dart';
import 'package:rehab_flow/core/theme/app_theme.dart';
import 'package:rehab_flow/main.dart';
import 'package:rehab_flow/network/api_client.dart';
import 'package:rehab_flow/utils/validators.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    Get.put(LocalStorageService(prefs), permanent: true);
    Get.put(NetworkInfo(), permanent: true);
    Get.put(ApiClient(), permanent: true);
  });

  tearDown(Get.reset);

  testWidgets('RehabFlow app boots with placeholder home', (tester) async {
    await tester.pumpWidget(const RehabFlowApp());
    expect(find.text('RehabFlow'), findsOneWidget);
    expect(find.text('Rehabilitation Exercise Management'), findsOneWidget);
  });

  test('email validator rejects invalid addresses', () {
    expect(Validators.email(null), isNotNull);
    expect(Validators.email('bad'), isNotNull);
    expect(Validators.email('demo@rehabflow.app'), isNull);
  });

  test('password validator enforces minimum length', () {
    expect(Validators.password('123'), isNotNull);
    expect(Validators.password('rehab123'), isNull);
  });

  test('LocalStorageService persists JSON values', () async {
    final storage = Get.find<LocalStorageService>();
    await storage.setJson('sample', {'ok': true});
    expect(storage.getJson('sample'), {'ok': true});
  });
}
