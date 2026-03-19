import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

/// Pantalla 4 — Adding Task (with file attachments support)
class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key, required this.repository});

  final TaskRepository repository;

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _selectedCategory = 'General';
  DateTime? _selectedDate;
  bool _saving = false;
  bool _dateError = false; // shown when user submits without picking a date

  /// Picked files (not yet uploaded — uploaded on Confirm)
  final List<PlatformFile> _pickedFiles = [];

  static const _categories = [
    'Healthy', 'Design', 'Job', 'Education', 'Sport', 'Personal', 'General',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // ── File picking ──────────────────────────────────────────────────────────
  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true, // ensures bytes are available cross-platform
    );
    if (result == null) return;

    // Merge with existing picks, avoiding duplicates by name
    final existing = _pickedFiles.map((f) => f.name).toSet();
    final newFiles =
        result.files.where((f) => !existing.contains(f.name)).toList();

    setState(() => _pickedFiles.addAll(newFiles));
  }

  void _removeFile(int index) {
    setState(() => _pickedFiles.removeAt(index));
  }

  // ── Date picker ───────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    // Validate the date separately (not a TextFormField)
    final formOk = _formKey.currentState!.validate();
    final dateOk = _selectedDate != null;
    setState(() => _dateError = !dateOk);
    if (!formOk || !dateOk) return;
    setState(() => _saving = true);

    try {
      final taskId = const Uuid().v4();

      // 1. Upload each file and collect public URLs
      final fileUrls = <String>[];
      for (final file in _pickedFiles) {
        if (file.bytes == null) continue;
        final url = await widget.repository.uploadFile(
          taskId: taskId,
          bytes: file.bytes!,
          fileName: file.name,
        );
        fileUrls.add(url);
      }

      // 2. Create task with URLs already attached
      final task = TaskEntity(
        id: taskId,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _selectedCategory,
        dueDate: _selectedDate,
        isCompleted: false,
        createdAt: DateTime.now(),
        fileUrls: fileUrls,
      );
      await widget.repository.addTask(task);

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Adding Task',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, fontSize: 17)),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title ──────────────────────────────────────────────
                    TextFormField(
                      controller: _titleCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 80,
                      inputFormatters: [_NoLeadingSpaceFormatter()],
                      decoration: const InputDecoration(
                        hintText: 'Task Title',
                        counterText: '',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter a title';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // ── Description ────────────────────────────────────────
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 4,
                      maxLength: 500,
                      inputFormatters: [_NoLeadingSpaceFormatter()],
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Description',
                        alignLabelWithHint: true,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter a description';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // ── Date picker ────────────────────────────────────────
                    _ActionRow(
                      icon: Icons.calendar_today_rounded,
                      label: _selectedDate == null
                          ? 'Select Date In Calendar'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      onTap: () {
                        _pickDate();
                        setState(() => _dateError = false);
                      },
                      hasError: _dateError,
                      errorText: 'Please select a date',
                    ),
                    const SizedBox(height: 12),

                    // ── Additional Files ───────────────────────────────────
                    _ActionRow(
                      icon: Icons.attach_file_rounded,
                      label: _pickedFiles.isEmpty
                          ? 'Additional Files'
                          : '${_pickedFiles.length} file${_pickedFiles.length > 1 ? 's' : ''} selected',
                      onTap: _pickFiles,
                    ),

                    // ── File chips ─────────────────────────────────────────
                    if (_pickedFiles.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _pickedFiles.asMap().entries.map((e) {
                          final i = e.key;
                          final f = e.value;
                          return Chip(
                            avatar: Icon(
                              _iconForFile(f.name),
                              size: 16,
                              color: AppColors.primary,
                            ),
                            label: Text(
                              f.name.length > 20
                                  ? '${f.name.substring(0, 18)}…'
                                  : f.name,
                              style: GoogleFonts.poppins(fontSize: 11),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () => _removeFile(i),
                            backgroundColor: AppColors.primaryLight,
                            side: BorderSide.none,
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // ── Categories ─────────────────────────────────────────
                    Text(
                      'Choose Category',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 9),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : const Color(0xFFDDDDDD),
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              cat,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textMedium,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // ── Confirm button ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          'Confirm Adding',
                          style: GoogleFonts.poppins(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForFile(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image_rounded;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.videocam_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }
}

// ── Shared action row ─────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.hasError = false,
    this.errorText,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool hasError;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: hasError
                  ? AppColors.dangerLight
                  : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
              border: hasError
                  ? Border.all(color: AppColors.danger, width: 1.2)
                  : null,
            ),
            child: Row(
              children: [
                Icon(icon,
                    color: hasError ? AppColors.danger : AppColors.primary,
                    size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: hasError
                            ? AppColors.danger
                            : AppColors.primary),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: hasError ? AppColors.danger : AppColors.primary,
                    size: 20),
              ],
            ),
          ),
        ),
        if (hasError && errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6),
            child: Text(
              errorText!,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.danger),
            ),
          ),
      ],
    );
  }

// ── Input formatter: blocks leading spaces as the user types ─────────────────

class _NoLeadingSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new text would start with a space, reject the change entirely
    if (newValue.text.startsWith(' ')) {
      return oldValue;
    }
    return newValue;
  }
}
}
