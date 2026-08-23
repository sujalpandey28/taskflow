import 'dart:convert';

class CommentModel {
  final String id;
  final String taskId;
  final String authorId;
  final String body;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.taskId,
    required this.authorId,
    required this.body,
    required this.createdAt,
  });

  CommentModel copyWith({
    String? id,
    String? taskId,
    String? authorId,
    String? body,
    DateTime? createdAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      authorId: authorId ?? this.authorId,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'author_id': authorId,
      'body': body,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as String,
      taskId: map['task_id'] as String,
      authorId: map['author_id'] as String,
      body: map['body'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory CommentModel.fromJson(String source) =>
      CommentModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CommentModel('
        'id: $id, '
        'taskId: $taskId, '
        'authorId: $authorId, '
        'body: $body, '
        'createdAt: $createdAt'
        ')';
  }

  @override
  bool operator ==(covariant CommentModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.taskId == taskId &&
        other.authorId == authorId &&
        other.body == body &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        taskId.hashCode ^
        authorId.hashCode ^
        body.hashCode ^
        createdAt.hashCode;
  }
}
