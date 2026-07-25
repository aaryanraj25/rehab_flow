import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../models/user_model.dart';


class AuthRepository {
  AuthRepository(this._storage);

  final LocalStorageService _storage;

  UserModel? getCurrentSession() {
    final json = _storage.getJson(AppConstants.storageAuthKey);
    if (json is! Map<String, dynamic>) return null;
    try {
      return UserModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  bool get isAuthenticated => getCurrentSession() != null;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));

    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      throw AuthException('Email and password are required.');
    }

    final user = UserModel(
      email: trimmedEmail,
      name: _nameFromEmail(trimmedEmail),
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
    );

    await _storage.setJson(AppConstants.storageAuthKey, user.toJson());
    return user;
  }

  Future<void> logout() async {
    await _storage.remove(AppConstants.storageAuthKey);
  }

  String _nameFromEmail(String email) {
    final local = email.split('@').first;
    if (local.isEmpty) return 'User';
    return local[0].toUpperCase() + local.substring(1);
  }
}

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
