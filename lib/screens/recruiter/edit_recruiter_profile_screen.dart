import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../models/recruiter_profile_model.dart';
import '../../utils/theme/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_indicator.dart';

class EditRecruiterProfileScreen extends ConsumerStatefulWidget {
  final bool isOnboarding;

  const EditRecruiterProfileScreen({super.key, this.isOnboarding = false});

  @override
  ConsumerState<EditRecruiterProfileScreen> createState() => _EditRecruiterProfileScreenState();
}

class _EditRecruiterProfileScreenState extends ConsumerState<EditRecruiterProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteController = TextEditingController();
  bool _isLoading = false;
  bool _profileLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isOnboarding) _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final profile = await ref.read(firestoreServiceProvider).getRecruiterProfile(user.uid);
      if (profile != null && mounted) {
        setState(() {
          _companyNameController.text = profile.companyName;
          _bioController.text = profile.bio ?? '';
          _phoneController.text = profile.phone ?? '';
          _addressController.text = profile.address ?? '';
          _websiteController.text = profile.website ?? '';
          _profileLoaded = true;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final profile = RecruiterProfile(
        id: 'default',
        userId: user.uid,
        companyName: _companyNameController.text.trim(),
        bio: _bioController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        website: _websiteController.text.trim(),
        isVerified: false,
        verificationDocuments: const [],
        createdAt: now,
        updatedAt: now,
      );

      if (widget.isOnboarding) {
        await ref.read(firestoreServiceProvider).createRecruiterProfile(user.uid, profile);
      } else {
        await ref.read(firestoreServiceProvider).updateRecruiterProfile(user.uid, {
          'companyName': profile.companyName,
          'bio': profile.bio,
          'phone': profile.phone,
          'address': profile.address,
          'website': profile.website,
        });
      }

      if (mounted) {
        ref.invalidate(recruiterProfileProvider(user.uid));
        if (widget.isOnboarding) {
          context.go('/recruiter');
        } else {
          context.pop();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isOnboarding ? 'Company Setup' : 'Edit Profile'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.isOnboarding) ...[
                Text(
                  'Set up your company profile',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'This information will be visible to talent on the platform.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
              ],

              CustomTextField(
                controller: _companyNameController,
                label: 'Company Name *',
                hint: 'Enter your company or organization name',
                prefixIcon: const Icon(Icons.business),
                validator: (v) => v == null || v.trim().isEmpty ? 'Company name is required' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _bioController,
                label: 'Company Description',
                hint: 'Brief description of your company (max 500 chars)',
                maxLines: 4,
                maxLength: 500,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _phoneController,
                label: 'Phone',
                hint: 'Contact phone number',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _addressController,
                label: 'Address',
                hint: 'Company address',
                prefixIcon: const Icon(Icons.location_on),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _websiteController,
                label: 'Website',
                hint: 'https://yourcompany.com',
                keyboardType: TextInputType.url,
                prefixIcon: const Icon(Icons.language),
              ),
              const SizedBox(height: 32),

              CustomButton(
                label: widget.isOnboarding ? 'Create Profile' : 'Save Changes',
                onPressed: _isLoading ? null : _handleSave,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
