import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../widgets/task_card.dart';
import '../widgets/weekly_tasks_card.dart';

/// Pantalla 1 — Home
/// Shows weekly stats, today's progress, and the full task list.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final TaskRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TaskEntity> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _loading = true);
    try {
      final tasks = await widget.repository.getAllTasks();
      setState(() => _tasks = tasks);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleTask(TaskEntity task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await widget.repository.updateTask(updated);
    await _loadTasks();
  }

  Future<void> _deleteTask(String id) async {
    await widget.repository.deleteTask(id);
    await _loadTasks();
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.danger,
      ),
    );
  }

  // ── Derived stats ─────────────────────────────────────────────────────────
  int get _totalToday {
    final today = DateTime.now();
    return _tasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == today.year &&
          t.dueDate!.month == today.month &&
          t.dueDate!.day == today.day;
    }).length;
  }

  int get _completedToday {
    final today = DateTime.now();
    return _tasks.where((t) {
      if (t.dueDate == null) return false;
      return t.isCompleted &&
          t.dueDate!.year == today.year &&
          t.dueDate!.month == today.month &&
          t.dueDate!.day == today.day;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final total = _tasks.length;
    final completed = _tasks.where((t) => t.isCompleted).length;
    final todayTotal = _totalToday.clamp(1, 9999);
    final todayDone = _completedToday;
    final progress = todayTotal == 0 ? 0.0 : todayDone / todayTotal;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadTasks,
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── App Bar ─────────────────────────────────────────────────
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AppColors.scaffold,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  expandedHeight: 80,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Day! 👋',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Weekly card ──────────────────────────────────
                        WeeklyTasksCard(total: total, completed: completed),
                        const SizedBox(height: 28),

                        // ── Today header ─────────────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Today Tasks',
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              '$todayDone of $_totalToday',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ── Progress bar ─────────────────────────────────
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: AppColors.primaryMid,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Task list ─────────────────────────────────────
                        if (_tasks.isEmpty)
                          _EmptyState()
                        else
                          ...(_tasks.map(
                            (t) => TaskCard(
                              task: t,
                              onToggle: () => _toggleTask(t),
                              onDelete: () => _deleteTask(t.id),
                            ),
                          )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline,
                size: 64, color: AppColors.primaryMid),
            const SizedBox(height: 16),
            Text(
              'No tasks yet!\nTap + to add your first one.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AppColors.textMedium,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
