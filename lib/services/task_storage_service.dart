import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_anagement/models/task.dart';

abstract class ITaskStorageService {
  Future<List<Task>> loadTasks();
  Future<bool> saveTasks(List<Task> tasks);
  Future<String?> loadThemeMode();
  Future<bool> saveThemeMode(String mode);
}

class TaskStorageService implements ITaskStorageService {
  static const String _tasksKey = 'user_tasks_list';
  static const String _themeModeKey = 'app_theme_mode';

  SharedPreferences? _cachedPrefs;

  TaskStorageService([this._cachedPrefs]);

  Future<SharedPreferences> _getPrefs() async {
    _cachedPrefs ??= await SharedPreferences.getInstance();
    return _cachedPrefs!;
  }

  @override
  Future<List<Task>> loadTasks() async {
    try {
      final prefs = await _getPrefs();
      final String? jsonString = prefs.getString(_tasksKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded.map((item) => Task.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      // In case of parsing error, return empty list gracefully
      return [];
    }
  }

  @override
  Future<bool> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await _getPrefs();
      final listMap = tasks.map((t) => t.toJson()).toList();
      final jsonString = jsonEncode(listMap);
      return await prefs.setString(_tasksKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> loadThemeMode() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(_themeModeKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> saveThemeMode(String mode) async {
    try {
      final prefs = await _getPrefs();
      return await prefs.setString(_themeModeKey, mode);
    } catch (e) {
      return false;
    }
  }
}
