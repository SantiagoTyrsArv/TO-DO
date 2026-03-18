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
  });

  final String id;
  final String title;
  final String? description;
  final String category;
  final DateTime? dueDate;
  final bool isCompleted;
  final DateTime createdAt;

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
