import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';
import 'package:yayvo/core/services/storage/user_session_service.dart';
import 'package:yayvo/features/auth/presentation/pages/login_page.dart';
import 'package:yayvo/features/consumer/profile/presentation/widgets/change_password.dart';
import 'package:yayvo/features/consumer/profile/presentation/widgets/edit_profile.dart';
import 'package:yayvo/features/consumer/profile/presentation/widgets/profile_part.dart';
import 'package:yayvo/features/consumer/profile/presentation/widgets/theme_selector.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final Future<ConsumerEntity> Function(ConsumerEntity updated)? onUpdateUser;
  final Future<ConsumerEntity> Function(File pickedImage)? onUploadProfilePicture;
  final Future<void> Function(String current, String next)? onChangePassword;
  final Future<void> Function()? onLogout;

  const ProfileScreen({
    Key? key,
    this.onUpdateUser,
    this.onUploadProfilePicture,
    this.onChangePassword,
    this.onLogout,
  }) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late ConsumerEntity _user;
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _user = const ConsumerEntity(
      fullName: 'Guest User',
      username: 'guest',
      profilePicture: null,
    );
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source);
      if (picked == null) return;
      final file = File(picked.path);

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Use this photo?'),
          content: Image.file(file, width: 200, height: 200, fit: BoxFit.cover),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Use')),
          ],
        ),
      );

      if (confirmed != true) return;

      setState(() => _loading = true);

      if (widget.onUploadProfilePicture != null) {
        final updated = await widget.onUploadProfilePicture!(file);
        setState(() => _user = updated);
      } else {
        setState(() => _user = _user.copyWith(profilePicture: file.path));
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture updated')));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _showImageSourceOptions() async {
    final choice = await showModalBottomSheet<String?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Choose from gallery'), onTap: () => Navigator.of(ctx).pop('gallery')),
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Take a photo'), onTap: () => Navigator.of(ctx).pop('camera')),
            ListTile(leading: const Icon(Icons.close), title: const Text('Cancel'), onTap: () => Navigator.of(ctx).pop(null)),
          ],
        ),
      ),
    );

    if (choice == 'gallery') await _pickAndUpload(ImageSource.gallery);
    if (choice == 'camera') await _pickAndUpload(ImageSource.camera);
  }

  Future<void> _saveDetails(ConsumerEntity updated) async {
    setState(() => _loading = true);
    try {
      if (widget.onUpdateUser != null) {
        final saved = await widget.onUpdateUser!(updated);
        setState(() => _user = saved);
      } else {
        setState(() => _user = updated);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _onChangePassword() async {
    final result = await showDialog<PasswordChangeResult?>(
      context: context,
      builder: (ctx) => const ChangePasswordDialog(),
    );
    if (result == null) return;

    setState(() => _loading = true);
    try {
      if (widget.onChangePassword != null) {
        await widget.onChangePassword!(result.current, result.next);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password changed')));
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _confirmAndLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Logout')),
        ],
      ),
    );

    if (shouldLogout != true) return;

    setState(() => _loading = true);
    try {
      if (widget.onLogout != null) {
        await widget.onLogout!();
      } else {
        await ref.read(userSessionServiceProvider).clearSession();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ProfilePart(user: _user, onTapCamera: _showImageSourceOptions),
                const SizedBox(height: 16),
                EditProfileSection(user: _user, onSave: _saveDetails),
                const SizedBox(height: 16),
                // ThemeSelector now handles currentMode and notifier internally
                const ThemeSelector(),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _onChangePassword,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    onPressed: _confirmAndLogout,
                  ),
                ),
              ],
            ),
            if (_loading)
              const Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: LinearProgressIndicator(),
              ),
            if (_error != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.red,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(_error!, style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
