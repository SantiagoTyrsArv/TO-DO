import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/repositories/task_repository.dart';
import 'home_screen.dart';
import 'completed_screen.dart';
import 'stats_screen.dart';
import 'add_task_screen.dart';

/// Root scaffold that hosts the 4 screens via [IndexedStack] and a custom
/// [BottomNavigationBar] matching the reference design.
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key, required this.repository});

  final TaskRepository repository;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  /// Navigate to Add Task screen as a full-screen route and reload if saved.
  Future<void> _openAddTask() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(repository: widget.repository),
      ),
    );
    // If a task was saved, force the home screen to reload by rebuilding.
    if (result == true && mounted) {
      setState(() {
        // The IndexedStack children hold their state; nudge state to trigger
        // initState on the visible screen is done by using GlobalKeys.
        // Here we simply switch to home (index 0) and back to force re-init.
        _currentIndex = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(repository: widget.repository),
      CompletedScreen(repository: widget.repository),
      StatsScreen(repository: widget.repository),
    ];

    return Scaffold(
      // Use IndexedStack so each screen preserves its scroll position.
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: _BottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        onAdd: _openAddTask,
      ),
    );
  }
}

// ── Custom bottom navigation bar ─────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.currentIndex,
    required this.onTap,
    required this.onAdd,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.description_outlined,
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.pie_chart_rounded,
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              // Green "+" add button
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 52,
        height: 52,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textLight,
              size: 26,
            ),
            if (isActive)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: CircleAvatar(
                  radius: 3,
                  backgroundColor: AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
