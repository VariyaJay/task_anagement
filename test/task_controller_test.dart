import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:task_anagement/controllers/task_controller.dart';
import 'package:task_anagement/models/task.dart';
import 'package:task_anagement/models/task_priority.dart';
import 'package:task_anagement/services/task_storage_service.dart';

class MockTaskStorageService implements ITaskStorageService {
  List<Task> storedTasks = [];
  String? storedThemeMode;

  @override
  Future<List<Task>> loadTasks() async {
    return List.from(storedTasks);
  }

  @override
  Future<bool> saveTasks(List<Task> tasks) async {
    storedTasks = List.from(tasks);
    return true;
  }

  @override
  Future<String?> loadThemeMode() async {
    return storedThemeMode;
  }

  @override
  Future<bool> saveThemeMode(String mode) async {
    storedThemeMode = mode;
    return true;
  }
}

void main() {
  group('TaskController (GetX) Business Logic Unit Tests', () {
    late MockTaskStorageService mockStorage;
    late TaskController controller;

    setUp(() {
      Get.reset();
      mockStorage = MockTaskStorageService();
      controller = TaskController(mockStorage);
      Get.put(controller);
    });

    tearDown(() {
      Get.reset();
    });

    test('1. Adding a task increases count, updates pending count, and saves to storage', () async {
      expect(controller.totalCount, 0);
      expect(controller.pendingCount, 0);

      final task = Task(
        id: 't1',
        title: 'Buy groceries',
        description: 'Milk, Eggs, Bread',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        priority: TaskPriority.high,
      );

      final result = await controller.addTask(task);

      expect(result, true);
      expect(controller.totalCount, 1);
      expect(controller.pendingCount, 1);
      expect(controller.completedCount, 0);
      expect(controller.tasks.first.title, 'Buy groceries');
      expect(mockStorage.storedTasks.length, 1);
    });

    test('2. Toggling task completion updates status and completion counters', () async {
      final task = Task(
        id: 't2',
        title: 'Submit report',
        description: 'Monthly summary',
        dueDate: DateTime.now(),
        isCompleted: false,
      );

      await controller.addTask(task);
      expect(controller.pendingCount, 1);
      expect(controller.completedCount, 0);
      expect(controller.completionRate, 0.0);

      // Toggle to completed
      await controller.toggleTaskCompletion('t2');
      expect(controller.pendingCount, 0);
      expect(controller.completedCount, 1);
      expect(controller.completionRate, 1.0);
      expect(controller.tasks.first.isCompleted, true);

      // Toggle back to pending
      await controller.toggleTaskCompletion('t2');
      expect(controller.pendingCount, 1);
      expect(controller.completedCount, 0);
      expect(controller.tasks.first.isCompleted, false);
    });

    test('3. Updating an existing task modifies its properties correctly', () async {
      final initial = Task(
        id: 't3',
        title: 'Old Title',
        description: 'Old Description',
        dueDate: DateTime(2026, 5, 1),
        priority: TaskPriority.low,
      );

      await controller.addTask(initial);

      final updated = initial.copyWith(
        title: 'Updated Title',
        description: 'New Description',
        priority: TaskPriority.high,
      );

      final result = await controller.updateTask(updated);

      expect(result, true);
      expect(controller.tasks.first.title, 'Updated Title');
      expect(controller.tasks.first.description, 'New Description');
      expect(controller.tasks.first.priority, TaskPriority.high);
    });

    test('4. Deleting a task removes it and updates stored list', () async {
      final task1 = Task(id: 't4_1', title: 'Task 1', description: '', dueDate: DateTime.now());
      final task2 = Task(id: 't4_2', title: 'Task 2', description: '', dueDate: DateTime.now());

      await controller.addTask(task1);
      await controller.addTask(task2);
      expect(controller.totalCount, 2);

      final result = await controller.deleteTask('t4_1');

      expect(result, true);
      expect(controller.totalCount, 1);
      expect(controller.tasks.any((t) => t.id == 't4_1'), false);
      expect(mockStorage.storedTasks.length, 1);
    });

    test('5. Filtering by All, Pending, and Completed works accurately', () async {
      final pendingTask = Task(
        id: 'p1',
        title: 'Pending item',
        description: '',
        dueDate: DateTime.now(),
        isCompleted: false,
      );
      final completedTask = Task(
        id: 'c1',
        title: 'Completed item',
        description: '',
        dueDate: DateTime.now(),
        isCompleted: true,
      );

      await controller.addTask(pendingTask);
      await controller.addTask(completedTask);

      // Filter: All
      controller.setFilter(TaskFilter.all);
      expect(controller.filteredTasks.length, 2);

      // Filter: Pending
      controller.setFilter(TaskFilter.pending);
      expect(controller.filteredTasks.length, 1);
      expect(controller.filteredTasks.first.id, 'p1');

      // Filter: Completed
      controller.setFilter(TaskFilter.completed);
      expect(controller.filteredTasks.length, 1);
      expect(controller.filteredTasks.first.id, 'c1');
    });

    test('6. Filter and Search query work seamlessly together', () async {
      final t1 = Task(
        id: '1',
        title: 'Fix Flutter bug',
        description: 'Resolve layout overflow',
        dueDate: DateTime.now(),
        isCompleted: false,
      );
      final t2 = Task(
        id: '2',
        title: 'Flutter UI design',
        description: 'Draft Figma mockups',
        dueDate: DateTime.now(),
        isCompleted: true,
      );
      final t3 = Task(
        id: '3',
        title: 'Backend API docs',
        description: 'Write Swagger specs',
        dueDate: DateTime.now(),
        isCompleted: false,
      );

      await controller.addTask(t1);
      await controller.addTask(t2);
      await controller.addTask(t3);

      // Search for "Flutter" with All filter
      controller.setFilter(TaskFilter.all);
      controller.setSearchQuery('Flutter');
      expect(controller.filteredTasks.length, 2);

      // Combined with Pending filter
      controller.setFilter(TaskFilter.pending);
      expect(controller.filteredTasks.length, 1);
      expect(controller.filteredTasks.first.id, '1');

      // Combined with Completed filter
      controller.setFilter(TaskFilter.completed);
      expect(controller.filteredTasks.length, 1);
      expect(controller.filteredTasks.first.id, '2');

      // Clear search
      controller.clearSearch();
      expect(controller.filteredTasks.length, 1); // 1 completed task
    });

    test('7. Sorting by due date and priority works as expected', () async {
      final earlier = Task(
        id: 's1',
        title: 'Earlier task',
        description: '',
        dueDate: DateTime(2026, 1, 1),
        priority: TaskPriority.low,
      );
      final later = Task(
        id: 's2',
        title: 'Later task',
        description: '',
        dueDate: DateTime(2026, 12, 1),
        priority: TaskPriority.high,
      );

      await controller.addTask(earlier);
      await controller.addTask(later);

      // Sort by Due Date Ascending (earliest first)
      controller.setSortOption(TaskSortOption.dueDateAsc);
      expect(controller.filteredTasks.first.id, 's1');

      // Sort by Due Date Descending (latest first)
      controller.setSortOption(TaskSortOption.dueDateDesc);
      expect(controller.filteredTasks.first.id, 's2');

      // Sort by Priority Descending (high first)
      controller.setSortOption(TaskSortOption.priorityDesc);
      expect(controller.filteredTasks.first.id, 's2'); // High priority
    });
  });
}
