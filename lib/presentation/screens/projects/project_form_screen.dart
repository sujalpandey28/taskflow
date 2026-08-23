import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../../data/models/project_model.dart';

class ProjectFormScreen extends StatefulWidget {
  final ProjectModel? project;

  const ProjectFormScreen({super.key, this.project});

  bool get isEditing => project != null;

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  String _status = 'active';
  bool _isSaving = false;

  static const Color primaryColor = Color(0xFF6C4AB6);
  static const Color pageBackground = Color(0xFFF6F3FC);
  static const Color darkText = Color(0xFF241B2F);
  static const Color secondaryText = Color(0xFF6F6878);

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.project?.name ?? '');

    _descriptionController = TextEditingController(
      text: widget.project?.description ?? '',
    );

    _status = widget.project?.status ?? 'active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final projectProvider = context.read<ProjectProvider>();

    if (!authProvider.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only organization admins can modify projects.'),
        ),
      );
      return;
    }

    final orgId = authProvider.orgId;

    if (orgId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Organization information is missing.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    bool success;

    if (widget.isEditing) {
      final oldProject = widget.project!;

      final updatedProject = oldProject.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _status,
      );

      success = await projectProvider.updateProject(
        project: updatedProject,
        isAdmin: authProvider.isAdmin,
      );
    } else {
      final newProject = ProjectModel(
        id: 'project_${DateTime.now().millisecondsSinceEpoch}',
        orgId: orgId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        taskCount: 0,
        status: _status,
        createdAt: DateTime.now(),
      );

      success = await projectProvider.createProject(
        project: newProject,
        isAdmin: authProvider.isAdmin,
      );
    }

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      Navigator.pop(context, true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          projectProvider.errorMessage ?? 'Failed to save project.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? 'Edit Project' : 'Create Project';

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        backgroundColor: pageBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: darkText),
        title: Text(
          title,
          style: const TextStyle(color: darkText, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9E1F7),
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
                          Icons.folder_outlined,
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
                              widget.isEditing
                                  ? 'Update project'
                                  : 'Create a new project',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: darkText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.isEditing
                                  ? 'Update your project details below.'
                                  : 'Add a project to your organization.',
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

                // Project Name
                const Text(
                  'Project Name',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: darkText,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Enter project name',
                    prefixIcon: const Icon(
                      Icons.folder_outlined,
                      color: primaryColor,
                    ),
                    filled: true,
                    fillColor: Colors.white,
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
                      borderSide: const BorderSide(
                        color: primaryColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Project name is required';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Description
                const Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: darkText,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter project description',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 72),
                      child: Icon(
                        Icons.description_outlined,
                        color: primaryColor,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
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
                      borderSide: const BorderSide(
                        color: primaryColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description is required';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Status
                const Text(
                  'Status',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: darkText,
                  ),
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.flag_outlined,
                      color: primaryColor,
                    ),
                    filled: true,
                    fillColor: Colors.white,
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
                      borderSide: const BorderSide(
                        color: primaryColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('Completed'),
                    ),
                    DropdownMenuItem(
                      value: 'archived',
                      child: Text('Archived'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      _status = value;
                    });
                  },
                ),

                const SizedBox(height: 28),

                // Save button
                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveProject,
                    icon: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            widget.isEditing
                                ? Icons.save_outlined
                                : Icons.add_rounded,
                          ),
                    label: Text(
                      _isSaving
                          ? 'Saving...'
                          : widget.isEditing
                          ? 'Update Project'
                          : 'Create Project',
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
}
