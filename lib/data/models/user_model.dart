import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email, 'avatar_url': avatarUrl};
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      avatarUrl: map['avatar_url'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, avatarUrl: $avatarUrl)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.email == email &&
        other.avatarUrl == avatarUrl;
  }

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ email.hashCode ^ avatarUrl.hashCode;
}

class OrgMemberModel {
  final String orgId;
  final String userId;
  final String role;

  OrgMemberModel({
    required this.orgId,
    required this.userId,
    required this.role,
  });

  OrgMemberModel copyWith({String? orgId, String? userId, String? role}) {
    return OrgMemberModel(
      orgId: orgId ?? this.orgId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return {'org_id': orgId, 'user_id': userId, 'role': role};
  }

  factory OrgMemberModel.fromMap(Map<String, dynamic> map) {
    return OrgMemberModel(
      orgId: map['org_id'] as String,
      userId: map['user_id'] as String,
      role: map['role'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory OrgMemberModel.fromJson(String source) =>
      OrgMemberModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'OrgMemberModel(orgId: $orgId, userId: $userId, role: $role)';
  }

  @override
  bool operator ==(covariant OrgMemberModel other) {
    if (identical(this, other)) return true;

    return other.orgId == orgId && other.userId == userId && other.role == role;
  }

  @override
  int get hashCode => orgId.hashCode ^ userId.hashCode ^ role.hashCode;
}
