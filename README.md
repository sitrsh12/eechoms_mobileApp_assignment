# ToDo — App Assignment Documentation

---

## 1. Project Summary

**Project name:** ToDo App  
**Short description:**  
A lightweight, production-minded Flutter To-Do application demonstrating a clean architecture, local persistence, responsive UI, theming, search & filtering, and smooth UI transitions.  
Built for instructional use — students can read, run, extend, and refactor the project as part of an assignment.  

**Target audience:**  
Mobile development students learning Flutter, state management (Provider), local persistence, and UI design patterns.

---

## 2. Goals and Learning Outcomes

This project is intended to teach and assess the following skills:

- Building a Flutter app with a clear separation between UI and business logic.  
- Implementing local data persistence using **shared_preferences** (JSON storage).  
- Using **Provider** for state management and exposing a simple, testable API.  
- Designing usable and presentable UIs with animations and theming.

---

## 3. Features

- Add tasks with title and optional note.  
- Edit tasks using a bottom-sheet form.  
- Mark tasks complete / undo completion with animated transitions.  
- Delete tasks via swipe or delete button.  
- Search across titles and notes.  
- Filter view: **All**, **Active**, **Done**.  
- Light / Dark theme toggle.  
- Local persistence using **shared_preferences** with JSON serialization.  
- Polished UI: cards, chips, dismissible items, animated icons.

---

## 4. Architecture Overview

The app follows a small but scalable architecture with these layers:

### **Model**
- **Todo** class: holds the data structure and handles JSON serialization.

### **Repository**
- **TodoRepository:** handles persistence (read/write).  
  Stores a single JSON array under the `todos_v1` key in SharedPreferences.  
  This layer isolates storage details.

### **State / Provider**
- **TodoProvider (extends ChangeNotifier):**  
  Exposes app operations like `load`, `add`, `update`, `toggleDone`, and `remove`.  
  Maintains in-memory state.  
  UI widgets consume provider values and call its API.

### **Presentation / UI**
- **Widgets and screens:** `HomeScreen`, `TodoFormSheet`, `_TodoCard`.  
  UI elements are kept thin and call provider methods rather than performing business logic.

### **Flow Example — Add Action**

1. User opens the add sheet and submits title/note.  
2. UI calls `TodoProvider.addTodo(title, note)`.  
3. Provider creates a new `Todo`, adds it to `_todos`, and calls `repository.saveTodos(...)`.  
4. Provider calls `notifyListeners()`, and the UI updates reactively.

This separation ensures that only `TodoRepository` interacts with storage, making code easier to maintain and test.

---

## 5. Data Model

**Todo fields:**

| Field | Type | Description |
|-------|------|-------------|
| `id` | String | Unique identifier (microseconds timestamp). |
| `title` | String | Task headline. |
| `note` | String | Optional details. |

**Serialization:**  
`toJson()` and `fromJson()` methods convert between `Todo` and `Map<String, dynamic>` for JSON encoding.

---

## 6. Persistence Details

- **Mechanism used:** `shared_preferences`  
- **Storage key:** `todos_v1`  
- **Format:** JSON array of objects, each representing a `Todo` with keys `id`, `title`, `note`, `done`, `createdAt` (ISO8601 string).  
- **Why SharedPreferences?**  
  Keeps the example simple for students.  
  Since the repository isolates storage, switching to a database like Hive requires minimal change.

---

## 7. State Management API (TodoProvider)

### **Public methods and properties:**

- `Future<void> load()` — Load saved todos from repository into memory.  
- `Future<void> addTodo(String title, {String note = ''})` — Add a new todo at the top.  
- `Future<void> updateTodo(Todo todo)` — Update an existing todo.  
- `Future<void> toggleDone(String id)` — Toggle completion; moves completed tasks to the bottom.  
- `Future<void> remove(String id)` — Delete a todo.  
- `void setSearch(String q)` — Set search query for filtering.  
- `void setFilter(TodoFilter f)` — Change filter (**All / Active / Done**).  
- `List<Todo> get visibleTodos` — Returns the filtered & searched view.

### **Implementation Notes:**

- `notifyListeners()` is used for reactive UI updates.  
- All persistence calls are async — provider awaits repository saves before notifying listeners.

---

## 8. UI Structure and Key Widgets

### **Screens / Components**

- **HomeScreen** — Main screen with AppBar, search bar, filter chips, and task list.  
  `FloatingActionButton` opens the add sheet.  
- **_buildList()** — Builds the task list with `ListView`, `Dismissible`, and `_TodoCard`.  
- **_TodoCard** — Displays a single task with animated icon and container.  
  Tap toggles done state.  
- **TodoFormSheet** — Bottom-sheet for Add/Edit with validation.

### **Design Choices**

- Animated transitions via `AnimatedContainer` and `AnimatedSwitcher`.  
- Swipe-to-delete UX using `Dismissible`.  
- Theming with `ThemeNotifier` and `ThemeMode` to toggle between light and dark modes.

---

## 9. Testing and Verification Checklist

Students should manually test and record the following before submission:

1. Launch app — verify empty state message.  
2. Add a task with title and note — task should appear.  
3. Edit the task — confirm updated values persist.  
4. Mark task done — icon changes, task animates and moves to bottom.  
5. Undo completion — task moves back to top.  
6. Swipe-to-delete or tap delete icon — task removed.  
7. Search tasks by title/note — verify correct results.  
8. Toggle filter chips (All / Active / Done) — verify list updates.  
9. Close and relaunch app — confirm tasks persist.  
10. Toggle theme — confirm look and feel changes.  
11. *(Optional)* Record a short demo (30–60 sec) showing add/edit/complete/delete/persistence.

---

## 10. Troubleshooting and Common Fixes

| Issue | Possible Fix |
|-------|---------------|
| **SharedPreferences returns null or empty list** | Check key `todos_v1` and ensure `await prefs.setString(...)` is called successfully. Review logs for JSON encode errors. |
| **Provider listeners not updating UI** | Confirm `notifyListeners()` is called and widgets use `Consumer` or `Provider.of(..., listen: true)`. |
| **Bottom sheet hidden by keyboard** | Use `MediaQuery.of(context).viewInsets.bottom` padding and set `isScrollControlled: true` in `showModalBottomSheet`. |
| **App crashes on JSON parse** | If JSON is corrupted, clear app data or reinstall while testing. |

---

## 11. Deliverables to Submit

- Complete **source code** (project folder).  
- `pubspec.yaml` showing dependencies.  
- Short **README** (1 page) with run instructions and optional demo GIF/link.  
- This **documentation file**.

---
