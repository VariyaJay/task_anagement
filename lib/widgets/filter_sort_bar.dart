import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_anagement/controllers/task_controller.dart';
import 'package:task_anagement/utils/app_theme.dart';

class FilterSortBar extends StatelessWidget {
  final TextEditingController searchController;

  const FilterSortBar({
    super.key,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskController = Get.find<TaskController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Search & Sort row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: (val) => taskController.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search tasks by title...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              searchController.clear();
                              taskController.clearSearch();
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Sort menu button
              Obx(() => PopupMenuButton<TaskSortOption>(
                    tooltip: 'Sort tasks',
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.outline),
                      ),
                      child: const Icon(Icons.sort_rounded, size: 20),
                    ),
                    initialValue: taskController.currentSort.value,
                    onSelected: (option) {
                      FocusScope.of(context).unfocus();
                      taskController.setSortOption(option);
                    },
                    itemBuilder: (context) {
                      return TaskSortOption.values.map((option) {
                        final isSelected = option == taskController.currentSort.value;
                        return PopupMenuItem<TaskSortOption>(
                          value: option,
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                size: 18,
                                color: isSelected ? AppTheme.primaryColor : null,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                option.displayName,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? AppTheme.primaryColor : null,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList();
                    },
                  )),
            ],
          ),
          const SizedBox(height: 12),
          // Filter Tabs / Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(
              () => Row(
                children: TaskFilter.values.map((filter) {
                  final isSelected = taskController.currentFilter.value == filter;
                  int count;
                  switch (filter) {
                    case TaskFilter.all:
                      count = taskController.totalCount;
                      break;
                    case TaskFilter.pending:
                      count = taskController.pendingCount;
                      break;
                    case TaskFilter.completed:
                      count = taskController.completedCount;
                      break;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('${filter.displayName} ($count)'),
                      selected: isSelected,
                      onSelected: (_) {
                        FocusScope.of(context).unfocus();
                        taskController.setFilter(filter);
                      },
                      showCheckmark: false,
                      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.18),
                      backgroundColor: theme.colorScheme.surface,
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryColor : theme.colorScheme.outline,
                        width: isSelected ? 1.5 : 1,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? AppTheme.primaryColor : theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
