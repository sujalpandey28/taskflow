import 'package:taskflow/data/data_sources/local/mock_data_source.dart';
import 'package:taskflow/data/models/auth_model.dart';
import 'package:taskflow/data/models/comment_model.dart';
import 'package:taskflow/data/models/notifications_model.dart';
import 'package:taskflow/data/models/organizations_model.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

class TaskFlowRepository {
  final MockDataSource dataSource;

  TaskFlowRepository({required this.dataSource});

  Future<List<AuthCredentialModel>> getAuthCredentials() {
    return dataSource.getAuthCredentials();
  }

  Future<MockLoginResponseModel> getMockLoginResponse() {
    return dataSource.getMockLoginResponse();
  }

  Future<List<OrganizationModel>> getOrganizations() {
    return dataSource.getOrganizations();
  }

  Future<List<UserModel>> getUsers() {
    return dataSource.getUsers();
  }

  Future<List<OrgMemberModel>> getOrgMembers() {
    return dataSource.getOrgMembers();
  }

  // Future<List<ProjectModel>> getProjects(String orgId) async {
  //   final projects = await dataSource.getProjects();

  //   return projects.where((project) => project.orgId == orgId).toList();
  // }

  Future<List<ProjectModel>> getProjects(String orgId) async {
    final projects = await dataSource.getProjects();

    // debugPrint('REQUESTED ORG: $orgId');
    // debugPrint('TOTAL PROJECTS: ${projects.length}');

    // for (final project in projects) {
    //   // debugPrint('PROJECT ${project.id} -> ORG ${project.orgId}');
    // }

    final filteredProjects = projects
        .where((project) => project.orgId == orgId)
        .toList();

    // debugPrint('FILTERED PROJECTS: ${filteredProjects.length}');

    return filteredProjects;
  }

  Future<ProjectModel> createProject(ProjectModel project) {
    return dataSource.createProject(project);
  }

  Future<ProjectModel> updateProject(ProjectModel project) {
    return dataSource.updateProject(project);
  }

  Future<void> deleteProject(String projectId) {
    return dataSource.deleteProject(projectId);
  }

  Future<List<TaskModel>> getTasks(String projectId) async {
    final tasks = await dataSource.getTasks();

    return tasks.where((task) => task.projectId == projectId).toList();
  }

  Future<TaskModel> createTask(TaskModel task) {
    return dataSource.createTask(task);
  }

  Future<TaskModel> updateTask(TaskModel task) {
    return dataSource.updateTask(task);
  }

  Future<void> deleteTask(String taskId) {
    return dataSource.deleteTask(taskId);
  }

  Future<List<CommentModel>> getComments(String taskId) async {
    final comments = await dataSource.getComments();

    return comments.where((comment) => comment.taskId == taskId).toList();
  }

  Future<CommentModel> createComment(CommentModel comment) {
    return dataSource.createComment(comment);
  }

  Future<CommentModel> updateComment(CommentModel comment) {
    return dataSource.updateComment(comment);
  }

  Future<void> deleteComment(String commentId) {
    return dataSource.deleteComment(commentId);
  }

  Future<List<NotificationModel>> getNotifications(String userId) async {
    final notifications = await dataSource.getNotifications();

    return notifications
        .where((notification) => notification.userId == userId)
        .toList();
  }

  Future<void> markNotificationAsRead(String notificationId) {
    return dataSource.markNotificationAsRead(notificationId);
  }

  Future<void> deleteNotification(String notificationId) {
    return dataSource.deleteNotification(notificationId);
  }
}
