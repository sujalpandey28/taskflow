import 'dart:convert';

class ProjectModel {
  final String id;
  final String orgId;
  final String name;
  final String description;
  final int taskCount;
  final String status;
  final DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.orgId,
    required this.name,
    required this.description,
    required this.taskCount,
    required this.status,
    required this.createdAt,
  });

  ProjectModel copyWith({
    String? id,
    String? orgId,
    String? name,
    String? description,
    int? taskCount,
    String? status,
    DateTime? createdAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      name: name ?? this.name,
      description: description ?? this.description,
      taskCount: taskCount ?? this.taskCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'org_id': orgId,
      'name': name,
      'description': description,
      'task_count': taskCount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] as String,
      orgId: map['org_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      taskCount: map['task_count'] as int,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory ProjectModel.fromJson(String source) =>
      ProjectModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ProjectModel('
        'id: $id, '
        'orgId: $orgId, '
        'name: $name, '
        'description: $description, '
        'taskCount: $taskCount, '
        'status: $status, '
        'createdAt: $createdAt'
        ')';
  }

  @override
  bool operator ==(covariant ProjectModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.orgId == orgId &&
        other.name == name &&
        other.description == description &&
        other.taskCount == taskCount &&
        other.status == status &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        orgId.hashCode ^
        name.hashCode ^
        description.hashCode ^
        taskCount.hashCode ^
        status.hashCode ^
        createdAt.hashCode;
  }
}
