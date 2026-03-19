import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../widgets/task_attachments_row.dart';

/// Full-screen view of a single task's details.
/// Returns `true` if the task was mutated (completed/deleted) so callers
/// can reload their list.
class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.repository,
  });

  final TaskEntity task;
  final TaskRepository repository;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TaskEntity _task;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _toggleComplete() async {
    setState(() => _busy = true);
    try {
      final updated = _task.copyWith(isCompleted: !_task.isCompleted);
      await widget.repository.updateTask(updated);
      setState(() => _task = updated);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Delete Task',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to delete "${_task.title}"?',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textMedium)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppColors.textMedium)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: GoogleFonts.poppins(
                    color: AppColors.danger, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      await widget.repository.deleteTask(_task.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      _showError(e.toString());
      setState(() => _busy = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dateStr = _task.dueDate != null
        ? DateFormat('EEEE, MMMM d · h:mm a').format(_task.dueDate!)
        : null;

    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.scaffold,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(true),
        ),
        title: Text('Task Details',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, fontSize: 17)),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline_rounded,
                color: AppColors.danger, size: 22),
            onPressed: _busy ? null : _delete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          // ── Status banner ─────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: _task.isCompleted
                  ? AppColors.primaryLight
                  : const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  _task.isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: _task.isCompleted
                      ? AppColors.primary
                      : const Color(0xFFFFA000),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  _task.isCompleted ? 'Completed' : 'In Progress',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _task.isCompleted
                        ? AppColors.primary
                        : const Color(0xFFFFA000),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Title ──────────────────────────────────────────────────────
          Text(
            _task.title,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              decoration: _task.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
          const SizedBox(height: 12),

          // ── Meta row (category + date) ─────────────────────────────────
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.folder_rounded,
                label: _task.category,
                bg: AppColors.primaryLight,
                fg: AppColors.primary,
              ),
              if (dateStr != null)
                _MetaChip(
                  icon: Icons.calendar_today_rounded,
                  label: dateStr,
                  bg: const Color(0xFFFFF3E0),
                  fg: const Color(0xFFFF9800),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Description ────────────────────────────────────────────────
          if (_task.description != null && _task.description!.isNotEmpty) ...[
            _SectionLabel(label: 'Description'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: Text(
                _task.description!,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textMedium,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Attachments ────────────────────────────────────────────────
          if (_task.fileUrls.isNotEmpty) ...[
            _SectionLabel(label: 'Attachments (${_task.fileUrls.length})'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppColors.cardShadow,
              ),
              child: TaskAttachmentsRow(urls: _task.fileUrls),
            ),
            const SizedBox(height: 20),
          ],

          // ── Created at ────────────────────────────────────────────────
          Center(
            child: Text(
              'Created ${DateFormat('MMM d, yyyy').format(_task.createdAt)}',
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.textLight),
            ),
          ),
        ],
      ),

      // ── Bottom action button ─────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _busy ? null : _toggleComplete,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : Icon(
                      _task.isCompleted
                          ? Icons.undo_rounded
                          : Icons.check_rounded,
                    ),
              label: Text(
                _task.isCompleted ? 'Mark as Pending' : 'Mark as Done',
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _task.isCompleted
                    ? AppColors.textMedium
                    : AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textMedium,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
  });

  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w500, color: fg),
          ),
        ],
      ),
    );
  }
}
