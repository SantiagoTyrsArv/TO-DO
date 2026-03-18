import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../widgets/task_card.dart';

/// Pantalla 2 — Completed Tasks
/// Shows all tasks where [TaskEntity.isCompleted] is true.
class CompletedScreen extends StatefulWidget {
  const CompletedScreen({super.key, required this.repository});

  final TaskRepository repository;

  @override
  State<CompletedScreen> createState() => _CompletedScreenState();
}

class _CompletedScreenState extends State<CompletedScreen> {
  List<TaskEntity> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final all = await widget.repository.getAllTasks();
      setState(() => _tasks = all.where((t) => t.isCompleted).toList());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _uncomplete(TaskEntity task) async {
    await widget.repository.updateTask(task.copyWith(isCompleted: false));
    await _load();
  }

  Future<void> _delete(String id) async {
    await widget.repository.deleteTask(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.scaffold,
        automaticallyImplyLeading: false,
        title: Text(
          'Completed Tasks',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_tasks.length} done',
                  style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : _tasks.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 120),
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.celebration_rounded,
                                size: 64, color: AppColors.primaryMid),
                            const SizedBox(height: 16),
                            Text(
                              'No completed tasks yet!\nKeep going 💪',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: AppColors.textMedium,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _tasks.length,
                    itemBuilder: (_, i) => TaskCard(
                      task: _tasks[i],
                      onToggle: () => _uncomplete(_tasks[i]),
                      onDelete: () => _delete(_tasks[i].id),
                    ),
                  ),
      ),
    );
  }
}
