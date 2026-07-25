import '../../../../core/errors/app_exception.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../models/user_model.dart';

/// Contract for mock auth + local session persistence.
abstract class AuthRepository {
  UserModel? getCurrentSession();

  bool get isAuthenticated;

  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();
}

/// Hive-backed [AuthRepository] implementation.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._storage);

  final LocalStorageService _storage;

  @override
  UserModel? getCurrentSession() => _storage.getSession();

  @override
  bool get isAuthenticated => _storage.hasSession;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      throw const AuthException('Email and password are required.');
    }

    final user = UserModel(
      email: trimmedEmail,
      name: _nameFromEmail(trimmedEmail),
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
    );

    await _storage.saveSession(user);
    return user;
  }

  @override
  Future<void> logout() async {
    await _storage.clearSession();
  }

  String _nameFromEmail(String email) {
    final local = email.split('@').first;
    if (local.isEmpty) return 'User';
    return local[0].toUpperCase() + local.substring(1);
  }
}

class AuthException extends AppException {
  const AuthException(super.message);
}
