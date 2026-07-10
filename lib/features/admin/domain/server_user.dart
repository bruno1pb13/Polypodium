class ServerUser {
  final String id;
  final String email;
  final String role;
  final bool disabled;
  final DateTime createdAt;

  const ServerUser({
    required this.id,
    required this.email,
    required this.role,
    required this.disabled,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';

  factory ServerUser.fromJson(Map<String, dynamic> json) => ServerUser(
        id: json['id'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        disabled: json['disabled'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
