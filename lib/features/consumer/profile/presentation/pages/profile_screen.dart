import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:yayvo/core/providers/theme_provider.dart';
import 'package:yayvo/core/services/storage/user_session_service.dart';
import 'package:yayvo/features/auth/domain/entities/consumer_entity.dart';
import 'package:yayvo/features/auth/presentation/pages/login_page.dart';
import 'package:yayvo/features/consumer/profile/domain/usecases/get_consumer_usecase.dart';
import 'package:yayvo/features/consumer/profile/domain/usecases/update_consumer_usecase.dart';
import 'package:yayvo/features/consumer/profile/domain/usecases/upload_profile_picture_usecase.dart';

import '../widgets/edit_profile.dart';
import '../widgets/profile_part.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  ConsumerEntity? _consumer;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // ================= LOAD PROFILE =================
  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Defensive read: ensure provider returns the expected type
      final sessionService = ref.read(userSessionServiceProvider);
      debugPrint('ProfileScreen: userSessionServiceProvider returned: $sessionService');

      if (sessionService == null) {
        throw Exception('Session service not available');
      }

      final session = sessionService.getUserSession();
      final authId = session?.userId;
      if (authId == null) {
        throw Exception('User not authenticated');
      }

      final consumer = await ref.read(getConsumerUseCaseProvider)(authId);

      if (!mounted) return;

      if (consumer == null) {
        throw Exception('Failed to load consumer data');
      }

      setState(() {
        _consumer = consumer;
        _error = null;
      });
    } catch (e, st) {
      if (!mounted) return;
      debugPrint('ProfileScreen: load error: $e\n$st');
      setState(() {
        _error = e.toString();
        _consumer = null;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  // ================= UPDATE PROFILE =================
  Future<void> _updateProfile(ConsumerEntity consumer) async {
    try {
      final updated = await ref.read(updateConsumerUseCaseProvider)(consumer);

      if (!mounted) return;

      if (updated == null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Update failed: no data returned'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _consumer = updated);

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('ProfileScreen: update error: $e');
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= UPLOAD PROFILE PICTURE =================
  Future<void> _uploadPicture() async {
    final picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final image = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image == null) return;

    if (kDebugMode) {
      debugPrint('Uploading image: ${image.path}');
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Uploading profile picture...')
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    try {
      final updated = await ref.read(uploadProfilePictureUseCaseProvider)(image);

      if (!mounted) return;

      if (updated == null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload failed: no data returned'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _consumer = updated);

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('ProfileScreen: upload error: $e');
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= LOGOUT =================
  Future<void> _logout() async {
    try {
      await ref.read(userSessionServiceProvider).clearSession();
    } catch (e) {
      debugPrint('ProfileScreen: clearSession error: $e');
    }

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_consumer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No profile data available.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Reload Profile'),
              ),
            ],
          ),
        ),
      );
    }

    final consumer = _consumer!;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ProfilePart(
                user: consumer,
                onTapCamera: _uploadPicture,
              ),
              const SizedBox(height: 20),
              EditProfileSection(
                user: consumer,
                onSave: _updateProfile,
              ),
              const SizedBox(height: 20),
              _buildTheme(),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.red,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTheme() {
    final mode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text('Theme'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => notifier.setThemeMode(ThemeMode.light),
                    child: const Text('Light'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => notifier.setThemeMode(ThemeMode.dark),
                    child: const Text('Dark'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => notifier.setThemeMode(ThemeMode.system),
                    child: const Text('System'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
