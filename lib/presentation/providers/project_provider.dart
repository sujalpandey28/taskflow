import 'package:flutter/foundation.dart';
import 'package:taskflow/data/models/project_model.dart';
import 'package:taskflow/data/repositories/task_flowrepository.dart';

enum ProjectStatus { initial, loading, success, error }

class ProjectProvider extends ChangeNotifier {
  final TaskFlowRepository repository;

  ProjectProvider({required this.repository});

  ProjectStatus _status = ProjectStatus.initial;

  ProjectStatus get status => _status;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  List<ProjectModel> _projects = [];

  List<ProjectModel> get projects => List.unmodifiable(_projects);

  Future<void> loadProjects(String orgId) async {
    _status = ProjectStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final projects = await repository.getProjects(orgId);

      final updatedProjects = <ProjectModel>[];

      for (final project in projects) {
        final tasks = await repository.getTasks(project.id);

        updatedProjects.add(project.copyWith(taskCount: tasks.length));
      }

      _projects = updatedProjects;

      _status = ProjectStatus.success;
    } catch (e) {
      _status = ProjectStatus.error;
      _errorMessage = 'Failed to load projects.';
    }

    notifyListeners();
  }

  Future<bool> createProject({
    required ProjectModel project,
    required bool isAdmin,
  }) async {
    if (!isAdmin) {
      _errorMessage = 'Only organization admins can create projects.';
      notifyListeners();
      return false;
    }

    try {
      final createdProject = await repository.createProject(project);

      _projects.add(createdProject);

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to create project.';
      notifyListeners();

      return false;
    }
  }

  Future<bool> updateProject({
    required ProjectModel project,
    required bool isAdmin,
  }) async {
    if (!isAdmin) {
      _errorMessage = 'Only organization admins can update projects.';
      notifyListeners();
      return false;
    }

    try {
      final updatedProject = await repository.updateProject(project);

      final index = _projects.indexWhere((item) => item.id == project.id);

      if (index != -1) {
        _projects[index] = updatedProject;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update project.';
      notifyListeners();

      return false;
    }
  }

  Future<bool> deleteProject({
    required String projectId,
    required bool isAdmin,
  }) async {
    if (!isAdmin) {
      _errorMessage = 'Only organization admins can delete projects.';
      notifyListeners();
      return false;
    }

    try {
      await repository.deleteProject(projectId);

      _projects.removeWhere((project) => project.id == projectId);

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete project.';
      notifyListeners();

      return false;
    }
  }

  ProjectModel? getProjectById(String projectId) {
    try {
      return _projects.firstWhere((project) => project.id == projectId);
    } catch (_) {
      return null;
    }
  }

  void clearProjects() {
    _projects = [];
    _status = ProjectStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
