// // import 'package:flutter/material.dart';
// // import 'package:taskflow/data/models/task_model.dart';

// // class TaskDetailsScreen extends StatelessWidget {
// //   final TaskModel task;

// //   const TaskDetailsScreen({super.key, required this.task});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text('Task Details')),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               task.title,
// //               style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
// //             ),

// //             const SizedBox(height: 20),

// //             _InfoCard(title: 'Description', value: task.description),

// //             const SizedBox(height: 12),

// //             _InfoCard(title: 'Status', value: task.status),

// //             const SizedBox(height: 12),

// //             _InfoCard(title: 'Priority', value: task.priority),

// //             const SizedBox(height: 12),

// //             _InfoCard(
// //               title: 'Assignee',
// //               value: task.assigneeId ?? 'Unassigned',
// //             ),

// //             const SizedBox(height: 12),

// //             _InfoCard(title: 'Due Date', value: _formatDate(task.dueDate)),

// //             const SizedBox(height: 12),

// //             _InfoCard(
// //               title: 'Created Date',
// //               value: _formatDate(task.createdAt),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   String _formatDate(DateTime date) {
// //     return '${date.day.toString().padLeft(2, '0')}/'
// //         '${date.month.toString().padLeft(2, '0')}/'
// //         '${date.year}';
// //   }
// // }

// // class _InfoCard extends StatelessWidget {
// //   final String title;
// //   final String value;

