import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../utils/theme/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_indicator.dart';

// ---------------------------------------------------------------------------
// Providers scoped to user management
// ---------------------------------------------------------------------------

final _allUsersProvider =
    FutureProvider.autoDispose<List<UserModel>>((ref) async {
  return ref.read(firestoreServiceProvider).getAllUsers();
});

// ---------------------------------------------------------------------------
// UserManagementScreen
// ---------------------------------------------------------------------------

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  UserType? _selectedFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserModel> _applyFilters(List<UserModel> users) {
    var filtered = users;

    // Apply user type filter
    if (_selectedFilter != null) {
      filtered =
          filtered.where((u) => u.userType == _selectedFilter).toList();
    }

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      final lower = _searchQuery.toLowerCase();
      filtered = filtered
          .where((u) =>
              u.email.toLowerCase().contains(lower) ||
              u.uid.toLowerCase().contains(lower))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(_allUsersProvider);

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'User Management',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 16),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomTextField(
              controller: _searchController,
              hint: 'Search by email or user ID...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          const SizedBox(height: 12),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _selectedFilter == null,
                  onTap: () => setState(() => _selectedFilter = null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Talent',
                  selected: _selectedFilter == UserType.TALENT,
                  onTap: () =>
                      setState(() => _selectedFilter = UserType.TALENT),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Recruiter',
                  selected: _selectedFilter == UserType.RECRUITER,
                  onTap: () =>
                      setState(() => _selectedFilter = UserType.RECRUITER),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // User list
          Expanded(
            child: usersAsync.when(
              data: (users) {
                final filtered = _applyFilters(users);
                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.people_outline,
                    title: 'No users found',
                    subtitle: _searchQuery.isNotEmpty || _selectedFilter != null
                        ? 'Try adjusting your search or filters'
                        : 'No users have registered yet',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(_allUsersProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _UserCard(
                        user: filtered[index],
                        onTap: () => _showUserDetailDialog(filtered[index]),
                      );
                    },
                  ),
                );
              },
              loading: () =>
                  const LoadingIndicator(message: 'Loading users...'),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 48),
                    const SizedBox(height: 12),
                    Text('Failed to load users',
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 4),
                    Text('$e',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    CustomButton(
                      label: 'Retry',
                      variant: ButtonVariant.outline,
                      width: 120,
                      onPressed: () => ref.invalidate(_allUsersProvider),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // User detail dialog
  // -------------------------------------------------------------------------

  void _showUserDetailDialog(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            final dateFormat = DateFormat('MMM d, yyyy');
            final isSuspended =
                user.accountStatus == AccountStatus.SUSPENDED;
            final isDeleted =
                user.accountStatus == AccountStatus.DELETED;

            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                // Drag indicator
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // User avatar & name
                Center(
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: user.userType == UserType.TALENT
                        ? AppColors.primary
                        : AppColors.secondary,
                    child: Icon(
                      user.userType == UserType.TALENT
                          ? Icons.person
                          : Icons.business,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    user.email,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: _UserTypeBadge(userType: user.userType),
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                // Detail rows
                _DetailRow(
                  label: 'User ID',
                  value: user.uid,
                ),
                _DetailRow(
                  label: 'Phone',
                  value: user.phone,
                ),
                _DetailRow(
                  label: 'Email Verified',
                  value: user.emailVerified ? 'Yes' : 'No',
                ),
                _DetailRow(
                  label: 'Phone Verified',
                  value: user.phoneVerified ? 'Yes' : 'No',
                ),
                _DetailRow(
                  label: 'Account Status',
                  value: user.accountStatus.name,
                ),
                _DetailRow(
                  label: 'Joined',
                  value: dateFormat.format(user.createdAt),
                ),
                if (user.lastLogin != null)
                  _DetailRow(
                    label: 'Last Login',
                    value: dateFormat.format(user.lastLogin!),
                  ),

                const SizedBox(height: 24),

                // Action buttons
                if (!isDeleted) ...[
                  if (isSuspended)
                    CustomButton(
                      label: 'Unblock User',
                      variant: ButtonVariant.primary,
                      icon: Icons.lock_open,
                      onPressed: () =>
                          _confirmAction(
                            context: context,
                            title: 'Unblock User',
                            message:
                                'Are you sure you want to unblock ${user.email}?',
                            confirmLabel: 'Unblock',
                            onConfirm: () async {
                              await ref
                                  .read(firestoreServiceProvider)
                                  .updateUserStatus(
                                      user.uid, AccountStatus.ACTIVE);
                              ref.invalidate(_allUsersProvider);
                              if (ctx.mounted) Navigator.of(ctx).pop();
                            },
                          ),
                    )
                  else
                    CustomButton(
                      label: 'Block User',
                      variant: ButtonVariant.outline,
                      icon: Icons.block,
                      onPressed: () =>
                          _confirmAction(
                            context: context,
                            title: 'Block User',
                            message:
                                'Are you sure you want to block ${user.email}? They will not be able to access the platform.',
                            confirmLabel: 'Block',
                            isDangerous: true,
                            onConfirm: () async {
                              await ref
                                  .read(firestoreServiceProvider)
                                  .updateUserStatus(
                                      user.uid, AccountStatus.SUSPENDED);
                              ref.invalidate(_allUsersProvider);
                              if (ctx.mounted) Navigator.of(ctx).pop();
                            },
                          ),
                    ),
                  const SizedBox(height: 12),
                  CustomButton(
                    label: 'Delete User',
                    variant: ButtonVariant.danger,
                    icon: Icons.delete_forever,
                    onPressed: () => _confirmAction(
                      context: context,
                      title: 'Delete User',
                      message:
                          'Are you sure you want to delete ${user.email}? This action cannot be undone.',
                      confirmLabel: 'Delete',
                      isDangerous: true,
                      onConfirm: () async {
                        await ref
                            .read(firestoreServiceProvider)
                            .updateUserStatus(
                                user.uid, AccountStatus.DELETED);
                        ref.invalidate(_allUsersProvider);
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      },
                    ),
                  ),
                ] else
                  Center(
                    child: Text(
                      'This account has been deleted',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.error),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmAction({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    required Future<void> Function() onConfirm,
    bool isDangerous = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: isDangerous ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await onConfirm();
        if (mounted) {
          ScaffoldMessenger.of(this.context).showSnackBar(
            SnackBar(
              content: Text('$title completed successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(this.context).showSnackBar(
            SnackBar(
              content: Text('Action failed: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Filter Chip
// ---------------------------------------------------------------------------

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// User Card
// ---------------------------------------------------------------------------

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const _UserCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: user.userType == UserType.TALENT
                    ? AppColors.primary.withOpacity(0.15)
                    : AppColors.secondary.withOpacity(0.15),
                child: Icon(
                  user.userType == UserType.TALENT
                      ? Icons.person
                      : Icons.business,
                  color: user.userType == UserType.TALENT
                      ? AppColors.primary
                      : AppColors.secondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.email,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _UserTypeBadge(userType: user.userType),
                        const SizedBox(width: 8),
                        _StatusBadge(status: user.accountStatus),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Joined ${dateFormat.format(user.createdAt)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textHint),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// User Type Badge
// ---------------------------------------------------------------------------

class _UserTypeBadge extends StatelessWidget {
  final UserType userType;

  const _UserTypeBadge({required this.userType});

  @override
  Widget build(BuildContext context) {
    final isTalent = userType == UserType.TALENT;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isTalent
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isTalent ? 'Talent' : 'Recruiter',
        style: TextStyle(
          color: isTalent ? AppColors.primary : AppColors.secondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status Badge
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  final AccountStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case AccountStatus.ACTIVE:
        bgColor = AppColors.successLight;
        textColor = AppColors.success;
        label = 'Active';
      case AccountStatus.SUSPENDED:
        bgColor = AppColors.warningLight;
        textColor = AppColors.warning;
        label = 'Blocked';
      case AccountStatus.DELETED:
        bgColor = AppColors.errorLight;
        textColor = AppColors.error;
        label = 'Deleted';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail Row
// ---------------------------------------------------------------------------

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
