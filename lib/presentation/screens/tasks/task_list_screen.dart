// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:taskflow/data/models/task_model.dart';
// import 'package:taskflow/presentation/providers/task_provider.dart';
// import 'package:taskflow/presentation/screens/tasks/task_detail_screen.dart';
// import 'package:taskflow/presentation/screens/tasks/task_form_screen.dart';

// class TaskListScreen extends StatefulWidget {
//   final String projectId;
//   final String projectName;

//   const TaskListScreen({
//     super.key,
//     required this.projectId,
//     required this.projectName,
//   });

//   @override
//   State<TaskListScreen> createState() => _TaskListScreenState();
// }

// class _TaskListScreenState extends State<TaskListScreen> {
//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<TaskProvider>().loadTasks(widget.projectId);
//     });
//   }

//   Future<void> _deleteTask(String taskId) async {
//     final shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Delete Task'),
//           content: const Text('Are you sure you want to delete this task?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context, false);
//               },
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context, true);
//               },
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );

//     if (shouldDelete != true) {
//       return;
//     }

//     final provider = context.read<TaskProvider>();

//     final success = await provider.deleteTask(taskId);

//     if (!mounted) return;

//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Task deleted successfully')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(provider.errorMessage ?? 'Failed to delete task.'),
//         ),
//       );
//     }
//   }

//   Future<void> _changePriority(TaskModel task, String priority) async {
//     final provider = context.read<TaskProvider>();

//     final updatedTask = TaskModel(
//       id: task.id,
//       projectId: task.projectId,
//       title: task.title,
//       description: task.description,
//       status: task.status,
//       priority: priority,
//       assigneeId: task.assigneeId,
//       dueDate: task.dueDate,
//       createdAt: task.createdAt,
//     );

//     final success = await provider.updateTask(updatedTask);

//     if (!mounted) return;

//     if (!success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             provider.errorMessage ?? 'Failed to update task priority.',
//           ),
//         ),
//       );
//     }
//   }

//   Future<void> _changeStatus(TaskModel task, String status) async {
//     final provider = context.read<TaskProvider>();

//     final updatedTask = TaskModel(
//       id: task.id,
//       projectId: task.projectId,
//       title: task.title,
//       description: task.description,
//       status: status,
//       priority: task.priority,
//       assigneeId: task.assigneeId,
//       dueDate: task.dueDate,
//       createdAt: task.createdAt,
//     );

//     final success = await provider.updateTask(updatedTask);

//     if (!mounted) return;

//     if (!success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             provider.errorMessage ?? 'Failed to update task status.',
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.projectName),
//         actions: [
//           IconButton(
//             onPressed: () async {
//               await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => TaskFormScreen(projectId: widget.projectId),
//                 ),
//               );

//               if (!mounted) return;

//               context.read<TaskProvider>().loadTasks(widget.projectId);
//             },
//             icon: const Icon(Icons.add),
//           ),
//         ],
//       ),
//       body: Consumer<TaskProvider>(
//         builder: (context, provider, child) {
//           if (provider.status == TaskStatus.loading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (provider.status == TaskStatus.error) {
//             return Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(provider.errorMessage ?? 'Something went wrong.'),
//                   const SizedBox(height: 12),
//                   ElevatedButton(
//                     onPressed: () {
//                       provider.loadTasks(widget.projectId);
//                     },
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             );
//           }

//           if (provider.tasks.isEmpty) {
//             return const Center(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.task_outlined, size: 64),
//                   SizedBox(height: 16),
//                   Text(
//                     'No tasks found',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 8),
//                   Text('There are no tasks in this project.'),
//                 ],
//               ),
//             );
//           }

//           // return RefreshIndicator(
//           //   onRefresh: () {
//           //     return provider.loadTasks(widget.projectId);
//           //   },
//           //   child: ListView.separated(
//           //     padding: const EdgeInsets.all(16),
//           //     itemCount: provider.filteredTasks.length,
//           //     separatorBuilder: (_, __) => const SizedBox(height: 12),
//           //     itemBuilder: (context, index) {
//           //       final task = provider.filteredTasks[index];

