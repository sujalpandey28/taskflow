import 'package:flutter/foundation.dart';
import 'package:taskflow/data/models/task_model.dart';
import 'package:taskflow/data/repositories/task_flowrepository.dart';

enum TaskStatus { initial, loading, success, error }

class TaskProvider extends ChangeNotifier {
  final TaskFlowRepository repository;

  TaskProvider({required this.repository});

  TaskStatus _status = TaskStatus.initial;

  TaskStatus get status => _status;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  List<TaskModel> _tasks = [];

  List<TaskModel> get tasks => List.unmodifiable(_tasks);

  String? _statusFilter;
  String? _priorityFilter;
  bool _sortByDueDate = false;
  String? get statusFilter => _statusFilter;

  String? get priorityFilter => _priorityFilter;

  bool get sortByDueDate => _sortByDueDate;

  List<TaskModel> get filteredTasks {
    List<TaskModel> result = List.from(_tasks);

    if (_statusFilter != null) {
      result = result.where((task) => task.status == _statusFilter).toList();
    }

    if (_priorityFilter != null) {
      result = result
          .where((task) => task.priority == _priorityFilter)
          .toList();
    }

    if (_sortByDueDate) {
      result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    }

    return result;
  }

  Future<void> loadTasks(String projectId) async {
    _status = TaskStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await repository.getTasks(projectId);

      _status = TaskStatus.success;
    } catch (e) {
      _status = TaskStatus.error;
      _errorMessage = 'Failed to load tasks.';
    }

    notifyListeners();
  }

  Future<bool> createTask(TaskModel task) async {
    try {
      _errorMessage = null;

      await repository.createTask(task);

      // Add immediately to the current list.
      _tasks.add(task);

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to create task.';
      notifyListeners();

      return false;
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    try {
      _errorMessage = null;

      await repository.updateTask(task);

      final index = _tasks.indexWhere((item) => item.id == task.id);

      if (index != -1) {
        _tasks[index] = task;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update task.';
      notifyListeners();

      return false;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      _errorMessage = null;

      await repository.deleteTask(taskId);

      _tasks.removeWhere((task) => task.id == taskId);

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete task.';
      notifyListeners();

      return false;
    }
  }

  TaskModel? getTaskById(String taskId) {
    try {
      return _tasks.firstWhere((task) => task.id == taskId);
    } catch (_) {
      return null;
    }
  }

  void setStatusFilter(String? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setPriorityFilter(String? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void setSortByDueDate(bool value) {
    _sortByDueDate = value;
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _priorityFilter = null;
    _sortByDueDate = false;
    notifyListeners();
  }

  void clearTasks() {
    _tasks = [];
    _status = TaskStatus.initial;
    _errorMessage = null;
    _statusFilter = null;
    _priorityFilter = null;
    _sortByDueDate = false;
    notifyListeners();
  }
}
