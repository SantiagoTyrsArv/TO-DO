import '../../domain/entities/task_entity.dart';

/// Data-layer model that extends [TaskEntity] with Supabase serialization.
class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    super.description,
    required super.category,
    super.dueDate,
    required super.isCompleted,
    required super.createdAt,
    super.fileUrls = const [],
  });

  // ── Deserialization ───────────────────────────────────────────────────────
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    // file_urls comes back as List<dynamic> from Supabase
    final rawUrls = map['file_urls'];
    final urls = rawUrls is List
        ? rawUrls.map((e) => e.toString()).toList()
        : <String>[];

    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      category: (map['category'] as String?) ?? 'General',
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'] as String).toLocal()
          : null,
      isCompleted: (map['is_completed'] as bool?) ?? false,
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      fileUrls: urls,
    );
  }

  // ── Serialization ─────────────────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'due_date': dueDate?.toUtc().toIso8601String(),
      'is_completed': isCompleted,
      'file_urls': fileUrls,
      // created_at is managed by the DB default, omit on insert
    };
  }

  /// Creates a [TaskModel] from a [TaskEntity].
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      category: entity.category,
      dueDate: entity.dueDate,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      fileUrls: entity.fileUrls,
    );
  }
}
