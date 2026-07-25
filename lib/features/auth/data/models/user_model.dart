import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  UserModel({
    required this.email,
    required this.name,
    required this.token,
  });

  @HiveField(0)
  final String email;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String token;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] as String,
      name: json['name'] as String? ?? 'User',
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'name': name,
        'token': token,
      };

  String get displayName {
    final local = email.split('@').first;
    if (local.isEmpty) return name;
    return local[0].toUpperCase() + local.substring(1);
  }
}
