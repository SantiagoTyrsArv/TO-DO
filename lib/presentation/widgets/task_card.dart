import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/task_entity.dart';
import 'task_attachments_row.dart';

/// Reusable task card used on [HomeScreen] and [CompletedScreen].
///
/// Shows a rounded checkbox, task title, coloured time/category badge, and
/// — when the task has file attachments — a [TaskAttachmentsRow] below.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    this.onDelete,
  });

  final TaskEntity task;
  final VoidCallback onToggle;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final hasAttachments = task.fileUrls.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Main row (checkbox · title · badge · delete) ──────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated checkbox
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: task.isCompleted
                            ? AppColors.primary
                            : AppColors.textLight,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),

                // Title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: task.isCompleted
                              ? AppColors.textLight
                              : AppColors.textDark,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      if (task.category != 'General')
                        Text(
                          task.category,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textMedium,
                          ),
                        ),
                    ],
                  ),
                ),

                // Time/category badge
                _BadgeChip(task: task),

                // Delete button
                if (onDelete != null) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(Icons.delete_outline,
                        color: AppColors.textLight, size: 20),
                  ),
                ],
              ],
            ),

            // ── Attachments strip ─────────────────────────────────────────
            if (hasAttachments) TaskAttachmentsRow(urls: task.fileUrls),
          ],
        ),
      ),
    );
  }
}

// ── Private badge widget ──────────────────────────────────────────────────────

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.task});

  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _fg,
        ),
      ),
    );
  }

  String get _label {
    if (task.dueDate == null) return task.category;
    final h = task.dueDate!.hour;
    final period = h < 12 ? 'A.M' : 'P.M';
    final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$hour $period';
  }

  Color get _bg {
    final colors = [
      AppColors.badgeOrange,
      AppColors.badgeGreen,
      AppColors.badgePurple,
      AppColors.badgeBlue,
    ];
    return colors[task.title.length % colors.length];
  }

  Color get _fg {
    final colors = [
      AppColors.badgeOrangeText,
      AppColors.badgeGreenText,
      AppColors.badgePurpleText,
      AppColors.badgeBlueText,
    ];
    return colors[task.title.length % colors.length];
  }
}
