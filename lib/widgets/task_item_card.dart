import 'package:flutter/material.dart';
import 'package:task_anagement/models/task.dart';
import 'package:task_anagement/models/task_priority.dart';
import 'package:task_anagement/utils/app_theme.dart';
import 'package:task_anagement/utils/date_formatter.dart';

class TaskItemCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskItemCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = task.isCompleted;
    final isOverdue = task.isOverdue;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCompleted
              ? theme.colorScheme.outline.withValues(alpha: 0.5)
              : isOverdue
                  ? AppTheme.errorColor.withValues(alpha: 0.4)
                  : theme.colorScheme.outline,
          width: isOverdue ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox Toggle Button
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppTheme.successColor
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted
                            ? AppTheme.successColor
                            : theme.colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Main content: Title, Description, Meta badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isCompleted
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.45)
                            : theme.colorScheme.onSurface,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    if (task.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: isCompleted
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.35)
                              : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    // Badges row: Priority, Due Date, Overdue Indicator
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Priority Badge
                        _buildPriorityBadge(task.priority),
                        // Due date badge
                        _buildDueDateBadge(context, isOverdue),
                      ],
                    ),
                  ],
                ),
              ),
              // Action Menu
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onSelected: (val) {
                  if (val == 'edit') {
                    onEdit();
                  } else if (val == 'delete') {
                    onDelete();
                  } else if (val == 'toggle') {
                    onToggle();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          isCompleted
                              ? Icons.radio_button_unchecked_rounded
                              : Icons.check_circle_outline_rounded,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(isCompleted ? 'Mark Pending' : 'Mark Completed'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: AppTheme.errorColor,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Delete',
                          style: TextStyle(color: AppTheme.errorColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(TaskPriority priority) {
    final color = priority.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(priority.icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            priority.displayName,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueDateBadge(BuildContext context, bool isOverdue) {
    final formattedDate = DateFormatter.formatDate(task.dueDate);
    final badgeColor = isOverdue
        ? AppTheme.errorColor
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOverdue
            ? AppTheme.errorColor.withValues(alpha: 0.12)
            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue ? Icons.warning_amber_rounded : Icons.calendar_today_rounded,
            size: 12,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            isOverdue ? 'Overdue ($formattedDate)' : formattedDate,
            style: TextStyle(
              color: badgeColor,
              fontSize: 11,
              fontWeight: isOverdue ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
