import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:task_anagement/models/task.dart';
import 'package:task_anagement/models/task_priority.dart';
import 'package:task_anagement/controllers/task_controller.dart';
import 'package:task_anagement/utils/app_theme.dart';
import 'package:task_anagement/utils/date_formatter.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? taskToEdit;

  const AddEditTaskScreen({super.key, this.taskToEdit});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDueDate;
  late TaskPriority _selectedPriority;
  late bool _isCompleted;
  bool _isSaving = false;

  bool get isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _selectedDueDate = task?.dueDate ?? DateTime.now();
    _selectedPriority = task?.priority ?? TaskPriority.medium;
    _isCompleted = task?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final initial = _selectedDueDate.isBefore(DateTime(now.year, now.month, now.day - 365))
        ? now
        : _selectedDueDate;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDueDate = pickedDate;
      });
    }
  }

  Future<void> _saveTask() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (title.isEmpty || description.isEmpty) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final taskController = Get.find<TaskController>();
    bool success;

    if (isEditing) {
      final updatedTask = widget.taskToEdit!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _selectedDueDate,
        priority: _selectedPriority,
        isCompleted: _isCompleted,
      );
      success = await taskController.updateTask(updatedTask);
    } else {
      final newTask = Task(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _selectedDueDate,
        priority: _selectedPriority,
        isCompleted: false,
      );
      success = await taskController.addTask(newTask);
    }

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? 'Task updated successfully!' : 'Task created successfully!',
          ),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(taskController.errorMessage.value ?? 'Failed to save task. Please try again.'),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: _isSaving ? null : _saveTask,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded, color: AppTheme.primaryColor),
              label: Text(
                'Save',
                style: TextStyle(
                  color: _isSaving ? Colors.grey : AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Field
                const Text(
                  'Task Title *',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  autofocus: false,
                  textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'e.g. Finish quarterly project report',
                  prefixIcon: Icon(Icons.title_rounded, size: 20),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  if (value.trim().length < 3) {
                    return 'Title must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description Field
              const Text(
                'Description *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Add details, subtasks, or reference links...',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Due Date Selector
              const Text(
                'Due Date *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _pickDueDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.inputDecorationTheme.fillColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded,
                          size: 20, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          DateFormatter.formatDetailed(_selectedDueDate),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          DateFormatter.formatDate(_selectedDueDate),
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Priority Selector
              const Text(
                'Priority',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                children: TaskPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  final pColor = priority.color;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _selectedPriority = priority;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? pColor.withValues(alpha: 0.15)
                                : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? pColor : theme.colorScheme.outline,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(priority.icon,
                                  color: isSelected ? pColor : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  size: 18),
                              const SizedBox(height: 4),
                              Text(
                                priority.displayName,
                                style: TextStyle(
                                  color: isSelected ? pColor : theme.colorScheme.onSurface,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              if (isEditing) ...[
                const SizedBox(height: 24),
                // Status Switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: _isCompleted
                                ? AppTheme.successColor
                                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _isCompleted ? 'Status: Completed' : 'Status: Pending',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isCompleted,
                        activeTrackColor: AppTheme.successColor,
                        onChanged: (val) {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _isCompleted = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 36),

              // Bottom Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isSaving ? null : _saveTask,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEditing ? 'Update Task' : 'Create Task',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
