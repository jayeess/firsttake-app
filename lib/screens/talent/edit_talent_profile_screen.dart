import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/talent_profile_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../routing/route_names.dart';
import '../../utils/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_indicator.dart';

class EditTalentProfileScreen extends ConsumerStatefulWidget {
  final bool isOnboarding;

  const EditTalentProfileScreen({super.key, this.isOnboarding = false});

  @override
  ConsumerState<EditTalentProfileScreen> createState() =>
      _EditTalentProfileScreenState();
}

class _EditTalentProfileScreenState
    extends ConsumerState<EditTalentProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isInitialized = false;

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late final TextEditingController _bioController;
  late final TextEditingController _locationController;
  late final TextEditingController _instagramController;
  late final TextEditingController _youtubeController;
  late final TextEditingController _websiteController;

  Gender? _selectedGender;
  TalentCategory _selectedCategory = TalentCategory.ACTOR;
  ExperienceLevel _selectedExperience = ExperienceLevel.FRESHER;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _bioController = TextEditingController();
    _locationController = TextEditingController();
    _instagramController = TextEditingController();
    _youtubeController = TextEditingController();
    _websiteController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _populateFields(TalentProfile profile) {
    if (_isInitialized) return;
    _isInitialized = true;

    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _ageController.text = profile.age?.toString() ?? '';
    _heightController.text = profile.height?.toString() ?? '';
    _bioController.text = profile.bio ?? '';
    _locationController.text = profile.location ?? '';
    _instagramController.text = profile.instagramUrl ?? '';
    _youtubeController.text = profile.youtubeUrl ?? '';
    _websiteController.text = profile.websiteUrl ?? '';
    _selectedGender = profile.gender;
    _selectedCategory = profile.category;
    _selectedExperience = profile.experienceLevel;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.valueOrNull?.uid;

    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in')),
      );
    }

    final profileAsync = ref.watch(talentProfileProvider(currentUserId));

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.isOnboarding ? 'Set Up Profile' : 'Edit Profile',
        showBack: !widget.isOnboarding,
      ),
      body: profileAsync.when(
        loading: () =>
            const LoadingIndicator(message: 'Loading profile...'),
        error: (error, stack) {
          if (widget.isOnboarding) {
            // For onboarding, show the empty form
            return _buildForm(context, currentUserId, null);
          }
          return EmptyState(
            icon: Icons.error_outline,
            title: 'Could not load profile',
            action: TextButton.icon(
              onPressed: () =>
                  ref.invalidate(talentProfileProvider(currentUserId)),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          );
        },
        data: (profile) {
          if (profile != null) {
            _populateFields(profile);
          }
          return _buildForm(context, currentUserId, profile);
        },
      ),
    );
  }

  Widget _buildForm(
      BuildContext context, String userId, TalentProfile? existing) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.isOnboarding) ...[
            Text(
              'Tell us about yourself',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Complete your profile so recruiters can find you.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
          ],

          // Name fields
          _buildSectionHeader(context, 'Basic Information'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  hint: 'Enter first name',
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  hint: 'Enter last name',
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Last name is required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _ageController,
                  label: 'Age',
                  hint: 'e.g. 25',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final age = int.tryParse(value);
                      if (age == null || age < 16 || age > 100) {
                        return 'Enter valid age (16-100)';
                      }
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<Gender>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                  ),
                  items: Gender.values.map((g) {
                    return DropdownMenuItem(
                      value: g,
                      child: Text(_genderDisplayName(g)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedGender = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _heightController,
            label: 'Height (cm)',
            hint: 'e.g. 170',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final height = double.tryParse(value);
                if (height == null || height < 100 || height > 250) {
                  return 'Enter valid height (100-250 cm)';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _bioController,
            label: 'Bio',
            hint: 'Tell recruiters about yourself, your skills, and experience...',
            maxLines: 4,
            maxLength: 500,
            textInputAction: TextInputAction.newline,
          ),
          const SizedBox(height: 24),

          // Category & Experience
          _buildSectionHeader(context, 'Professional Details'),
          const SizedBox(height: 12),

          DropdownButtonFormField<TalentCategory>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
            ),
            items: TalentCategory.values.map((cat) {
              return DropdownMenuItem(
                value: cat,
                child: Text(_categoryDisplayName(cat)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCategory = value);
              }
            },
            validator: (value) {
              if (value == null) return 'Please select a category';
              return null;
            },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<ExperienceLevel>(
            value: _selectedExperience,
            decoration: const InputDecoration(
              labelText: 'Experience Level',
            ),
            items: ExperienceLevel.values.map((exp) {
              return DropdownMenuItem(
                value: exp,
                child: Text(_experienceDisplayName(exp)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedExperience = value);
              }
            },
            validator: (value) {
              if (value == null) {
                return 'Please select experience level';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _locationController,
            label: 'Location',
            hint: 'e.g. Mumbai, Maharashtra',
            prefixIcon:
                const Icon(Icons.location_on_outlined, size: 20),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 24),

          // Social links
          _buildSectionHeader(context, 'Social Links'),
          const SizedBox(height: 4),
          Text(
            'Optional - helps recruiters learn more about you',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textHint),
          ),
          const SizedBox(height: 12),

          CustomTextField(
            controller: _instagramController,
            label: 'Instagram',
            hint: 'https://instagram.com/yourprofile',
            prefixIcon:
                const Icon(Icons.camera_alt_outlined, size: 20),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _youtubeController,
            label: 'YouTube',
            hint: 'https://youtube.com/@yourchannel',
            prefixIcon:
                const Icon(Icons.play_circle_outline, size: 20),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _websiteController,
            label: 'Website / Portfolio',
            hint: 'https://yourportfolio.com',
            prefixIcon: const Icon(Icons.language, size: 20),
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 32),

          // Save button
          CustomButton(
            label: widget.isOnboarding ? 'Complete Profile' : 'Save Changes',
            isLoading: _isLoading,
            onPressed: () => _saveProfile(userId, existing),
          ),

          if (widget.isOnboarding) ...[
            const SizedBox(height: 12),
            CustomButton(
              label: 'Skip for now',
              variant: ButtonVariant.text,
              onPressed: () => context.goNamed(RouteNames.talentHome),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _saveProfile(
      String userId, TalentProfile? existing) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      final now = DateTime.now();

      if (existing != null) {
        // Update existing profile
        final updates = <String, dynamic>{
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'age': _ageController.text.isNotEmpty
              ? int.parse(_ageController.text.trim())
              : null,
          'gender': _selectedGender?.name,
          'height': _heightController.text.isNotEmpty
              ? double.parse(_heightController.text.trim())
              : null,
          'bio': _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
          'category': _selectedCategory.name,
          'experienceLevel':
              experienceLevelToString[_selectedExperience],
          'location': _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          'instagramUrl': _instagramController.text.trim().isEmpty
              ? null
              : _instagramController.text.trim(),
          'youtubeUrl': _youtubeController.text.trim().isEmpty
              ? null
              : _youtubeController.text.trim(),
          'websiteUrl': _websiteController.text.trim().isEmpty
              ? null
              : _websiteController.text.trim(),
        };

        await firestoreService.updateTalentProfile(userId, updates);
      } else {
        // Create new profile
        final profile = TalentProfile(
          id: 'default',
          userId: userId,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          age: _ageController.text.isNotEmpty
              ? int.parse(_ageController.text.trim())
              : null,
          gender: _selectedGender,
          height: _heightController.text.isNotEmpty
              ? double.parse(_heightController.text.trim())
              : null,
          bio: _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
          category: _selectedCategory,
          experienceLevel: _selectedExperience,
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          instagramUrl: _instagramController.text.trim().isEmpty
              ? null
              : _instagramController.text.trim(),
          youtubeUrl: _youtubeController.text.trim().isEmpty
              ? null
              : _youtubeController.text.trim(),
          websiteUrl: _websiteController.text.trim().isEmpty
              ? null
              : _websiteController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );

        await firestoreService.createTalentProfile(userId, profile);
      }

      // Invalidate provider to refresh cached data
      ref.invalidate(talentProfileProvider(userId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        if (widget.isOnboarding) {
          context.goNamed(RouteNames.talentHome);
        } else {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  String _genderDisplayName(Gender gender) {
    switch (gender) {
      case Gender.MALE:
        return 'Male';
      case Gender.FEMALE:
        return 'Female';
      case Gender.OTHER:
        return 'Other';
    }
  }

  String _categoryDisplayName(TalentCategory category) {
    switch (category) {
      case TalentCategory.ACTOR:
        return 'Actor';
      case TalentCategory.MODEL:
        return 'Model';
      case TalentCategory.DANCER:
        return 'Dancer';
      case TalentCategory.VOICE_ARTIST:
        return 'Voice Artist';
      case TalentCategory.ANCHOR:
        return 'Anchor';
    }
  }

  String _experienceDisplayName(ExperienceLevel level) {
    switch (level) {
      case ExperienceLevel.FRESHER:
        return 'Fresher';
      case ExperienceLevel.ONE_3_YRS:
        return '1-3 Years';
      case ExperienceLevel.THREE_5_YRS:
        return '3-5 Years';
      case ExperienceLevel.FIVE_PLUS_YRS:
        return '5+ Years';
    }
  }
}
