class UserModel {
  const UserModel({
    required this.email,
    required this.name,
    required this.token,
  });

  final String email;
  final String name;
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
