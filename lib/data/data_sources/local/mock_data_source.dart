import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskflow/data/data_sources/local/mock_scenerio.dart';
import 'package:taskflow/data/models/auth_model.dart';
import 'package:taskflow/data/models/comment_model.dart';
import 'package:taskflow/data/models/notifications_model.dart';
import 'package:taskflow/data/models/organizations_model.dart';
import 'package:taskflow/data/models/project_model.dart';
import 'package:taskflow/data/models/task_model.dart';
import 'package:taskflow/data/models/user_model.dart';

class MockDataSource {
  static const String _assetPath = 'assets/mock/mock-data.json';
  static const String _projectsStorageKey = 'saved_projects';
  static const String _tasksStorageKey = 'saved_tasks';
  static const String _commentsStorageKey = 'saved_comments';
  static const String _notificationsStorageKey = 'saved_notifications';

  MockScenario scenario = MockScenario.normal;
  Map<String, dynamic>? _data;
  List<ProjectModel>? _projects;

  Future<void> _ensureLoaded() async {
    if (_data != null) return;

    final jsonString = await rootBundle.loadString(_assetPath);

    _data = json.decode(jsonString) as Map<String, dynamic>;
  }

  Future<List<OrganizationModel>> getOrganizations() async {
    await _ensureLoaded();

    final organizations = _data!['organizations'] as List;

    return organizations
        .map((item) => OrganizationModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> _simulateScenario({
    bool allowNotFound = false,
    bool allowValidation = false,
  }) async {
    switch (scenario) {
      case MockScenario.normal:
        return;

      case MockScenario.offline:
        throw Exception('OFFLINE');

      case MockScenario.timeout:
        await Future.delayed(const Duration(seconds: 3));
        throw TimeoutException('Mock request timed out.');

      case MockScenario.notFound:
        if (allowNotFound) {
          throw Exception('NOT_FOUND');
        }
        return;

      case MockScenario.validationError:
        if (allowValidation) {
          throw Exception('VALIDATION_ERROR');
        }
        return;
    }
  }

  Future<List<UserModel>> getUsers() async {
    await _ensureLoaded();

    final users = _data!['users'] as List;

    return users
        .map((item) => UserModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<OrgMemberModel>> getOrgMembers() async {
    await _ensureLoaded();

    final members = _data!['org_members'] as List;

    return members
        .map((item) => OrgMemberModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProjectModel>> getProjects() async {
    await _simulateScenario(allowNotFound: true);
    if (_projects != null) {
      return List.unmodifiable(_projects!);
    }

    final preferences = await SharedPreferences.getInstance();

    final savedProjects = preferences.getString(_projectsStorageKey);

    if (savedProjects != null) {
      final decoded = jsonDecode(savedProjects) as List;

      _projects = decoded
          .map((item) => ProjectModel.fromMap(item as Map<String, dynamic>))
          .toList();

      return List.unmodifiable(_projects!);
    }

    await _ensureLoaded();

    final data = _data!['projects'] as List;

    _projects = data
        .map((item) => ProjectModel.fromMap(item as Map<String, dynamic>))
        .toList();

    await _saveProjects();

    return List.unmodifiable(_projects!);
  }

  Future<void> _saveProjects() async {
    final preferences = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      _projects!.map((project) => project.toMap()).toList(),
    );

    await preferences.setString(_projectsStorageKey, encoded);
  }

  Future<ProjectModel> createProject(ProjectModel project) async {
    await _simulateScenario(allowValidation: true);
    await getProjects();

    _projects!.add(project);
    await _saveProjects();

    return project;
  }

  Future<ProjectModel> updateProject(ProjectModel project) async {
    await _simulateScenario(allowValidation: true);
    await getProjects();

    final index = _projects!.indexWhere((item) => item.id == project.id);

    if (index == -1) {
      throw Exception('Project not found.');
    }

    _projects![index] = project;
    await _saveProjects();

    return project;
  }

  Future<void> deleteProject(String projectId) async {
    await getProjects();

    final index = _projects!.indexWhere((project) => project.id == projectId);

    if (index == -1) {
      throw Exception('Project not found.');
    }

    _projects!.removeAt(index);
    await _saveProjects();
  }

  Future<List<TaskModel>> getTasks() async {
    await _simulateScenario(allowNotFound: true);
    final preferences = await SharedPreferences.getInstance();

    final savedTasks = preferences.getString(_tasksStorageKey);

    if (savedTasks != null) {
      final decoded = jsonDecode(savedTasks) as List;

      return decoded
          .map((item) => TaskModel.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    await _ensureLoaded();

    final tasks = _data!['tasks'] as List;

    final taskList = tasks
        .map((item) => TaskModel.fromMap(item as Map<String, dynamic>))
        .toList();

    await _saveTasks(taskList);

    return taskList;
  }

  Future<void> _saveTasks(List<TaskModel> tasks) async {
    final preferences = await SharedPreferences.getInstance();

    final encoded = jsonEncode(tasks.map((task) => task.toMap()).toList());

    await preferences.setString(_tasksStorageKey, encoded);
  }

  Future<TaskModel> createTask(TaskModel task) async {
    await _simulateScenario(allowValidation: true);
    final tasks = await getTasks();

    tasks.add(task);

    await _saveTasks(tasks);

    return task;
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    await _simulateScenario(allowValidation: true);
    final tasks = await getTasks();

    final index = tasks.indexWhere((item) => item.id == task.id);

    if (index == -1) {
      throw Exception('Task not found.');
    }

    tasks[index] = task;

    await _saveTasks(tasks);

    return task;
  }

  Future<void> deleteTask(String taskId) async {
    final tasks = await getTasks();

    final index = tasks.indexWhere((task) => task.id == taskId);

    if (index == -1) {
      throw Exception('Task not found.');
    }

    tasks.removeAt(index);

    await _saveTasks(tasks);
  }

  Future<List<CommentModel>> getComments() async {
    final preferences = await SharedPreferences.getInstance();

    final savedComments = preferences.getString(_commentsStorageKey);

    if (savedComments != null) {
      final decoded = jsonDecode(savedComments) as List;

      return decoded
          .map((item) => CommentModel.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    await _ensureLoaded();

    final comments = _data!['comments'] as List;

    final commentList = comments
        .map((item) => CommentModel.fromMap(item as Map<String, dynamic>))
        .toList();

    await _saveComments(commentList);

    return commentList;
  }

  Future<void> _saveComments(List<CommentModel> comments) async {
    final preferences = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      comments.map((comment) => comment.toMap()).toList(),
    );

    await preferences.setString(_commentsStorageKey, encoded);
  }

  Future<CommentModel> createComment(CommentModel comment) async {
    final comments = await getComments();

    comments.add(comment);

    await _saveComments(comments);

    return comment;
  }

  Future<CommentModel> updateComment(CommentModel comment) async {
    final comments = await getComments();

    final index = comments.indexWhere((item) => item.id == comment.id);

    if (index == -1) {
      throw Exception('Comment not found.');
    }

    comments[index] = comment;

    await _saveComments(comments);

    return comment;
  }

  Future<void> deleteComment(String commentId) async {
    final comments = await getComments();

    final index = comments.indexWhere((comment) => comment.id == commentId);

    if (index == -1) {
      throw Exception('Comment not found.');
    }

    comments.removeAt(index);

    await _saveComments(comments);
  }

  Future<List<NotificationModel>> getNotifications() async {
    final preferences = await SharedPreferences.getInstance();

    final savedNotifications = preferences.getString(_notificationsStorageKey);

    if (savedNotifications != null) {
      final decoded = jsonDecode(savedNotifications) as List;

      return decoded
          .map(
            (item) => NotificationModel.fromMap(item as Map<String, dynamic>),
          )
          .toList();
    }

    await _ensureLoaded();

    final notifications = _data!['notifications'] as List;

    final notificationList = notifications
        .map((item) => NotificationModel.fromMap(item as Map<String, dynamic>))
        .toList();

    await _saveNotifications(notificationList);

    return notificationList;
  }

  Future<void> _saveNotifications(List<NotificationModel> notifications) async {
    final preferences = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      notifications.map((notification) => notification.toMap()).toList(),
    );

    await preferences.setString(_notificationsStorageKey, encoded);
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final notifications = await getNotifications();

    final index = notifications.indexWhere(
      (notification) => notification.id == notificationId,
    );

    if (index == -1) {
      throw Exception('Notification not found.');
    }

    notifications[index] = notifications[index].copyWith(read: true);

    await _saveNotifications(notifications);
  }

  Future<void> deleteNotification(String notificationId) async {
    final notifications = await getNotifications();

    final index = notifications.indexWhere(
      (notification) => notification.id == notificationId,
    );

    if (index == -1) {
      throw Exception('Notification not found.');
    }

    notifications.removeAt(index);

    await _saveNotifications(notifications);
  }

  Future<List<AuthCredentialModel>> getAuthCredentials() async {
    await _ensureLoaded();

    final authMock = _data!['auth_mock'] as Map<String, dynamic>;
    final credentials = authMock['test_credentials'] as List;

    return credentials
        .map(
          (item) => AuthCredentialModel.fromMap(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<MockLoginResponseModel> getMockLoginResponse() async {
    await _ensureLoaded();

    final authMock = _data!['auth_mock'] as Map<String, dynamic>;

    return MockLoginResponseModel.fromMap(
      authMock['mock_login_response'] as Map<String, dynamic>,
    );
  }
}
