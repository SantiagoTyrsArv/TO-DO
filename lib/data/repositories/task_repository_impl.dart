import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase/supabase_provider.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../models/task_model.dart';

/// Concrete Supabase implementation of [TaskRepository].
class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl();

  static const String _table = 'tasks';
  static const String _bucket = 'task-files';

  SupabaseClient get _client => SupabaseProvider.client;

  // ── Read ──────────────────────────────────────────────────────────────────
  @override
  Future<List<TaskEntity>> getAllTasks() async {
    final response = await _client
        .from(_table)
        .select()
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((row) => TaskModel.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  // ── Create ────────────────────────────────────────────────────────────────
  @override
  Future<void> addTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    final data = model.toMap()..remove('created_at');
    await _client.from(_table).insert(data);
  }

  // ── Update ────────────────────────────────────────────────────────────────
  @override
  Future<void> updateTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    await _client
        .from(_table)
        .update(model.toMap())
        .eq('id', task.id);
  }

  // ── Delete ────────────────────────────────────────────────────────────────
  @override
  Future<void> deleteTask(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  // ── File Upload ───────────────────────────────────────────────────────────
  @override
  Future<String> uploadFile({
    required String taskId,
    required List<int> bytes,
    required String fileName,
  }) async {
    // Sanitise the filename (replace spaces) to avoid URL encoding issues
    final safeName = fileName.replaceAll(' ', '_');
    final storagePath = 'tasks/$taskId/$safeName';

    await _client.storage.from(_bucket).uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from(_bucket).getPublicUrl(storagePath);
  }
}
