import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_anagement/controllers/task_controller.dart';
import 'package:task_anagement/controllers/theme_controller.dart';
import 'package:task_anagement/screens/task_list_screen.dart';
import 'package:task_anagement/services/task_storage_service.dart';
import 'package:task_anagement/utils/app_theme.dart';

void main() {
  testWidgets('Task Management App smoke test (GetX)', (WidgetTester tester) async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    final storageService = TaskStorageService();
    Get.put(ThemeController(storageService));
    Get.put(TaskController(storageService));

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        home: const TaskListScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify app bar title
    expect(find.text('Taskify'), findsOneWidget);

    // Verify task overview card
    expect(find.text('Task Overview'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);

    // Verify initial empty state
    expect(find.text('No tasks yet'), findsOneWidget);
    expect(find.text('Create a Task'), findsNothing);

    // Verify Floating Action Button is present
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('New Task'), findsOneWidget);

    Get.reset();
  });
}
