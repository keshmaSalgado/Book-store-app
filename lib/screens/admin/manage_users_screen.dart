import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../services/user_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/empty_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<UserModel> _users = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _currentAdminId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndUsers();
  }

  Future<void> _loadCurrentUserAndUsers() async {
    _currentAdminId = await ApiService.getUserId();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await UserService.getUsers();

    if (!mounted) return;

    if (response.success && response.data != null) {
      setState(() {
        _users = response.data!;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.message;
        _isLoading = false;
      });
    }
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String role = 'customer';
    String status = 'active';
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add New User'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: nameController,
                    label: 'Full Name *',
                    validator: Validators.validateName,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: emailController,
                    label: 'Email Address *',
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: passwordController,
                    label: 'Password *',
                    isPassword: true,
                    validator: Validators.validatePassword,
                  ),
                  const SizedBox(height: 12),
                  const Text('Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: role,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'customer', child: Text('Customer')),
                      DropdownMenuItem(value: 'staff', child: Text('Store Staff')),
                      DropdownMenuItem(value: 'admin', child: Text('Administrator')),
                    ],
                    onChanged: (val) => setDialogState(() => role = val!),
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cancel', style: TextStyle(color: AppConstants.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isSaving = true);

                      final response = await UserService.addUser(
                        name: nameController.text,
                        email: emailController.text,
                        password: passwordController.text,
                        role: role,
                        status: status,
                      );

                      if (!context.mounted) return;

                      if (response.success) {
                        Navigator.pop(ctx);
                        _fetchUsers();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User created successfully'),
                            backgroundColor: AppConstants.successColor,
                          ),
                        );
                      } else {
                        setDialogState(() => isSaving = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response.message),
                            backgroundColor: AppConstants.dangerColor,
                          ),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create User', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(UserModel user) {
    String role = user.role;
    String status = user.status;
    final isSelf = user.id == _currentAdminId;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit User: ${user.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${user.email}', style: const TextStyle(color: AppConstants.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),
              const Text('Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: role,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: [
                  const DropdownMenuItem(value: 'customer', child: Text('Customer')),
                  const DropdownMenuItem(value: 'staff', child: Text('Store Staff')),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text(isSelf ? 'Administrator (Current You)' : 'Administrator'),
                  ),
                ],
                onChanged: isSelf ? null : (val) => setDialogState(() => role = val!),
              ),
              const SizedBox(height: 16),
              const Text('Account Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: status,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive (Disabled)')),
                ],
                onChanged: isSelf ? null : (val) => setDialogState(() => status = val!),
              ),
              if (isSelf) ...[
                const SizedBox(height: 8),
                const Text(
                  'Note: You cannot revoke or deactivate your own admin account.',
                  style: TextStyle(fontSize: 11, color: AppConstants.textMuted, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cancel', style: TextStyle(color: AppConstants.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      setDialogState(() => isSaving = true);
                      final response = await UserService.updateUser(user.id, {
                        'role': role,
                        'status': status,
                      });

                      if (!context.mounted) return;

                      if (response.success) {
                        Navigator.pop(ctx);
                        _fetchUsers();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User permissions updated'),
                            backgroundColor: AppConstants.successColor,
                          ),
                        );
                      } else {
                        setDialogState(() => isSaving = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response.message),
                            backgroundColor: AppConstants.dangerColor,
                          ),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteUser(UserModel user) async {
    if (user.id == _currentAdminId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot delete your own admin account!'),
          backgroundColor: AppConstants.dangerColor,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User Account'),
        content: Text('Are you sure you want to delete ${user.name} (${user.email})? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppConstants.dangerColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final response = await UserService.deleteUser(user.id);
    if (!mounted) return;

    if (response.success) {
      _fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: AppConstants.dangerColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'User Management',
          style: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppConstants.textPrimary),
            onPressed: _fetchUsers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppConstants.primaryColor,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Add User', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: _showAddUserDialog,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading user accounts...');
    }

    if (_errorMessage != null) {
      return CustomErrorWidget(message: _errorMessage!, onRetry: _fetchUsers);
    }

    if (_users.isEmpty) {
      return const EmptyWidget(
        icon: Icons.people_outline_rounded,
        title: 'No users found',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      itemCount: _users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = _users[index];
        final isSelf = user.id == _currentAdminId;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: user.isAdmin
                    ? AppConstants.primaryColor
                    : (user.isStaff ? AppConstants.accentColor : Colors.grey.shade400),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelf) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('YOU', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: const TextStyle(color: AppConstants.textSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppConstants.surfaceColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user.role.toUpperCase(),
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppConstants.textPrimary),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: user.isActive ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: user.isActive ? AppConstants.successColor : AppConstants.dangerColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20, color: AppConstants.primaryColor),
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    tooltip: 'Edit User',
                    onPressed: () => _showEditUserDialog(user),
                  ),
                  if (!isSelf) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: AppConstants.dangerColor),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                      tooltip: 'Delete User',
                      onPressed: () => _deleteUser(user),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
