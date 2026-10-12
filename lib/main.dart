import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_anagement/controllers/task_controller.dart';
import 'package:task_anagement/controllers/theme_controller.dart';
import 'package:task_anagement/models/task.dart';
import 'package:task_anagement/screens/task_list_screen.dart';
import 'package:task_anagement/services/task_storage_service.dart';
import 'package:task_anagement/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences once
  final prefs = await SharedPreferences.getInstance();
  final storageService = TaskStorageService(prefs);

  // Parallel pre-loading of theme and tasks
  final results = await Future.wait([
    storageService.loadThemeMode(),
    storageService.loadTasks(),
  ]);

  final savedThemeMode = results[0] as String?;
  final initialTasks = results[1] as List<Task>;

  // Register controllers with GetX Dependency Injection
  Get.put<ITaskStorageService>(storageService);
  final themeController = Get.put(ThemeController(storageService, savedThemeMode));
  Get.put(TaskController(storageService, initialTasks));

  runApp(TaskManagementApp(themeController: themeController));
}

class TaskManagementApp extends StatelessWidget {
  final ThemeController themeController;

  const TaskManagementApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        title: 'Task Management',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode.value,
        home: const TaskListScreen(),
      ),
    );
  }
}
