import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_anagement/services/task_storage_service.dart';

class ThemeController extends GetxController {
  final ITaskStorageService _storageService;
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  ThemeController([ITaskStorageService? storageService, String? initialMode])
      : _storageService = storageService ?? TaskStorageService() {
    if (initialMode != null) {
      _applyMode(initialMode);
    }
  }

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  void _applyMode(String mode) {
    switch (mode) {
      case 'dark':
        themeMode.value = ThemeMode.dark;
        break;
      case 'light':
        themeMode.value = ThemeMode.light;
        break;
      case 'system':
      default:
        themeMode.value = ThemeMode.system;
        break;
    }
  }

  Future<void> loadThemeMode() async {
    final savedMode = await _storageService.loadThemeMode();
    if (savedMode != null) {
      _applyMode(savedMode);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    String modeString = 'system';
    if (mode == ThemeMode.dark) modeString = 'dark';
    if (mode == ThemeMode.light) modeString = 'light';
    await _storageService.saveThemeMode(modeString);
  }

  void toggleTheme() {
    if (themeMode.value == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }
}
