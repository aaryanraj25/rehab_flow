import 'package:flutter_test/flutter_test.dart';
import 'package:rehab_flow/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects null and empty', () {
      expect(Validators.email(null), 'Email is required');
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email('   '), 'Email is required');
    });

    test('rejects malformed addresses', () {
      expect(Validators.email('bad'), isNotNull);
      expect(Validators.email('bad@'), isNotNull);
      expect(Validators.email('@domain.com'), isNotNull);
      expect(Validators.email('name@domain'), isNotNull);
    });

    test('accepts valid addresses', () {
      expect(Validators.email('demo@rehabflow.app'), isNull);
      expect(Validators.email('  user.name+tag@example.co.uk  '), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects null and empty', () {
      expect(Validators.password(null), 'Password is required');
      expect(Validators.password(''), 'Password is required');
    });

    test('rejects passwords shorter than minimum', () {
      expect(Validators.password('12345'), contains('at least'));
    });

    test('accepts passwords that meet minimum length', () {
      expect(Validators.password('rehab123'), isNull);
      expect(Validators.password('123456'), isNull);
    });
  });
}
