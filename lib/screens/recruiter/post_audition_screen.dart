import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/audition_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/audition_provider.dart';
import '../../utils/theme/app_colors.dart';
import '../../utils/extensions/date_extensions.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_app_bar.dart';

class PostAuditionScreen extends ConsumerStatefulWidget {
  const PostAuditionScreen({super.key});

  @override
  ConsumerState<PostAuditionScreen> createState() =>
      _PostAuditionScreenState();
}

class _PostAuditionScreenState extends ConsumerState<PostAuditionScreen> {
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
  bool _isPublishing = false;
  bool _isSavingDraft = false;

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

  Future<void> _pickDate({required bool isDeadline}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
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

  Future<void> _submit({required bool publish}) async {
    if (!_formKey.currentState!.validate()) return;

    if (_deadlineDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an application deadline.')),
      );
      return;
    }

    if (_auditionDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an audition date.')),
      );
      return;
    }

    final userId = ref.read(authStateProvider).valueOrNull?.uid;
    if (userId == null) return;

    setState(() {
      if (publish) {
        _isPublishing = true;
      } else {
        _isSavingDraft = true;
      }
    });

    try {
      final firestoreService = ref.read(firestoreServiceProvider);

      // Fetch recruiter profile to populate recruiterName and companyName.
      final recruiterProfile =
          await firestoreService.getRecruiterProfile(userId);

      // Use the Firebase Auth display name for recruiterName, falling back to
      // companyName or email so the audition always shows a human-readable
      // poster identity.
      final authUser = ref.read(authStateProvider).valueOrNull;
      final recruiterDisplayName = authUser?.displayName ??
          recruiterProfile?.companyName ??
          authUser?.email ??
          '';

      final now = DateTime.now();
      final audition = Audition(
        id: '',
        recruiterId: userId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory!,
        experienceLevel: _selectedExperience!,
        location: _locationController.text.trim(),
        payInfo: _payController.text.trim().isNotEmpty
            ? _payController.text.trim()
            : null,
        deadline: _deadlineDate!,
        status: publish ? AuditionStatus.ACTIVE : AuditionStatus.DRAFT,
        applicantCount: 0,
        createdAt: now,
        updatedAt: now,
        recruiterName: recruiterDisplayName,
        companyName: recruiterProfile?.companyName,
      );

      await firestoreService.createAudition(audition);

      ref.invalidate(recruiterAuditionsProvider(userId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              publish
                  ? 'Audition published successfully!'
                  : 'Draft saved successfully!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        _resetForm();
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
      if (mounted) {
        setState(() {
          _isPublishing = false;
          _isSavingDraft = false;
        });
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _durationController.clear();
    _requirementsController.clear();
    _positionsController.clear();
    _payController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedExperience = null;
      _deadlineDate = null;
      _auditionDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Post Audition',
        showBack: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    value == null ? 'Please select an experience level' : null,
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
                controller: _durationController,
                label: 'Duration',
                hint: 'e.g. 2 weeks, 3 months',
                prefixIcon: const Icon(Icons.timer_outlined),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _requirementsController,
                label: 'Requirements',
                hint: 'Specific requirements for applicants...',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _positionsController,
                      label: 'Number of Positions',
                      hint: 'e.g. 3',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _payController,
                      label: 'Pay Info (Optional)',
                      hint: 'e.g. 50,000/month',
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ],
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
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: 'Save as Draft',
                      variant: ButtonVariant.outline,
                      isLoading: _isSavingDraft,
                      onPressed:
                          _isPublishing ? null : () => _submit(publish: false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      label: 'Publish',
                      variant: ButtonVariant.primary,
                      isLoading: _isPublishing,
                      onPressed:
                          _isSavingDraft ? null : () => _submit(publish: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
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
