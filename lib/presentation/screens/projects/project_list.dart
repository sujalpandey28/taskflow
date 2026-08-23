import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskflow/data/models/project_model.dart';
import 'package:taskflow/presentation/screens/projects/project_form_screen.dart';
import 'package:taskflow/presentation/screens/tasks/task_list_screen.dart';

import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  static const Color primaryColor = Color(0xFF6C4AB6);
  static const Color pageBackground = Color(0xFFF6F3FC);
  static const Color darkText = Color(0xFF241B2F);
  static const Color secondaryText = Color(0xFF6F6878);
  static const Color lightPurple = Color(0xFFE9E1F7);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = context.read<AuthProvider>();
      final projectProvider = context.read<ProjectProvider>();

      debugPrint('AUTH ORG ID: ${authProvider.orgId}');
      debugPrint('AUTH ROLE: ${authProvider.role}');

      if (authProvider.orgId != null) {
        await projectProvider.loadProjects(authProvider.orgId!);

        debugPrint('PROJECT COUNT: ${projectProvider.projects.length}');

        for (final project in projectProvider.projects) {
          debugPrint('PROJECT: ${project.name} | ORG: ${project.orgId}');
        }
      }
    });
  }

  Future<void> _editProject(ProjectModel project) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProjectFormScreen(project: project)),
    );

    if (!mounted) return;

    final orgId = context.read<AuthProvider>().orgId;

    if (orgId != null) {
      await context.read<ProjectProvider>().loadProjects(orgId);
    }
  }

  Future<void> _deleteProject(ProjectModel project) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Project'),
          content: Text('Are you sure you want to delete "${project.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: secondaryText),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final projectProvider = context.read<ProjectProvider>();

    final success = await projectProvider.deleteProject(
      projectId: project.id,
      isAdmin: authProvider.isAdmin,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project deleted successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            projectProvider.errorMessage ?? 'Failed to delete project.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkText),
        title: const Text(
          'Projects',
          style: TextStyle(color: darkText, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (authProvider.isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                tooltip: 'Create project',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProjectFormScreen(),
                    ),
                  );

                  if (!mounted) return;

                  if (authProvider.orgId != null) {
                    context.read<ProjectProvider>().loadProjects(
                      authProvider.orgId!,
                    );
                  }
                },
                icon: const Icon(Icons.add_rounded, color: primaryColor),
              ),
            ),
        ],
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          if (provider.status == ProjectStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (provider.status == ProjectStatus.error) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: lightPurple,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        size: 40,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage ?? 'Something went wrong.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: darkText, fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (authProvider.orgId != null) {
                          provider.loadProjects(authProvider.orgId!);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.projects.isEmpty) {
            return RefreshIndicator(
              color: primaryColor,
              onRefresh: () async {
                if (authProvider.orgId != null) {
                  await provider.loadProjects(authProvider.orgId!);
                }
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 120),
                  Center(child: _EmptyProjectState()),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: primaryColor,
            onRefresh: () async {
              if (authProvider.orgId != null) {
                await provider.loadProjects(authProvider.orgId!);
              }
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: provider.projects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final project = provider.projects[index];

                return Card(
                  margin: EdgeInsets.zero,
                  elevation: 2,
                  shadowColor: Colors.black.withValues(alpha: 0.06),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0xFFE2DCEB)),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskListScreen(
                            projectId: project.id,
                            projectName: project.name,
                          ),
                        ),
                      );

                      if (!mounted) return;

                      final orgId = context.read<AuthProvider>().orgId;

                      if (orgId != null) {
                        await context.read<ProjectProvider>().loadProjects(
                          orgId,
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Project icon
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: lightPurple,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.folder_outlined,
                              color: primaryColor,
                              size: 28,
                            ),
                          ),

                          const SizedBox(width: 14),

                          // Project information
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  project.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: darkText,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  project.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: secondaryText,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: lightPurple,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${project.taskCount} tasks',
                                        style: const TextStyle(
                                          color: primaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0EDF4),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _formatStatus(project.status),
                                        style: const TextStyle(
                                          color: secondaryText,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Admin menu / navigation arrow
                          if (authProvider.isAdmin)
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert_rounded,
                                color: secondaryText,
                              ),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editProject(project);
                                } else if (value == 'delete') {
                                  _deleteProject(project);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,
                                        color: primaryColor,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: secondaryText,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatStatus(String status) {
    if (status.isEmpty) {
      return status;
    }

    return status[0].toUpperCase() + status.substring(1);
  }
}

class _EmptyProjectState extends StatelessWidget {
  const _EmptyProjectState();

  static const Color primaryColor = Color(0xFF6C4AB6);
  static const Color darkText = Color(0xFF241B2F);
  static const Color secondaryText = Color(0xFF6F6878);
  static const Color lightPurple = Color(0xFFE9E1F7);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: lightPurple,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(
            Icons.folder_open_rounded,
            size: 44,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'No projects found',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'There are no projects in this organization.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: secondaryText),
        ),
      ],
    );
  }
}
