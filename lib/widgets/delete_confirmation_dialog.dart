import 'package:flutter/material.dart';
import 'package:task_anagement/utils/app_theme.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String taskTitle;

  const DeleteConfirmationDialog({
    super.key,
    required this.taskTitle,
  });

  static Future<bool> show(BuildContext context, String taskTitle) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(taskTitle: taskTitle),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: AppTheme.errorColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Delete Task',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to delete "$taskTitle"? This action cannot be undone.',
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          fontSize: 14,
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.errorColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text(
            'Delete',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
