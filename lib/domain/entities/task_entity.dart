/// Pure domain entity representing a single task.
/// Has no dependency on any external framework or package.
class TaskEntity {
  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.dueDate,
    required this.isCompleted,
    required this.createdAt,
    this.fileUrls = const [],
  });

  final String id;
  final String title;
  final String? description;
  final String category;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;

  /// Public URLs of files attached to this task (stored in Supabase Storage).
  final List<String> fileUrls;

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
    List<String>? fileUrls,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      fileUrls: fileUrls ?? this.fileUrls,
    );
  }
}