// //   const _InfoCard({required this.title, required this.value});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Card(
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Row(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Expanded(
// //               flex: 2,
// //               child: Text(
// //                 title,
// //                 style: const TextStyle(fontWeight: FontWeight.bold),
// //               ),
// //             ),
// //             const SizedBox(width: 16),
// //             Expanded(flex: 3, child: Text(value)),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:taskflow/data/models/comment_model.dart';
// import 'package:taskflow/data/models/task_model.dart';
// import 'package:taskflow/presentation/providers/comment_provider.dart';

// class TaskDetailsScreen extends StatefulWidget {
//   final TaskModel task;

//   const TaskDetailsScreen({super.key, required this.task});

//   @override
//   State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
// }

// class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
//   final _commentController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<CommentProvider>().loadComments(widget.task.id);
//     });
//   }

//   @override
//   void dispose() {
//     _commentController.dispose();
//     super.dispose();
//   }

//   Future<void> _addComment() async {
//     final body = _commentController.text.trim();

//     if (body.isEmpty) {
//       return;
//     }

//     final comment = CommentModel(
//       id: 'cmt_${DateTime.now().millisecondsSinceEpoch}',
//       taskId: widget.task.id,
//       authorId: 'user_001',
//       body: body,
//       createdAt: DateTime.now(),
//     );

//     final provider = context.read<CommentProvider>();

//     final success = await provider.createComment(comment);

//     if (!mounted) return;

//     if (success) {
//       _commentController.clear();

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Comment added successfully.')),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(provider.errorMessage ?? 'Failed to add comment.'),
//         ),
//       );
//     }
//   }

//   Future<void> _deleteComment(CommentModel comment) async {
//     final shouldDelete = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Delete Comment'),
//           content: const Text('Are you sure you want to delete this comment?'),
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

//     final provider = context.read<CommentProvider>();

//     final success = await provider.deleteComment(comment.id);

//     if (!mounted) return;

//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Comment deleted successfully.')),
//       );
//     }
//   }

//   Future<void> _editComment(CommentModel comment) async {
//     final updatedBody = await showDialog<String>(
//       context: context,
//       builder: (context) {
//         return _EditCommentDialog(initialText: comment.body);
//       },
//     );

//     if (updatedBody == null || updatedBody.trim().isEmpty) {
//       return;
//     }

//     final updatedComment = comment.copyWith(body: updatedBody.trim());

//     final provider = context.read<CommentProvider>();

//     final success = await provider.updateComment(updatedComment);

//     if (!mounted) return;

//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Comment updated successfully.')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Task Details')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               widget.task.title,
//               style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 20),

//             _InfoCard(title: 'Description', value: widget.task.description),

//             const SizedBox(height: 12),

//             _InfoCard(title: 'Status', value: widget.task.status),

//             const SizedBox(height: 12),

//             _InfoCard(title: 'Priority', value: widget.task.priority),

//             const SizedBox(height: 12),

//             _InfoCard(
//               title: 'Assignee',
//               value: widget.task.assigneeId ?? 'Unassigned',
//             ),

//             const SizedBox(height: 12),

//             _InfoCard(
//               title: 'Due Date',
//               value: _formatDate(widget.task.dueDate),
//             ),

//             const SizedBox(height: 12),

//             _InfoCard(
//               title: 'Created Date',
//               value: _formatDate(widget.task.createdAt),
//             ),

//             const SizedBox(height: 28),

//             const Text(
//               'Comments',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 12),

//             _buildComments(),

//             const SizedBox(height: 20),

//             TextField(
//               controller: _commentController,
//               maxLines: 3,
//               decoration: InputDecoration(
//                 labelText: 'Add a comment',
//                 hintText: 'Write your comment...',
//                 border: const OutlineInputBorder(),
//                 suffixIcon: IconButton(
//                   onPressed: _addComment,
//                   icon: const Icon(Icons.send),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildComments() {
//     return Consumer<CommentProvider>(
//       builder: (context, provider, child) {
//         if (provider.status == CommentStatus.loading) {
//           return const Center(
//             child: Padding(
//               padding: EdgeInsets.all(20),
//               child: CircularProgressIndicator(),
//             ),
//           );
//         }

//         if (provider.status == CommentStatus.error) {
//           return Card(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Text(provider.errorMessage ?? 'Failed to load comments.'),
//             ),
//           );
//         }

//         if (provider.comments.isEmpty) {
//           return const Card(
//             child: Padding(
//               padding: EdgeInsets.all(16),
//               child: Text('No comments yet.'),
//             ),
//           );
//         }

//         return Column(
//           children: provider.comments.map((comment) {
//             return Card(
//               margin: const EdgeInsets.only(bottom: 10),
//               child: ListTile(
//                 title: Text(comment.body),
//                 subtitle: Padding(
//                   padding: const EdgeInsets.only(top: 6),
//                   child: Text(
//                     '${comment.authorId} • '
//                     '${_formatDate(comment.createdAt)}',
//                   ),
//                 ),
//                 trailing: PopupMenuButton<String>(
//                   onSelected: (value) {
//                     if (value == 'edit') {
//                       _editComment(comment);
//                     }

//                     if (value == 'delete') {
//                       _deleteComment(comment);
//                     }
//                   },
//                   itemBuilder: (context) => const [
//                     PopupMenuItem(
//                       value: 'edit',
//                       child: Row(
//                         children: [
//                           Icon(Icons.edit),
//                           SizedBox(width: 8),
//                           Text('Edit'),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem(
//                       value: 'delete',
//                       child: Row(
//                         children: [
//                           Icon(Icons.delete),
//                           SizedBox(width: 8),
//                           Text('Delete'),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day.toString().padLeft(2, '0')}/'
//         '${date.month.toString().padLeft(2, '0')}/'
//         '${date.year}';
//   }
// }

// class _InfoCard extends StatelessWidget {
//   final String title;
//   final String value;

//   const _InfoCard({required this.title, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               flex: 2,
//               child: Text(
//                 title,
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(flex: 3, child: Text(value)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _EditCommentDialog extends StatefulWidget {
//   final String initialText;

//   const _EditCommentDialog({required this.initialText});

//   @override
//   State<_EditCommentDialog> createState() => _EditCommentDialogState();
// }

// class _EditCommentDialogState extends State<_EditCommentDialog> {
//   late final TextEditingController _controller;

//   @override
//   void initState() {
//     super.initState();

//     _controller = TextEditingController(text: widget.initialText);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Edit Comment'),
//       content: TextField(
//         controller: _controller,
//         maxLines: 4,
//         decoration: const InputDecoration(
//           labelText: 'Comment',
//           border: OutlineInputBorder(),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             final value = _controller.text.trim();

//             if (value.isNotEmpty) {
//               Navigator.pop(context, value);
//             }
//           },
//           child: const Text('Save'),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskflow/data/models/comment_model.dart';
import 'package:taskflow/data/models/task_model.dart';
import 'package:taskflow/presentation/providers/comment_provider.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final _commentController = TextEditingController();

  static const Color primaryColor = Color(0xFF6C4AB6);
  static const Color pageBackground = Color(0xFFF6F3FC);
  static const Color darkText = Color(0xFF241B2F);
  static const Color secondaryText = Color(0xFF6F6878);
  static const Color lightPurple = Color(0xFFE9E1F7);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommentProvider>().loadComments(widget.task.id);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    final body = _commentController.text.trim();

    if (body.isEmpty) {
      return;
    }

    final comment = CommentModel(
      id: 'cmt_${DateTime.now().millisecondsSinceEpoch}',
      taskId: widget.task.id,
      authorId: 'user_001',
      body: body,
      createdAt: DateTime.now(),
    );

    final provider = context.read<CommentProvider>();

    final success = await provider.createComment(comment);

    if (!mounted) return;

    if (success) {
      _commentController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment added successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to add comment.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteComment(CommentModel comment) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Comment'),
          content: const Text('Are you sure you want to delete this comment?'),
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

    final provider = context.read<CommentProvider>();

    final success = await provider.deleteComment(comment.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment deleted successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _editComment(CommentModel comment) async {
    final updatedBody = await showDialog<String>(
      context: context,
      builder: (context) {
        return _EditCommentDialog(initialText: comment.body);
      },
    );

    if (updatedBody == null || updatedBody.trim().isEmpty) {
      return;
    }

    final updatedComment = comment.copyWith(body: updatedBody.trim());

    final provider = context.read<CommentProvider>();

    final success = await provider.updateComment(updatedComment);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment updated successfully.'),
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
        title: const Text(
          'Task Details',
          style: TextStyle(color: darkText, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: lightPurple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.task.title,
                    style: const TextStyle(
                      fontSize: 26,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Task information and discussion',
                    style: const TextStyle(fontSize: 14, color: secondaryText),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _InfoCard(
              icon: Icons.description_outlined,
              title: 'Description',
              value: widget.task.description,
            ),

            const SizedBox(height: 10),

            _InfoCard(
              icon: Icons.flag_outlined,
              title: 'Status',
              value: _formatStatus(widget.task.status),
            ),

            const SizedBox(height: 10),

            _InfoCard(
              icon: Icons.priority_high_rounded,
              title: 'Priority',
              value: _formatStatus(widget.task.priority),
            ),

            const SizedBox(height: 10),

            _InfoCard(
              icon: Icons.person_outline_rounded,
              title: 'Assignee',
              value: widget.task.assigneeId ?? 'Unassigned',
            ),

            const SizedBox(height: 10),

            _InfoCard(
              icon: Icons.event_outlined,
              title: 'Due Date',
              value: _formatDate(widget.task.dueDate),
            ),

            const SizedBox(height: 10),

            _InfoCard(
              icon: Icons.calendar_today_outlined,
              title: 'Created Date',
              value: _formatDate(widget.task.createdAt),
            ),

            const SizedBox(height: 30),

            // Comments header
            Row(
              children: [
                const Icon(Icons.forum_outlined, color: primaryColor, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            _buildComments(),

            const SizedBox(height: 18),

            // Add comment
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2DCEB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      maxLines: 3,
                      minLines: 1,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        labelText: 'Add a comment',
                        hintText: 'Write your comment...',
                        labelStyle: const TextStyle(color: secondaryText),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: primaryColor,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2DCEB),
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFAF9FC),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _addComment,
                      color: Colors.white,
                      tooltip: 'Add comment',
                      icon: const Icon(Icons.send_rounded, size: 21),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComments() {
    return Consumer<CommentProvider>(
      builder: (context, provider, child) {
        if (provider.status == CommentStatus.loading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: primaryColor),
            ),
          );
        }

        if (provider.status == CommentStatus.error) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2DCEB)),
            ),
            child: Text(
              provider.errorMessage ?? 'Failed to load comments.',
              style: const TextStyle(color: secondaryText),
            ),
          );
        }

        if (provider.comments.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2DCEB)),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 38,
                  color: primaryColor,
                ),
                SizedBox(height: 10),
                Text(
                  'No comments yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: darkText,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Start the discussion by adding a comment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: secondaryText),
                ),
              ],
            ),
          );
        }

        return Column(
          children: provider.comments.map((comment) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2DCEB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: lightPurple,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: primaryColor,
                      size: 21,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                comment.authorId,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: darkText,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              _formatDate(comment.createdAt),
                              style: const TextStyle(
                                fontSize: 11,
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 7),

                        Text(
                          comment.body,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: darkText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: secondaryText,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editComment(comment);
                      }

                      if (value == 'delete') {
                        _deleteComment(comment);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, color: primaryColor),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _formatStatus(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() + value.substring(1);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  static const Color primaryColor = Color(0xFF6C4AB6);
  static const Color darkText = Color(0xFF241B2F);
  static const Color secondaryText = Color(0xFF6F6878);
  static const Color lightPurple = Color(0xFFE9E1F7);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE2DCEB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: lightPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryColor, size: 21),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: darkText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditCommentDialog extends StatefulWidget {
  final String initialText;

  const _EditCommentDialog({required this.initialText});

  @override
  State<_EditCommentDialog> createState() => _EditCommentDialogState();
}

class _EditCommentDialogState extends State<_EditCommentDialog> {
  late final TextEditingController _controller;

  static const Color primaryColor = Color(0xFF6C4AB6);

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Edit Comment',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      content: TextField(
        controller: _controller,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: 'Comment',
          hintText: 'Update your comment...',
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2DCEB)),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            final value = _controller.text.trim();

            if (value.isNotEmpty) {
              Navigator.pop(context, value);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
