import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/audition_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/audition_provider.dart';
import '../../utils/theme/app_colors.dart';
import '../../utils/extensions/date_extensions.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_indicator.dart';

class AuditionEditScreen extends ConsumerStatefulWidget {
  final String auditionId;

  const AuditionEditScreen({super.key, required this.auditionId});

  @override
  ConsumerState<AuditionEditScreen> createState() =>
      _AuditionEditScreenState();
}

class _AuditionEditScreenState extends ConsumerState<AuditionEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _durationController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _positionsController = TextEditingController();
  final _payController = TextEditingController();

  String? _selectedCategory;
  String? _selectedExperience;
  DateTime? _deadlineDate;
  DateTime? _auditionDate;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isClosing = false;
  bool _initialized = false;
  int _applicationCount = 0;

  static const _categories = [
    'ACTOR',
    'MODEL',
    'DANCER',
    'VOICE_ARTIST',
    'ANCHOR',
  ];

  static const _categoryLabels = {
    'ACTOR': 'Actor',
    'MODEL': 'Model',
    'DANCER': 'Dancer',
    'VOICE_ARTIST': 'Voice Artist',
    'ANCHOR': 'Anchor',
  };

  static const _experienceLevels = [
    'FRESHER',
    '1_3_YRS',
    '3_5_YRS',
    '5_PLUS_YRS',
  ];

  static const _experienceLabels = {
    'FRESHER': 'Fresher',
    '1_3_YRS': '1-3 Years',
    '3_5_YRS': '3-5 Years',
    '5_PLUS_YRS': '5+ Years',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _durationController.dispose();
    _requirementsController.dispose();
    _positionsController.dispose();
    _payController.dispose();
    super.dispose();
  }

  void _populateForm(Audition audition) {
    if (_initialized) return;
    _initialized = true;

    _titleController.text = audition.title;
    _descriptionController.text = audition.description;
    _locationController.text = audition.location ?? '';
    _payController.text = audition.payInfo ?? '';
    _selectedCategory = audition.category;
    _selectedExperience = audition.experienceLevel;
    _deadlineDate = audition.deadline;
    _auditionDate = audition.deadline;
    _applicationCount = audition.applicantCount;
  }

  Future<void> _pickDate({required bool isDeadline}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          isDeadline ? (_deadlineDate ?? now.add(const Duration(days: 7)))
                     : (_auditionDate ?? now.add(const Duration(days: 14))),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isDeadline) {
          _deadlineDate = picked;
        } else {
          _auditionDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_deadlineDate == null || _auditionDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select both audition date and deadline.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.updateAudition(widget.auditionId, {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'experienceLevel': _selectedExperience,
        'location': _locationController.text.trim(),
        'payInfo': _payController.text.trim().isNotEmpty
            ? _payController.text.trim()
            : null,
        'deadline': Timestamp.fromDate(_deadlineDate!),
      });

      final userId = ref.read(authStateProvider).valueOrNull?.uid;
      if (userId != null) {
        ref.invalidate(recruiterAuditionsProvider(userId));
      }
      ref.invalidate(auditionDetailProvider(widget.auditionId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audition updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _closeAudition() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Close Audition'),
        content: const Text(
          'Closing this audition will stop accepting new applications. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Close', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isClosing = true);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.updateAudition(widget.auditionId, {
        'status': AuditionStatus.CLOSED.name,
      });

      final userId = ref.read(authStateProvider).valueOrNull?.uid;
      if (userId != null) {
        ref.invalidate(recruiterAuditionsProvider(userId));
      }
      ref.invalidate(auditionDetailProvider(widget.auditionId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audition closed.'),
            backgroundColor: AppColors.warning,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isClosing = false);
    }
  }

  Future<void> _deleteAudition() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Audition'),
        content: const Text(
          'This will permanently delete this audition and all its applications. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.deleteAudition(widget.auditionId);

      final userId = ref.read(authStateProvider).valueOrNull?.uid;
      if (userId != null) {
        ref.invalidate(recruiterAuditionsProvider(userId));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audition deleted.'),
            backgroundColor: AppColors.error,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auditionAsync =
        ref.watch(auditionDetailProvider(widget.auditionId));

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Audition',
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'close') _closeAudition();
              if (value == 'delete') _deleteAudition();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'close',
                child: Row(
                  children: [
                    Icon(Icons.block, color: AppColors.warning, size: 20),
                    SizedBox(width: 8),
                    Text('Close Audition'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: auditionAsync.when(
        loading: () => const LoadingIndicator(message: 'Loading audition...'),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Failed to load audition: $error'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.invalidate(
                    auditionDetailProvider(widget.auditionId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (audition) {
          if (audition == null) {
            return const Center(child: Text('Audition not found.'));
          }

          _populateForm(audition);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_applicationCount > 0)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: AppColors.warning, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This audition has $_applicationCount applicant${_applicationCount == 1 ? '' : 's'}. Changes will be visible to all applicants.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  CustomTextField(
                    controller: _titleController,
                    label: 'Title',
                    hint: 'e.g. Lead Actor for Short Film',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      if (value.trim().length < 5) {
                        return 'Title must be at least 5 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Describe the audition in detail...',
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required';
                      }
                      if (value.trim().length < 20) {
                        return 'Description must be at least 20 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(_categoryLabels[cat] ?? cat),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value),
                    validator: (value) =>
                        value == null ? 'Please select a category' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedExperience,
                    decoration: const InputDecoration(
                      labelText: 'Experience Level',
                      border: OutlineInputBorder(),
                    ),
                    items: _experienceLevels.map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text(_experienceLabels[level] ?? level),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedExperience = value),
                    validator: (value) =>
                        value == null
                            ? 'Please select an experience level'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _locationController,
                    label: 'Location',
                    hint: 'e.g. Mumbai, Maharashtra',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Location is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _payController,
                    label: 'Pay Info (Optional)',
                    hint: 'e.g. 50,000/month',
                  ),
                  const SizedBox(height: 16),
                  _buildDateField(
                    label: 'Audition Date',
                    date: _auditionDate,
                    onTap: () => _pickDate(isDeadline: false),
                  ),
                  const SizedBox(height: 16),
                  _buildDateField(
                    label: 'Application Deadline',
                    date: _deadlineDate,
                    onTap: () => _pickDate(isDeadline: true),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    label: 'Save Changes',
                    variant: ButtonVariant.primary,
                    isLoading: _isSaving,
                    onPressed: (_isDeleting || _isClosing) ? null : _save,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
        ),
        child: Text(
          date != null ? date!.formattedDate : 'Select date',
          style: TextStyle(
            fontSize: 16,
            color: date != null ? AppColors.textPrimary : AppColors.textHint,
          ),
        ),
      ),
    );
  }
}
