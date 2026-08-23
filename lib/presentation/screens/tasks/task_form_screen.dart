import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskflow/data/models/task_model.dart';
import 'package:taskflow/data/models/user_model.dart';
import 'package:taskflow/presentation/providers/task_provider.dart';

class TaskFormScreen extends StatefulWidget {
  final String projectId;
  final TaskModel? task;

  const TaskFormScreen({super.key, required this.projectId, this.task});

  bool get isEditing => task != null;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  List<OrgMemberModel> _members = [];
  bool _loadingMembers = false;
  bool _isSaving = false;

  String? _selectedAssigneeId;

  String _status = 'todo';
  String _priority = 'medium';
  DateTime? _dueDate;

  static const Color primaryColor = Color(0xFF6C4AB6);
  static const Color pageBackground = Color(0xFFF6F3FC);
  static const Color darkText = Color(0xFF241B2F);
  static const Color secondaryText = Color(0xFF6F6878);
  static const Color lightPurple = Color(0xFFE9E1F7);

  @override
  void initState() {
    super.initState();

    final task = widget.task;

    _titleController = TextEditingController(text: task?.title ?? '');

    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );

    _status = task?.status ?? 'todo';
    _priority = task?.priority ?? 'medium';
    _dueDate = task?.dueDate;

    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _loadingMembers = true;
    });

    try {
      final repository = context.read<TaskProvider>().repository;

      final members = await repository.getOrgMembers();

      if (!mounted) return;

      setState(() {
        _members = members;
        _selectedAssigneeId = widget.task?.assigneeId;
        _loadingMembers = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingMembers = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _dueDate = selectedDate;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a due date.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final provider = context.read<TaskProvider>();

    final task = widget.task;

    final taskModel = TaskModel(
      id: task?.id ?? 'task_${DateTime.now().millisecondsSinceEpoch}',
      projectId: widget.projectId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _status,
      priority: _priority,
      assigneeId: _selectedAssigneeId,
      dueDate: _dueDate!,
      createdAt: task?.createdAt ?? DateTime.now(),
    );

    setState(() {
      _isSaving = true;
    });

    final success = widget.isEditing
        ? await provider.updateTask(taskModel)
        : await provider.createTask(taskModel);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to save task.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkText),
        title: Text(
          isEditing ? 'Edit Task' : 'Create Task',
          style: const TextStyle(color: darkText, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: lightPurple,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.task_alt_rounded,
                          color: primaryColor,
                          size: 27,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing ? 'Update task' : 'Create a new task',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: darkText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isEditing
                                  ? 'Update the task details below.'
                                  : 'Add a task to this project.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _FieldLabel(label: 'Task Title'),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    hintText: 'Enter task title',
                    icon: Icons.title_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title is required.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                _FieldLabel(label: 'Description'),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: _inputDecoration(
                    hintText: 'Describe the task...',
                    icon: Icons.description_outlined,
                    alignIconToTop: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description is required.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                _FieldLabel(label: 'Status'),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: _inputDecoration(
                    hintText: 'Select status',
                    icon: Icons.flag_outlined,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'todo', child: Text('Todo')),
                    DropdownMenuItem(
                      value: 'in_progress',
                      child: Text('In Progress'),
                    ),
                    DropdownMenuItem(value: 'done', child: Text('Done')),
                    DropdownMenuItem(value: 'review', child: Text('Review')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _status = value;
                    });
                  },
                ),

                const SizedBox(height: 18),

                _FieldLabel(label: 'Priority'),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: _priority,
                  decoration: _inputDecoration(
                    hintText: 'Select priority',
                    icon: Icons.priority_high_rounded,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                    DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _priority = value;
                    });
                  },
                ),

                const SizedBox(height: 18),

                _FieldLabel(label: 'Assignee'),

                const SizedBox(height: 8),

                if (_loadingMembers)
                  Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2DCEB)),
                    ),
                    child: const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: primaryColor,
                      ),
                    ),
                  )
                else
                  DropdownButtonFormField<String?>(
                    value:
                        _members.any(
                          (member) => member.userId == _selectedAssigneeId,
                        )
                        ? _selectedAssigneeId
                        : null,
                    decoration: _inputDecoration(
                      hintText: 'Select assignee',
                      icon: Icons.person_outline_rounded,
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Unassigned'),
                      ),
                      ..._members.map(
                        (member) => DropdownMenuItem<String?>(
                          value: member.userId,
                          child: Text(member.userId),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedAssigneeId = value;
                      });
                    },
                  ),

                const SizedBox(height: 18),

                _FieldLabel(label: 'Due Date'),

                const SizedBox(height: 8),

                InkWell(
                  onTap: _selectDueDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: _inputDecoration(
                      hintText: 'Select due date',
                      icon: Icons.event_outlined,
                    ),
                    child: Text(
                      _dueDate == null
                          ? 'Select due date'
                          : _formatDate(_dueDate!),
                      style: TextStyle(
                        color: _dueDate == null ? secondaryText : darkText,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Save button
                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _submit,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            isEditing
                                ? Icons.save_outlined
                                : Icons.add_task_rounded,
                          ),
                    label: Text(
                      _isSaving
                          ? 'Saving...'
                          : isEditing
                          ? 'Update Task'
                          : 'Create Task',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shadowColor: primaryColor.withValues(alpha: 0.30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    bool alignIconToTop = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: alignIconToTop
          ? Padding(
              padding: const EdgeInsets.only(bottom: 72),
              child: Icon(icon, color: primaryColor),
            )
          : Icon(icon, color: primaryColor),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  static const Color darkText = Color(0xFF241B2F);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: darkText,
      ),
    );
  }
}
