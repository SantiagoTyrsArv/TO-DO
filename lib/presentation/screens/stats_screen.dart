import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

/// Pantalla 3 — Task Overview (Statistics)
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key, required this.repository});

  final TaskRepository repository;

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
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
      setState(() => _tasks = all);
    } finally {
      setState(() => _loading = false);
    }
  }

  int get _total => _tasks.length;
  int get _completed => _tasks.where((t) => t.isCompleted).length;
  int get _pending => _total - _completed;
  double get _rate => _total == 0 ? 0 : _completed / _total;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffold,
      appBar: AppBar(
        backgroundColor: AppColors.scaffold,
        automaticallyImplyLeading: false,
        title: Text(
          'Task Overview',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                children: [
                  const SizedBox(height: 16),

                  // ── Pie chart ─────────────────────────────────────────
                  Container(
                    height: 260,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppColors.cardShadow,
                    ),
                    padding: const EdgeInsets.all(24),
                    child: _total == 0
                        ? Center(
                            child: Text(
                              'Add tasks to see\nyour stats 📊',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: AppColors.textMedium,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 60,
                              sections: [
                                PieChartSectionData(
                                  value: _completed.toDouble(),
                                  color: AppColors.primary,
                                  radius: 28,
                                  title: '',
                                ),
                                PieChartSectionData(
                                  value: _pending.toDouble(),
                                  color: const Color(0xFFEEEEEE),
                                  radius: 22,
                                  title: '',
                                ),
                              ],
                            ),
                          ),
                    // Center label overlay
                  ),

                  // ── Center label (overlaid via Stack won't work in ListView,
                  //    so we show a separate summary label below) ─────────────
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '${(_rate * 100).round()}% completed',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ),

                  // ── Legend ────────────────────────────────────────────
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LegendDot(color: AppColors.primary, label: 'Completed'),
                      const SizedBox(width: 24),
                      _LegendDot(
                          color: const Color(0xFFEEEEEE), label: 'Pending'),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Stat cards grid ───────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                          child: _StatCard(
                              label: 'Total', value: _total, icon: Icons.list_alt_rounded)),
                      const SizedBox(width: 14),
                      Expanded(
                          child: _StatCard(
                              label: 'Completed',
                              value: _completed,
                              icon: Icons.check_circle_rounded,
                              color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                          child: _StatCard(
                              label: 'Pending',
                              value: _pending,
                              icon: Icons.access_time_filled_rounded,
                              color: AppColors.danger)),
                      const SizedBox(width: 14),
                      Expanded(
                          child: _StatCard(
                              label: 'Success Rate',
                              value: '${(_rate * 100).round()}%',
                              icon: Icons.bar_chart_rounded,
                              color: const Color(0xFF9C27B0))),
                    ],
                  ),

                  // ── Category breakdown ────────────────────────────────
                  const SizedBox(height: 28),
                  Text(
                    'By Category',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._buildCategoryRows(),
                ],
              ),
      ),
    );
  }

  List<Widget> _buildCategoryRows() {
    final Map<String, int> counts = {};
    for (final t in _tasks) {
      counts[t.category] = (counts[t.category] ?? 0) + 1;
    }
    if (counts.isEmpty) {
      return [
        Text('No data yet.',
            style: GoogleFonts.poppins(color: AppColors.textMedium))
      ];
    }
    return counts.entries.map((e) {
      final ratio = _total == 0 ? 0.0 : e.value / _total;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.textDark)),
                  Text('${e.value} tasks',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textMedium)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 6,
                  backgroundColor: AppColors.primaryMid,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.textDark,
  });

  final String label;
  final Object value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            '$value',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(backgroundColor: color, radius: 7),
        const SizedBox(width: 8),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12, color: AppColors.textMedium)),
      ],
    );
  }
}
