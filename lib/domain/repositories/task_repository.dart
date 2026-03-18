import '../entities/task_entity.dart';

/// Abstract contract for task persistence operations.
/// The [data] layer provides the concrete implementation.
abstract interface class TaskRepository {
  /// Returns all tasks ordered by creation date descending.
  Future<List<TaskEntity>> getAllTasks();

  /// Persists a new [task] to the data source.
  Future<void> addTask(TaskEntity task);

  /// Updates an existing task (matched by [TaskEntity.id]).
  Future<void> updateTask(TaskEntity task);

  /// Permanently removes the task with the given [id].
  Future<void> deleteTask(String id);

  /// Uploads [bytes] to Supabase Storage under `tasks/[taskId]/[fileName]`
  /// and returns the public download URL.
  Future<String> uploadFile({
    required String taskId,
    required List<int> bytes,
    required String fileName,
  });
}
