import 'package:flutter/material.dart';
import 'package:task_anagement/controllers/task_controller.dart';
import 'package:task_anagement/utils/app_theme.dart';

class EmptyStateView extends StatelessWidget {
  final TaskFilter currentFilter;
  final String searchQuery;
  final VoidCallback onActionPressed;
  final VoidCallback onClearSearch;

  const EmptyStateView({
    super.key,
    required this.currentFilter,
    required this.searchQuery,
    required this.onActionPressed,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSearching = searchQuery.trim().isNotEmpty;

    IconData icon;
    String title;
    String subtitle;
    String? buttonText;
    VoidCallback? buttonCallback;

    if (isSearching) {
      icon = Icons.search_off_rounded;
      title = 'No tasks found';
      subtitle = 'No tasks match "$searchQuery". Try searching for something else.';
      buttonText = 'Clear Search';
      buttonCallback = onClearSearch;
    } else {
      switch (currentFilter) {
        case TaskFilter.pending:
          icon = Icons.task_alt_rounded;
          title = 'No pending tasks!';
          subtitle = 'Great job! You have cleared all your pending tasks.';
          buttonText = null;
          buttonCallback = null;
          break;
        case TaskFilter.completed:
          icon = Icons.check_circle_outline_rounded;
          title = 'No completed tasks';
          subtitle = 'Complete your pending tasks to see them archived here.';
          buttonText = 'View All Tasks';
          buttonCallback = onActionPressed;
          break;
        case TaskFilter.all:
          icon = Icons.note_add_outlined;
          title = 'No tasks yet';
          subtitle = 'Keep track of your projects, errands, and goals by tapping the + button below.';
          buttonText = null;
          buttonCallback = null;
          break;
      }
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            if (buttonText != null && buttonCallback != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: buttonCallback,
                icon: Icon(
                  isSearching ? Icons.clear_rounded : Icons.add_rounded,
                  size: 20,
                ),
                label: Text(
                  buttonText,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
