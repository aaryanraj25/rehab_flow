import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rehab_flow/core/storage/local_storage_service.dart';
import 'package:rehab_flow/core/theme/app_theme.dart';
import 'package:rehab_flow/features/auth/data/repositories/auth_repository.dart';
import 'package:rehab_flow/main.dart';
import 'package:rehab_flow/network/api_client.dart';
import 'package:rehab_flow/utils/validators.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorageService(prefs);
    Get.put(storage, permanent: true);
    Get.put(NetworkInfo(), permanent: true);
    Get.put(ApiClient(), permanent: true);
    Get.put(AuthRepository(storage), permanent: true);
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

  test('AuthRepository persists and clears mock session', () async {
    final auth = Get.find<AuthRepository>();
    expect(auth.isAuthenticated, isFalse);

    final user = await auth.login(
      email: 'demo@rehabflow.app',
      password: 'rehab123',
    );
    expect(user.email, 'demo@rehabflow.app');
    expect(auth.isAuthenticated, isTrue);
    expect(auth.getCurrentSession()?.token, isNotEmpty);

    await auth.logout();
    expect(auth.isAuthenticated, isFalse);
  });
}