//           //       return Card(
//           //         child: ListTile(
//           //           contentPadding: const EdgeInsets.all(16),
//           //           leading: CircleAvatar(
//           //             child: Icon(
//           //               task.status == 'done' ? Icons.check : Icons.task_alt,
//           //             ),
//           //           ),
//           //           title: Text(
//           //             task.title,
//           //             style: const TextStyle(fontWeight: FontWeight.bold),
//           //           ),
//           //           subtitle: Padding(
//           //             padding: const EdgeInsets.only(top: 8),
//           //             child: Column(
//           //               crossAxisAlignment: CrossAxisAlignment.start,
//           //               children: [
//           //                 Text(task.description),

//           //                 const SizedBox(height: 10),

//           //                 Text('Status: ${task.status}'),

//           //                 Text('Priority: ${task.priority}'),

//           //                 Text(
//           //                   'Assignee: '
//           //                   '${task.assigneeId ?? 'Unassigned'}',
//           //                 ),

//           //                 Text('Due: ${_formatDate(task.dueDate)}'),
//           //               ],
//           //             ),
//           //           ),
//           //           isThreeLine: true,
//           //         ),
//           //       );
//           //     },
//           //   ),
//           // );
//           return Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: DropdownButtonFormField<String?>(
//                         value: provider.statusFilter,
//                         decoration: const InputDecoration(
//                           labelText: 'Status',
//                           border: OutlineInputBorder(),
//                         ),
//                         items: const [
//                           DropdownMenuItem<String?>(
//                             value: null,
//                             child: Text('All'),
//                           ),
//                           DropdownMenuItem<String?>(
//                             value: 'todo',
//                             child: Text('Todo'),
//                           ),
//                           DropdownMenuItem<String?>(
//                             value: 'in_progress',
//                             child: Text('In Progress'),
//                           ),
//                           DropdownMenuItem<String?>(
//                             value: 'done',
//                             child: Text('Done'),
//                           ),
//                         ],
//                         onChanged: provider.setStatusFilter,
//                       ),
//                     ),

//                     const SizedBox(width: 12),

//                     Expanded(
//                       child: DropdownButtonFormField<String?>(
//                         value: provider.priorityFilter,
//                         decoration: const InputDecoration(
//                           labelText: 'Priority',
//                           border: OutlineInputBorder(),
//                         ),
//                         items: const [
//                           DropdownMenuItem<String?>(
//                             value: null,
//                             child: Text('All'),
//                           ),
//                           DropdownMenuItem<String?>(
//                             value: 'low',
//                             child: Text('Low'),
//                           ),
//                           DropdownMenuItem<String?>(
//                             value: 'medium',
//                             child: Text('Medium'),
//                           ),
//                           DropdownMenuItem<String?>(
//                             value: 'high',
//                             child: Text('High'),
//                           ),
//                         ],
//                         onChanged: provider.setPriorityFilter,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               SwitchListTile(
//                 title: const Text('Sort by due date'),
//                 value: provider.sortByDueDate,
//                 onChanged: provider.setSortByDueDate,
//               ),

//               Expanded(
//                 child: RefreshIndicator(
//                   onRefresh: () {
//                     return provider.loadTasks(widget.projectId);
//                   },
//                   child: ListView.separated(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: provider.filteredTasks.length,
//                     separatorBuilder: (_, __) => const SizedBox(height: 12),
//                     itemBuilder: (context, index) {
//                       final task = provider.filteredTasks[index];

//                       return Card(
//                         child: ListTile(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => TaskDetailsScreen(task: task),
//                               ),
//                             );
//                           },

//                           contentPadding: const EdgeInsets.all(16),

