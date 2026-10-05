/// A server garden (jardim): the unit of synced data several accounts on the
/// same server can share. Every account has a personal one.
class Garden {
  final String id;
  final String name;
  final bool personal;

  /// The caller's role in it: 'owner' | 'member'.
  final String role;
  final String? ownerEmail;

  const Garden({
    required this.id,
    required this.name,
    required this.personal,
    required this.role,
    this.ownerEmail,
  });

  bool get isOwner => role == 'owner';

  /// The caller's own personal garden, which a workspace reaches without
  /// naming it (no garden id).
  bool get isOwnPersonal => personal && isOwner;

  factory Garden.fromJson(Map<String, dynamic> json) => Garden(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        personal: json['personal'] as bool? ?? false,
        role: json['role'] as String? ?? 'member',
        ownerEmail: json['ownerEmail'] as String?,
      );
}

class GardenMember {
  final String userId;
  final String email;

  /// 'owner' | 'member'.
  final String role;

  const GardenMember({
    required this.userId,
    required this.email,
    required this.role,
  });

  bool get isOwner => role == 'owner';

  factory GardenMember.fromJson(Map<String, dynamic> json) => GardenMember(
        userId: json['userId'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
      );
}

/// The garden a workspace is set to sync: its id and the name shown for it.
/// No choice (null) means the account's personal garden.
typedef GardenChoice = ({String id, String name});
