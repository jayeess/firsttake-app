import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/user_provider.dart';
import '../../services/storage_service.dart';
import '../../models/media_file_model.dart';
import '../../utils/theme/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_indicator.dart';

final _storageServiceProvider = Provider<StorageService>((ref) => StorageService());

final _mediaFilesProvider = FutureProvider.autoDispose<List<MediaFile>>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];
  final firestore = ref.read(firestoreServiceProvider);
  try {
    final snapshot = await firestore.getTalentProfile(user.uid);
    // Media files would typically be fetched from subcollection
    // For now return empty list - media tracked via profile fields
    return [];
  } catch (_) {
    return [];
  }
});

class MediaUploadScreen extends ConsumerStatefulWidget {
  const MediaUploadScreen({super.key});

  @override
  ConsumerState<MediaUploadScreen> createState() => _MediaUploadScreenState();
}

class _MediaUploadScreenState extends ConsumerState<MediaUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? _uploadingLabel;
  final List<String> _photoUrls = [];
  String? _videoUrl;

  @override
  void initState() {
    super.initState();
    _loadExistingMedia();
  }

  Future<void> _loadExistingMedia() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final profile = await ref.read(firestoreServiceProvider).getTalentProfile(user.uid);
      if (profile != null && mounted) {
        setState(() {
          if (profile.profilePhotoUrl != null && profile.profilePhotoUrl!.isNotEmpty) {
            _photoUrls.add(profile.profilePhotoUrl!);
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _pickAndUploadPhoto() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 85);
    if (file == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isUploading = true;
      _uploadingLabel = 'Uploading photo...';
    });

    try {
      final bytes = await file.readAsBytes();
      final url = await ref.read(_storageServiceProvider).uploadProfilePhoto(
        user.uid,
        bytes,
        file.name,
      );
      if (mounted) {
        setState(() {
          _photoUrls.add(url);
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded successfully'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _pickAndUploadVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 60));
    if (file == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isUploading = true;
      _uploadingLabel = 'Uploading video...';
    });

    try {
      final bytes = await file.readAsBytes();
      final sizeMB = bytes.length / (1024 * 1024);
      if (sizeMB > 100) {
        if (mounted) {
          setState(() => _isUploading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video must be under 100MB'), backgroundColor: AppColors.error),
          );
        }
        return;
      }
      final url = await ref.read(_storageServiceProvider).uploadIntroVideo(
        user.uid,
        bytes,
        file.name,
      );
      if (mounted) {
        setState(() {
          _videoUrl = url;
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video uploaded successfully'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _deletePhoto(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await ref.read(_storageServiceProvider).deleteFile(_photoUrls[index]);
        setState(() => _photoUrls.removeAt(index));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Media'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isUploading
          ? LoadingIndicator(message: _uploadingLabel)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photos section
                  Text('Portfolio Photos', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    'Upload up to 5 photos (JPG/PNG, max 5MB each)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  if (_photoUrls.isEmpty)
                    Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library_outlined, size: 48, color: AppColors.textHint),
                          SizedBox(height: 8),
                          Text('No photos uploaded yet', style: TextStyle(color: AppColors.textHint)),
                        ],
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _photoUrls.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _photoUrls[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.surfaceVariant,
                                  child: const Icon(Icons.broken_image, color: AppColors.textHint),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _deletePhoto(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                            if (index == 0)
                              Positioned(
                                bottom: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Primary',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  const SizedBox(height: 12),
                  if (_photoUrls.length < 5)
                    CustomButton(
                      label: 'Add Photo',
                      icon: Icons.add_photo_alternate_outlined,
                      variant: ButtonVariant.outline,
                      onPressed: _pickAndUploadPhoto,
                    ),
                  const SizedBox(height: 32),

                  // Video section
                  Text('Introduction Video', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    '30-60 second intro video (MP4, max 100MB)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  if (_videoUrl == null)
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam_outlined, size: 48, color: AppColors.textHint),
                          SizedBox(height: 8),
                          Text('No video uploaded yet', style: TextStyle(color: AppColors.textHint)),
                        ],
                      ),
                    )
                  else
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(Icons.play_circle_outline, size: 64, color: Colors.white70),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete Video'),
                                  content: const Text('Are you sure?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                try {
                                  await ref.read(_storageServiceProvider).deleteFile(_videoUrl!);
                                  setState(() => _videoUrl = null);
                                } catch (_) {}
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  if (_videoUrl == null)
                    CustomButton(
                      label: 'Upload Video',
                      icon: Icons.videocam_outlined,
                      variant: ButtonVariant.outline,
                      onPressed: _pickAndUploadVideo,
                    ),
                ],
              ),
            ),
    );
  }
}
