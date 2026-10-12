import 'package:get/get.dart';
import 'package:task_anagement/models/task.dart';
import 'package:task_anagement/models/task_priority.dart';
import 'package:task_anagement/services/task_storage_service.dart';

enum TaskFilter {
  all,
  pending,
  completed;

  String get displayName {
    switch (this) {
      case TaskFilter.all:
        return 'All';
      case TaskFilter.pending:
        return 'Pending';
      case TaskFilter.completed:
        return 'Completed';
    }
  }
}

enum TaskSortOption {
  dueDateAsc,
  dueDateDesc,
  priorityDesc,
  titleAsc;

  String get displayName {
    switch (this) {
      case TaskSortOption.dueDateAsc:
        return 'Due Date (Earliest)';
      case TaskSortOption.dueDateDesc:
        return 'Due Date (Latest)';
      case TaskSortOption.priorityDesc:
        return 'Priority (Highest)';
      case TaskSortOption.titleAsc:
        return 'Title (A-Z)';
    }
  }
}

class TaskController extends GetxController {
  final ITaskStorageService _storageService;

  final RxList<Task> tasks = <Task>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);
  final Rx<TaskFilter> currentFilter = TaskFilter.all.obs;
  final Rx<TaskSortOption> currentSort = TaskSortOption.dueDateAsc.obs;
  final RxString searchQuery = ''.obs;

  TaskController([ITaskStorageService? storageService, List<Task>? initialTasks])
      : _storageService = storageService ?? TaskStorageService() {
    if (initialTasks != null && initialTasks.isNotEmpty) {
      tasks.assignAll(initialTasks);
    }
  }

  // Getters
  int get totalCount => tasks.length;
  int get pendingCount => tasks.where((t) => !t.isCompleted).length;
  int get completedCount => tasks.where((t) => t.isCompleted).length;
  double get completionRate => totalCount == 0 ? 0.0 : (completedCount / totalCount);

  List<Task> get filteredTasks {
    List<Task> result = List.from(tasks);

    // 1. Filter by status
    switch (currentFilter.value) {
      case TaskFilter.pending:
        result = result.where((t) => !t.isCompleted).toList();
        break;
      case TaskFilter.completed:
        result = result.where((t) => t.isCompleted).toList();
        break;
      case TaskFilter.all:
        break;
    }

    // 2. Filter by search query (title or description)
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((t) {
        return t.title.toLowerCase().contains(query) ||
            t.description.toLowerCase().contains(query);
      }).toList();
    }

    // 3. Sort
    switch (currentSort.value) {
      case TaskSortOption.dueDateAsc:
        result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case TaskSortOption.dueDateDesc:
        result.sort((a, b) => b.dueDate.compareTo(a.dueDate));
        break;
      case TaskSortOption.priorityDesc:
        result.sort((a, b) {
          final priorityOrder = {
            TaskPriority.high: 3,
            TaskPriority.medium: 2,
            TaskPriority.low: 1,
          };
          final pA = priorityOrder[a.priority] ?? 0;
          final pB = priorityOrder[b.priority] ?? 0;
          final priorityCompare = pB.compareTo(pA);
          if (priorityCompare != 0) return priorityCompare;
          return a.dueDate.compareTo(b.dueDate);
        });
        break;
      case TaskSortOption.titleAsc:
        result.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }

    return result;
  }

  Future<void> loadTasks() async {
    if (tasks.isEmpty) {
      isLoading.value = true;
    }
    errorMessage.value = null;

    try {
      final loaded = await _storageService.loadTasks();
      tasks.assignAll(loaded);
    } catch (e) {
      errorMessage.value = 'Failed to load tasks: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addTask(Task task) async {
    try {
      tasks.insert(0, task);
      final success = await _storageService.saveTasks(tasks);
      if (!success) {
        errorMessage.value = 'Failed to persist new task.';
      }
      return success;
    } catch (e) {
      errorMessage.value = 'Error adding task: $e';
      return false;
    }
  }

  Future<bool> updateTask(Task updatedTask) async {
    try {
      final index = tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        tasks[index] = updatedTask;
        final success = await _storageService.saveTasks(tasks);
        if (!success) {
          errorMessage.value = 'Failed to persist task update.';
        }
        return success;
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Error updating task: $e';
      return false;
    }
  }

  Future<bool> toggleTaskCompletion(String taskId) async {
    try {
      final index = tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        final current = tasks[index];
        tasks[index] = current.copyWith(isCompleted: !current.isCompleted);
        return await _storageService.saveTasks(tasks);
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Error toggling completion: $e';
      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      final index = tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        tasks.removeAt(index);
        return await _storageService.saveTasks(tasks);
      }
      return false;
    } catch (e) {
      errorMessage.value = 'Error deleting task: $e';
      return false;
    }
  }

  void setFilter(TaskFilter filter) {
    currentFilter.value = filter;
  }

  void setSortOption(TaskSortOption option) {
    currentSort.value = option;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchQuery.value = '';
  }
}
