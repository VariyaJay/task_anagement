import 'package:flutter_test/flutter_test.dart';
import 'package:task_anagement/models/task.dart';
import 'package:task_anagement/models/task_priority.dart';

void main() {
  group('Task Model Tests', () {
    test('Task creation and default values', () {
      final dueDate = DateTime(2026, 12, 31);
      final task = Task(
        id: '1',
        title: 'Complete assignment',
        description: 'Math assignment',
        dueDate: dueDate,
      );

      expect(task.id, '1');
      expect(task.title, 'Complete assignment');
      expect(task.description, 'Math assignment');
      expect(task.dueDate, dueDate);
      expect(task.isCompleted, false);
      expect(task.priority, TaskPriority.medium);
      expect(task.createdAt, isNotNull);
    });

    test('Task serialization and deserialization (toJson & fromJson)', () {
      final task = Task(
        id: '2',
        title: 'Review PR',
        description: 'Review the frontend code',
        dueDate: DateTime(2026, 11, 20),
        isCompleted: true,
        priority: TaskPriority.high,
      );

      final json = task.toJson();
      expect(json['id'], '2');
      expect(json['title'], 'Review PR');
      expect(json['description'], 'Review the frontend code');
      expect(json['isCompleted'], true);
      expect(json['priority'], 'high');

      final deserialized = Task.fromJson(json);
      expect(deserialized.id, task.id);
      expect(deserialized.title, task.title);
      expect(deserialized.description, task.description);
      expect(deserialized.isCompleted, task.isCompleted);
      expect(deserialized.priority, task.priority);
      expect(deserialized.dueDate, task.dueDate);
    });

    test('Task copyWith updates specific fields correctly', () {
      final task = Task(
        id: '3',
        title: 'Original Title',
        description: 'Original Description',
        dueDate: DateTime(2026, 10, 15),
        priority: TaskPriority.low,
      );

      final updated = task.copyWith(
        title: 'Updated Title',
        isCompleted: true,
        priority: TaskPriority.high,
      );

      expect(updated.id, '3');
      expect(updated.title, 'Updated Title');
      expect(updated.description, 'Original Description');
      expect(updated.isCompleted, true);
      expect(updated.priority, TaskPriority.high);
    });

    test('Task overdue status calculation', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 2));
      final futureDate = DateTime.now().add(const Duration(days: 2));

      final overdueTask = Task(
        id: '4',
        title: 'Overdue task',
        description: '',
        dueDate: pastDate,
        isCompleted: false,
      );

      final completedPastTask = Task(
        id: '5',
        title: 'Completed past task',
        description: '',
        dueDate: pastDate,
        isCompleted: true,
      );

      final futureTask = Task(
        id: '6',
        title: 'Future task',
        description: '',
        dueDate: futureDate,
        isCompleted: false,
      );

      expect(overdueTask.isOverdue, true);
      expect(completedPastTask.isOverdue, false);
      expect(futureTask.isOverdue, false);
    });
  });
}