//                           leading: CircleAvatar(
//                             child: Icon(
//                               task.status == 'done'
//                                   ? Icons.check
//                                   : Icons.task_alt,
//                             ),
//                           ),

//                           title: Text(
//                             task.title,
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),

//                           subtitle: Padding(
//                             padding: const EdgeInsets.only(top: 8),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(task.description),

//                                 const SizedBox(height: 10),

//                                 Text('Status: ${task.status}'),

//                                 Text('Priority: ${task.priority}'),

//                                 Text(
//                                   'Assignee: '
//                                   '${task.assigneeId ?? 'Unassigned'}',
//                                 ),

//                                 Text('Due: ${_formatDate(task.dueDate)}'),
//                               ],
//                             ),
//                           ),

//                           isThreeLine: true,

//                           trailing: PopupMenuButton<String>(
//                             onSelected: (value) async {
//                               if (value == 'edit') {
//                                 await Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => TaskFormScreen(
//                                       projectId: widget.projectId,
//                                       task: task,
//                                     ),
//                                   ),
//                                 );

//                                 if (!mounted) return;

//                                 await context.read<TaskProvider>().loadTasks(
//                                   widget.projectId,
//                                 );
//                               }

//                               if (value == 'status_todo') {
//                                 await _changeStatus(task, 'todo');
//                               }

//                               if (value == 'status_in_progress') {
//                                 await _changeStatus(task, 'in_progress');
//                               }

//                               if (value == 'status_done') {
//                                 await _changeStatus(task, 'done');
//                               }

//                               if (value == 'delete') {
//                                 await _deleteTask(task.id);
//                               }

//                               if (value == 'priority_low') {
//                                 await _changePriority(task, 'low');
//                               }

//                               if (value == 'priority_medium') {
//                                 await _changePriority(task, 'medium');
//                               }

//                               if (value == 'priority_high') {
//                                 await _changePriority(task, 'high');
//                               }

//                               if (value == 'priority_urgent') {
//                                 await _changePriority(task, 'urgent');
//                               }
//                             },

//                             itemBuilder: (context) => const [
//                               PopupMenuItem(
//                                 value: 'edit',
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.edit),
//                                     SizedBox(width: 8),
//                                     Text('Edit'),
//                                   ],
//                                 ),
//                               ),

//                               PopupMenuItem(
//                                 value: 'delete',
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.delete),
//                                     SizedBox(width: 8),
//                                     Text('Delete'),
//                                   ],
//                                 ),
//                               ),
//                               PopupMenuItem(
//                                 value: 'status_todo',
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.radio_button_unchecked),
//                                     SizedBox(width: 8),
//                                     Text('Mark as Todo'),
//                                   ],
//                                 ),
//                               ),
//                               PopupMenuItem(
//                                 value: 'status_in_progress',
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.pending),
//                                     SizedBox(width: 8),
//                                     Text('Mark as In Progress'),
//                                   ],
//                                 ),
//                               ),
//                               PopupMenuItem(
//                                 value: 'status_done',
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.check_circle),
//                                     SizedBox(width: 8),
//                                     Text('Mark as Done'),
//                                   ],
//                                 ),
//                               ),

//                               PopupMenuItem(
//                                 value: 'priority_low',
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.arrow_downward),
//                                     SizedBox(width: 8),
//                                     Text('Set Low Priority'),
//                                   ],
//                                 ),
//                               ),

//                               PopupMenuItem(
//                                 value: 'priority_medium',
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.remove),
//                                     SizedBox(width: 8),
//                                     Text('Set Medium Priority'),
//                                   ],
//                                 ),
//                               ),

