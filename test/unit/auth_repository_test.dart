import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_flow/features/auth/data/repositories/auth_repository.dart';

import '../helpers/test_harness.dart';

void main() {
  late TestHarness harness;

  setUp(() async {
    harness = await TestHarness.create();
  });

  tearDown(() async {
    await harness.dispose();
  });

  group('AuthRepositoryImpl', () {
    test('starts unauthenticated', () {
      expect(harness.authRepository.isAuthenticated, isFalse);
      expect(harness.authRepository.getCurrentSession(), isNull);
    });

    test('login persists a session that survives re-read', () async {
      final user = await harness.authRepository.login(
        email: 'demo@rehabflow.app',
        password: 'rehab123',
      );

      expect(user.email, 'demo@rehabflow.app');
      expect(user.token, startsWith('mock_token_'));
      expect(harness.authRepository.isAuthenticated, isTrue);

      final session = harness.authRepository.getCurrentSession();
      expect(session?.email, 'demo@rehabflow.app');
      expect(session?.displayName, 'Demo');
    });

    test('login trims email and rejects empty credentials', () async {
      await expectLater(
        () => harness.authRepository.login(email: '  ', password: 'rehab123'),
        throwsA(isA<AuthException>()),
      );
      await expectLater(
        () => harness.authRepository.login(
          email: 'demo@rehabflow.app',
          password: '',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('logout clears the persisted session', () async {
      await harness.authRepository.login(
        email: 'demo@rehabflow.app',
        password: 'rehab123',
      );
      await harness.authRepository.logout();

      expect(harness.authRepository.isAuthenticated, isFalse);
      expect(harness.storage.hasSession, isFalse);
    });
  });
}
