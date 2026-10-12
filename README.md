<div align="center">

# 📋 Taskify — Task Management Application

**A modern, robust, and reactive Task Management ecosystem built with Flutter & GetX.**

[![Flutter Version](https://img.shields.io/badge/Flutter-v3.44.8-blue.svg?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-v3.12.2-0175C2.svg?logo=dart)](https://dart.dev)
[![State Management](https://img.shields.io/badge/State_Management-GetX_v4.7.3-8A2BE2.svg)](https://pub.dev/packages/get)
[![Tests Status](https://img.shields.io/badge/Tests-12%2F12_Passed-success.svg)](https://flutter.dev)
[![Platform Support](https://img.shields.io/badge/Platforms-Android%20%7C%20Windows%20%7C%20iOS%20%7C%20Web-orange.svg)](#)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](#)

<p align="center">
  <a href="#-key-features">Key Features</a> •
  <a href="#-architecture--design-patterns">Architecture</a> •
  <a href="#-tech-stack--dependencies">Tech Stack</a> •
  <a href="#-getting-started">Getting Started</a> •
  <a href="#-state-management--storage-mechanics">Mechanics</a> •
  <a href="#-test-suite">Test Suite</a>
</p>

---

</div>

## 🌟 Overview

**Taskify** is an enterprise-ready, cross-platform productivity application designed with performance, visual ergonomics, and maintainability at its core. Engineered on a decoupled **Layered Architecture** and powered by **GetX reactive programming**, Taskify offers instantaneous responsiveness, local persistence, real-time multi-filter queries, customizable priority queues, and dynamic theme switching.

---

## 🚀 Key Features

| Category | Capability | Description |
| :--- | :--- | :--- |
| **Task Management** | **Full CRUD Pipeline** | Create, inspect, update, and remove tasks with zero UI latency. |
| **Reactive Dashboard** | **Live Metrics Card** | Real-time visual progress bar tracking Total, Pending, and Completed tasks with dynamic completion percentages. |
| **Search & Filtering** | **Synchronized Multi-Filter** | Real-time substring search by title or description combined with status tabs (**All**, **Pending**, **Completed**) and item counters. |
| **Priority Hierarchy** | **Three-Tier Priority Queue** | Color-coded urgency levels: **Low** (Emerald), **Medium** (Amber), and **High** (Crimson) with custom visual indicators. |
| **Schedule & Deadlines** | **Relative Due Date & Overdue Radar** | Contextual date formatting (*Today*, *Tomorrow*, *Weekday*, *Date*) with dedicated overdue warning badges for past-due items. |
| **Data Integrity** | **Strict Form Validation** | Guaranteed non-empty title and description validation before state commitment. |
| **Ergonomics & Safety** | **Undo Safeguard & Deletion Prompts** | Modal confirmation prompt for task removal accompanied by a 2-second floating Undo snackbar. |
| **Keyboard UX** | **Intelligent Unfocus Mechanism** | Auto-dismisses keyboard on scroll, background tap, priority selection, or date picking to prevent viewport obstruction. |
| **Aesthetics & Theme** | **Material 3 Adaptive Theme** | Seamless switching between modern Indigo Light Mode and deep Slate Dark Mode, persisted across sessions. |
| **Startup Performance** | **Parallel Pre-Load Pipeline** | Zero-flash startup utilizing parallelized `Future.wait` storage hydration and in-memory preferences caching. |

---

## 🏗️ Architecture & Design Patterns

The codebase strictly adheres to **Separation of Concerns (SoC)** and **Clean Architecture Principles**, partitioning business rules, presentation logic, and persistent storage into distinct layers.

```
lib/
├── 📁 controllers/          # Business logic & reactive state management (GetxController)
│   ├── task_controller.dart     # Task state, sorting, filtering, and query mutations
│   └── theme_controller.dart    # Theme mode observables and persistence handlers
├── 📁 models/               # Domain entities & serialization contracts
│   ├── task.dart                # Task entity, copyWith, overdue computation, JSON mapping
│   └── task_priority.dart       # Priority enumerations, color palettes, and icons
├── 📁 services/             # Low-level infrastructure & storage abstraction
│   └── task_storage_service.dart# SharedPreferences adapter with in-memory caching
├── 📁 screens/              # Top-level viewport presentations
│   ├── task_list_screen.dart    # Main dashboard, search bar, and task list view
│   └── add_edit_task_screen.dart# Validated form screen for task creation & editing
├── 📁 widgets/              # Reusable, atomic UI components
│   ├── task_summary_card.dart   # Visual progress indicator & counter overview
│   ├── task_item_card.dart      # Task list tile with completion toggle & action menu
│   ├── filter_sort_bar.dart     # Search field, sorting popup, and filter chips
│   ├── empty_state_view.dart    # Context-aware empty state illustrations
│   └── delete_confirmation_dialog.dart # Safety dialog preventing accidental loss
├── 📁 utils/                # Styling constants and formatters
│   ├── app_theme.dart           # Light & Dark Material 3 theme configurations
│   └── date_formatter.dart      # Relative date logic and locale formatters
└── main.dart                # Application entrypoint & dependency injection setup
```

### Architectural Decisions

1. **GetX State Management (`GetxController` + `Obx`)**:
   - Eliminates unnecessary widget tree rebuilds by isolating reactivity to granular `Obx` boundaries.
   - Decouples logic from `BuildContext`, allowing clean dependency injection via `Get.put()` and `Get.find()`.
2. **Repository / Service Abstraction**:
   - Data operations conform to the `ITaskStorageService` interface. This shields business logic from storage implementation details and facilitates straightforward unit testing with mock services.
3. **Optimized Startup Caching**:
   - `SharedPreferences.getInstance()` is initialized once and retained in memory, preventing redundant platform-channel invocations. Both theme preferences and task registries hydrate concurrently via `Future.wait`.

---

## 📦 Tech Stack & Dependencies

| Package | Version | Architectural Responsibility |
| :--- | :--- | :--- |
| [**`get`**](https://pub.dev/packages/get) | `^4.7.3` | Reactive state management (`Rx`, `Obx`), dependency injection (`Get.put`), and route transitions. |
| [**`shared_preferences`**](https://pub.dev/packages/shared_preferences) | `^2.5.6` | Lightweight, asynchronous on-device key-value persistence. |
| [**`intl`**](https://pub.dev/packages/intl) | `^0.20.3` | Localized date representations, relative calendar parsing, and display formats. |
| [**`uuid`**](https://pub.dev/packages/uuid) | `^4.6.0` | Cryptographically strong UUID v4 generation ensuring zero key collisions in widget trees and stores. |
| [**`cupertino_icons`**](https://pub.dev/packages/cupertino_icons) | `^1.0.8` | Adaptive iconography set for platform consistency. |
| [**`flutter_lints`**](https://pub.dev/packages/flutter_lints) | `^6.0.0` | Static analysis rules enforcing strict Dart/Flutter idioms. |

---

## ⚡ Getting Started

### Prerequisites
- **Flutter SDK**: `v3.44.8` or newer
- **Dart SDK**: `v3.12.2` or newer
- **Platform Targets**: Android SDK (API 21+), Windows 10/11, iOS, or Web

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/task_management.git
   cd task_management
   ```

2. **Fetch dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify static analysis & code health**:
   ```bash
   flutter analyze
   ```

4. **Execute test suite**:
   ```bash
   flutter test
   ```

5. **Run the application**:
   ```bash
   # Development Debug Mode
   flutter run

   # Production Optimized Release Mode (Instant Startup)
   flutter run --release
   ```

---

## ⚙️ State Management & Storage Mechanics

```
┌────────────────────────────────────────────────────────┐
│                      UI Screens                        │
│   (TaskListScreen, AddEditTaskScreen, SummaryCard)     │
└──────────────┬───────────────────────────▲─────────────┘
               │ User Action               │ Obx Rebuild
               ▼                           │
┌──────────────────────────────────────────┴─────────────┐
│                 TaskController (GetX)                  │
│       • tasks (RxList)        • currentFilter (Rx)     │
│       • isLoading (RxBool)    • searchQuery (RxString) │
└──────────────┬─────────────────────────────────────────┘
               │ Persist JSON
               ▼
┌────────────────────────────────────────────────────────┐
│            TaskStorageService (Cached Prefs)           │
│       • In-Memory Cache       • SharedPreferences      │
└────────────────────────────────────────────────────────┘
```

### 1. How State Management Operates
- State is modeled reactively using GetX observables (`.obs`).
- When an interaction occurs (e.g., toggling a task, updating search criteria, or altering priority):
  1. The UI invokes the corresponding method on `TaskController`.
  2. The controller updates the internal `Rx` variables.
  3. All listening `Obx` widgets automatically rebuild only their specific sub-tree, achieving **60/120 FPS performance**.

### 2. How Local Persistence Operates
- Tasks serialize into compact JSON structures upon every modification.
- Storage operations run asynchronously on the background I/O thread, ensuring the main UI thread remains completely unblocked.
- On cold boot, data hydrates in parallel before widget inflation, resulting in an immediate first frame with zero loading flicker.

---

## 🧪 Test Suite

The test suite validates data serialization, state controller mutations, search/filter algorithms, and widget rendering.

```bash
flutter test
```

### Test Coverage Highlights

- ✅ **Model Integrity Tests** (`test/task_model_test.dart`):
  - Default property assignment and instantiation.
  - Bidirectional JSON serialization (`toJson` / `fromJson`).
  - Immutable state copying (`copyWith`).
  - Dynamic overdue status logic based on timestamps.
- ✅ **Controller Business Logic Tests** (`test/task_controller_test.dart`):
  - Task creation, count increments, and store synchronization.
  - Completion toggling, rate computation, and counter metrics.
  - Entity property updates and mutation verification.
  - Safe task deletion and list pruning.
  - Status filtering (**All**, **Pending**, **Completed**).
  - Multi-criteria queries combining search tokens with active status filters.
  - Priority and chronological sorting configurations.
- ✅ **Widget Smoke Tests** (`test/widget_test.dart`):
  - Application tree initialization and controller bindings.
  - Header and overview widget presence.
  - Contextual empty state display and action button presence.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
