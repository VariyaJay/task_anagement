import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_anagement/controllers/task_controller.dart';
import 'package:task_anagement/controllers/theme_controller.dart';
import 'package:task_anagement/models/task.dart';
import 'package:task_anagement/screens/add_edit_task_screen.dart';
import 'package:task_anagement/utils/app_theme.dart';
import 'package:task_anagement/widgets/delete_confirmation_dialog.dart';
import 'package:task_anagement/widgets/empty_state_view.dart';
import 'package:task_anagement/widgets/filter_sort_bar.dart';
import 'package:task_anagement/widgets/task_item_card.dart';
import 'package:task_anagement/widgets/task_summary_card.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TaskController taskController = Get.find<TaskController>();
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  void initState() {
    super.initState();
    if (taskController.tasks.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        taskController.loadTasks();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToAddTask() {
    FocusScope.of(context).unfocus();
    Get.to(() => const AddEditTaskScreen());
  }

  void _navigateToEditTask(Task task) {
    FocusScope.of(context).unfocus();
    Get.to(() => AddEditTaskScreen(taskToEdit: task));
  }

  Future<void> _handleDeleteTask(Task task) async {
    final confirmed = await DeleteConfirmationDialog.show(context, task.title);
    if (confirmed && mounted) {
      final success = await taskController.deleteTask(task.id);
      if (mounted) {
        if (success) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text('Task "${task.title}" deleted'),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'Undo',
                textColor: Colors.amber,
                onPressed: () {
                  taskController.addTask(task);
                },
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete task'),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.check_box_outlined,
                color: AppTheme.primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Taskify'),
          ],
        ),
        actions: [
          // Theme Toggle Button
          Obx(
            () => IconButton(
              tooltip: themeController.isDarkMode
                  ? 'Switch to Light Mode'
                  : 'Switch to Dark Mode',
              icon: Icon(
                themeController.isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
                color: themeController.isDarkMode ? Colors.amber : null,
              ),
              onPressed: () => themeController.toggleTheme(),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: Column(
            children: [
              // Dashboard Summary Card
              Obx(
                () => TaskSummaryCard(
                  totalCount: taskController.totalCount,
                  pendingCount: taskController.pendingCount,
                  completedCount: taskController.completedCount,
                  completionRate: taskController.completionRate,
                ),
              ),

              const SizedBox(height: 6),

              // Search Bar & Filter Tabs
              FilterSortBar(searchController: _searchController),

              const SizedBox(height: 10),

              // Task List or Empty State
              Expanded(
                child: Obx(() {
                  if (taskController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final tasks = taskController.filteredTasks;

                  if (tasks.isEmpty) {
                    return EmptyStateView(
                      currentFilter: taskController.currentFilter.value,
                      searchQuery: taskController.searchQuery.value,
                      onActionPressed: () {
                        if (taskController.currentFilter.value == TaskFilter.completed) {
                          taskController.setFilter(TaskFilter.all);
                        } else {
                          _navigateToAddTask();
                        }
                      },
                      onClearSearch: () {
                        _searchController.clear();
                        taskController.clearSearch();
                      },
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => taskController.loadTasks(),
                    child: ListView.builder(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.only(bottom: 88, top: 4),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return TaskItemCard(
                          key: ValueKey(task.id),
                          task: task,
                          onToggle: () => taskController.toggleTaskCompletion(task.id),
                          onEdit: () => _navigateToEditTask(task),
                          onDelete: () => _handleDeleteTask(task),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddTask,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