//                               PopupMenuItem(
//                                 value: 'priority_high',
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.arrow_upward),
//                                     SizedBox(width: 8),
//                                     Text('Set High Priority'),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')}/'
//         '${date.month.toString().padLeft(2, '0')}/'
//         '${date.year}';
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskflow/data/models/task_model.dart';
import 'package:taskflow/presentation/providers/task_provider.dart';
import 'package:taskflow/presentation/screens/tasks/task_detail_screen.dart';
import 'package:taskflow/presentation/screens/tasks/task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  final String projectId;
  final String projectName;

  const TaskListScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  static const Color primaryColor = Color(0xFF6C4AB6);
  static const Color pageBackground = Color(0xFFF6F3FC);
  static const Color darkText = Color(0xFF241B2F);
  static const Color secondaryText = Color(0xFF6F6878);
  static const Color lightPurple = Color(0xFFE9E1F7);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks(widget.projectId);
    });
  }

  Future<void> _deleteTask(String taskId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Task',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
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
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    final provider = context.read<TaskProvider>();

    final success = await provider.deleteTask(taskId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Task deleted successfully'
              : provider.errorMessage ?? 'Failed to delete task.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _changePriority(TaskModel task, String priority) async {
    final provider = context.read<TaskProvider>();

    final updatedTask = TaskModel(
      id: task.id,
      projectId: task.projectId,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: priority,
      assigneeId: task.assigneeId,
      dueDate: task.dueDate,
      createdAt: task.createdAt,
    );

    final success = await provider.updateTask(updatedTask);

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Failed to update task priority.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _changeStatus(TaskModel task, String status) async {
    final provider = context.read<TaskProvider>();

    final updatedTask = TaskModel(
      id: task.id,
      projectId: task.projectId,
      title: task.title,
      description: task.description,
      status: status,
      priority: task.priority,
      assigneeId: task.assigneeId,
      dueDate: task.dueDate,
      createdAt: task.createdAt,
    );

    final success = await provider.updateTask(updatedTask);

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Failed to update task status.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkText),
        title: Text(
          widget.projectName,
          style: const TextStyle(color: darkText, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Add task',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskFormScreen(projectId: widget.projectId),
                ),
              );

              if (!mounted) return;

              context.read<TaskProvider>().loadTasks(widget.projectId);
            },
            icon: const Icon(Icons.add_task_rounded, color: primaryColor),
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          if (provider.status == TaskStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          if (provider.status == TaskStatus.error) {
            return _ErrorState(
              message: provider.errorMessage ?? 'Something went wrong.',
              onRetry: () {
                provider.loadTasks(widget.projectId);
              },
            );
          }

          if (provider.tasks.isEmpty) {
            return RefreshIndicator(
              color: primaryColor,
              onRefresh: () {
                return provider.loadTasks(widget.projectId);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [SizedBox(height: 130), _EmptyTaskState()],
              ),
            );
          }

          return Column(
            children: [
              // Filters
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: _FilterDropdown(
                        label: 'Status',
                        value: provider.statusFilter,
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: _PriorityOption(
                              icon: Icons.filter_alt_outlined,
                              label: 'All',
                              color: const Color(0xFF6C4AB6),
                            ),
                          ),

                          DropdownMenuItem<String?>(
                            value: 'todo',
                            child: _PriorityOption(
                              icon: Icons.radio_button_unchecked_rounded,
                              label: 'Todo',
                              color: const Color(0xFF6C4AB6),
                            ),
                          ),

                          DropdownMenuItem<String?>(
                            value: 'in_progress',
                            child: _PriorityOption(
                              icon: Icons.timelapse_rounded,
                              label: 'In Progress',
                              color: Colors.orange.shade600,
                            ),
                          ),

                          DropdownMenuItem<String?>(
                            value: 'done',
                            child: _PriorityOption(
                              icon: Icons.check_circle_outline_rounded,
                              label: 'Done',
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                        onChanged: provider.setStatusFilter,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _FilterDropdown(
                        label: 'Priority',
                        value: provider.priorityFilter,
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: _PriorityOption(
                              icon: Icons.filter_alt_outlined,
                              label: 'All',
                              color: const Color(0xFF6C4AB6),
                            ),
                          ),

                          DropdownMenuItem<String?>(
                            value: 'low',
                            child: _PriorityOption(
                              icon: Icons.keyboard_arrow_down_rounded,
                              label: 'Low',
                              color: Colors.green.shade600,
                            ),
                          ),

                          DropdownMenuItem<String?>(
                            value: 'medium',
                            child: _PriorityOption(
                              icon: Icons.remove_rounded,
                              label: 'Medium',
                              color: Colors.orange.shade600,
                            ),
                          ),

                          DropdownMenuItem<String?>(
                            value: 'high',
                            child: _PriorityOption(
                              icon: Icons.keyboard_arrow_up_rounded,
                              label: 'High',
                              color: Colors.deepOrange.shade600,
                            ),
                          ),

                          DropdownMenuItem<String?>(
                            value: 'urgent',
                            child: _PriorityOption(
                              icon: Icons.priority_high_rounded,
                              label: 'Urgent',
                              color: Colors.red.shade600,
                            ),
                          ),
                        ],
                        onChanged: provider.setPriorityFilter,
                      ),
                    ),
                  ],
                ),
              ),

              // Sort + task count
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: SwitchListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.only(left: 4),
                        activeColor: primaryColor,
                        title: const Text(
                          'Sort by due date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: darkText,
                          ),
                        ),
                        value: provider.sortByDueDate,
                        onChanged: provider.setSortByDueDate,
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: lightPurple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${provider.filteredTasks.length} tasks',
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              Expanded(
                child: RefreshIndicator(
                  color: primaryColor,
                  onRefresh: () {
                    return provider.loadTasks(widget.projectId);
                  },
                  child: provider.filteredTasks.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 100),
                            Center(
                              child: Text(
                                'No tasks match the selected filters.',
                                style: TextStyle(
                                  color: secondaryText,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: provider.filteredTasks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final task = provider.filteredTasks[index];

                            return _TaskCard(
                              task: task,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TaskDetailsScreen(task: task),
                                  ),
                                );

                                if (!mounted) return;

                                context.read<TaskProvider>().loadTasks(
                                  widget.projectId,
                                );
                              },
                              onEdit: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TaskFormScreen(
                                      projectId: widget.projectId,
                                      task: task,
                                    ),
                                  ),
                                );

                                if (!mounted) return;

                                context.read<TaskProvider>().loadTasks(
                                  widget.projectId,
                                );
                              },
                              onDelete: () {
                                _deleteTask(task.id);
                              },
                              onStatusChange: (status) {
                                _changeStatus(task, status);
                              },
                              onPriorityChange: (priority) {
                                _changePriority(task, priority);
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // String _formatDate(DateTime date) {
  //   return '${date.day.toString().padLeft(2, '0')}/'
  //       '${date.month.toString().padLeft(2, '0')}/'
  //       '${date.year}';
  // }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<String> onStatusChange;
  final ValueChanged<String> onPriorityChange;

  const _TaskCard({
    required this.task,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusChange,
    required this.onPriorityChange,
  });

  static const Color primaryColor = Color(0xFF6C4AB6);
  static const Color darkText = Color(0xFF241B2F);
  static const Color secondaryText = Color(0xFF6F6878);
  static const Color lightPurple = Color(0xFFE9E1F7);

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == 'done';

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE2DCEB)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDone ? const Color(0xFFE4F4EA) : lightPurple,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isDone
                      ? Icons.check_circle_outline_rounded
                      : Icons.task_alt_rounded,
                  color: isDone ? Colors.green.shade700 : primaryColor,
                  size: 26,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: secondaryText,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        _Badge(
                          icon: Icons.flag_outlined,
                          text: _formatValue(task.status),
                        ),
                        _Badge(
                          icon: Icons.priority_high_rounded,
                          text: _formatValue(task.priority),
                        ),
                        _Badge(
                          icon: Icons.event_outlined,
                          text: _formatDate(task.dueDate),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 15,
                          color: secondaryText,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            task.assigneeId ?? 'Unassigned',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: secondaryText),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;

                    case 'delete':
                      onDelete();
                      break;

                    case 'status_todo':
                      onStatusChange('todo');
                      break;

                    case 'status_in_progress':
                      onStatusChange('in_progress');
                      break;

                    case 'status_done':
                      onStatusChange('done');
                      break;

                    case 'priority_low':
                      onPriorityChange('low');
                      break;

                    case 'priority_medium':
                      onPriorityChange('medium');
                      break;

                    case 'priority_high':
                      onPriorityChange('high');
                      break;

                    case 'priority_urgent':
                      onPriorityChange('urgent');
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: _MenuItem(icon: Icons.edit_outlined, text: 'Edit'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: _MenuItem(
                      icon: Icons.delete_outline,
                      text: 'Delete',
                      danger: true,
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'status_todo',
                    child: _MenuItem(
                      icon: Icons.radio_button_unchecked,
                      text: 'Mark as Todo',
                    ),
                  ),
                  PopupMenuItem(
                    value: 'status_in_progress',
                    child: _MenuItem(
                      icon: Icons.pending_outlined,
                      text: 'Mark as In Progress',
                    ),
                  ),
                  PopupMenuItem(
                    value: 'status_done',
                    child: _MenuItem(
                      icon: Icons.check_circle_outline,
                      text: 'Mark as Done',
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'priority_low',
                    child: _MenuItem(
                      icon: Icons.arrow_downward_rounded,
                      text: 'Set Low Priority',
                    ),
                  ),
                  PopupMenuItem(
                    value: 'priority_medium',
                    child: _MenuItem(
                      icon: Icons.remove_rounded,
                      text: 'Set Medium Priority',
                    ),
                  ),
                  PopupMenuItem(
                    value: 'priority_high',
                    child: _MenuItem(
                      icon: Icons.arrow_upward_rounded,
                      text: 'Set High Priority',
                    ),
                  ),
                  PopupMenuItem(
                    value: 'priority_urgent',
                    child: _MenuItem(
                      icon: Icons.priority_high_rounded,
                      text: 'Set Urgent Priority',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatValue(String value) {
    if (value.isEmpty) return value;

    return value.replaceAll('_', ' ').substring(0, 1).toUpperCase() +
        value.replaceAll('_', ' ').substring(1);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Badge({required this.icon, required this.text});

  static const Color primaryColor = Color(0xFF6C4AB6);
  static const Color lightPurple = Color(0xFFE9E1F7);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: lightPurple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: primaryColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool danger;

  const _MenuItem({
    required this.icon,
    required this.text,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: danger ? Colors.red : const Color(0xFF6C4AB6)),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<DropdownMenuItem<String?>> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  static const Color primaryColor = Color(0xFF6C4AB6);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2DCEB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}

class _EmptyTaskState extends StatelessWidget {
  const _EmptyTaskState();

  static const Color primaryColor = Color(0xFF6C4AB6);
  static const Color darkText = Color(0xFF241B2F);
  static const Color secondaryText = Color(0xFF6F6878);
  static const Color lightPurple = Color(0xFFE9E1F7);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: lightPurple,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.task_outlined, size: 44, color: primaryColor),
        ),
        const SizedBox(height: 18),
        const Text(
          'No tasks found',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: darkText,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'There are no tasks in this project.',
          style: TextStyle(fontSize: 14, color: secondaryText),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  static const Color primaryColor = Color(0xFF6C4AB6);
  static const Color darkText = Color(0xFF241B2F);
  static const Color lightPurple = Color(0xFFE9E1F7);

  @override
  Widget build(BuildContext context) {
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
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: darkText, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
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
}

class _PriorityOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PriorityOption({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 19, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
