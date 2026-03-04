import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:yayvo/core/utils/image_url_helper.dart';
import 'package:yayvo/features/consumer/presentation/shell/consumer_shell.dart';
import 'package:yayvo/features/consumer/domain/entities/consumer_entity.dart';
import 'package:yayvo/features/consumer/presentation/theme/consumer_theme.dart';
import 'package:yayvo/features/consumer/data/repositories/consumer_repository_impl.dart';
import 'package:yayvo/core/utils/network_error_helper.dart';
import 'package:yayvo/features/consumer/data/datasources/local/consumer_local_datasource.dart';
import 'package:yayvo/features/auth/domain/usecases/logout_user_usecase.dart';
import 'package:yayvo/features/auth/presentation/pages/login_page.dart';
import 'package:yayvo/features/consumer/presentation/pages/consumer_my_reviews_screen.dart';
import 'package:yayvo/core/providers/theme_provider.dart';

class ConsumerProfileScreen extends ConsumerStatefulWidget {
  const ConsumerProfileScreen({super.key});

  @override
  ConsumerState<ConsumerProfileScreen> createState() =>
      _ConsumerProfileScreenState();
}

class _ConsumerProfileScreenState extends ConsumerState<ConsumerProfileScreen> {
  bool _loading = true;
  bool _uploadingPic = false;
  String? _error;
  ConsumerEntity? _consumer;
  /// Bump after upload so CachedNetworkImage loads fresh (same URL, new file on server).
  int _profilePicCacheKey = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final authId = ref.read(consumerAuthIdProvider);
    if (authId == null || authId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Not logged in';
      });
      return;
    }
    final local = ref.read(consumerLocalProvider);
    final cached = local.getConsumerProfileCache(authId);
    if (cached != null) {
      setState(() {
        _consumer = cached.toEntity();
        _loading = false;
        _error = null;
        _profilePicCacheKey = DateTime.now().millisecondsSinceEpoch;
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final usecase = ref.read(getConsumerProfileProvider);
      final result = await usecase.call(authId);
      if (!mounted) return;
      result.fold(
        (f) => setState(() {
          _loading = false;
          _error = normalizeNetworkErrorMessage(f.message.contains('401') || f.message.contains('Unauthorized')
              ? 'Session expired. Please log in again.'
              : f.message);
        }),
        (consumer) {
          setState(() {
            _loading = false;
            _consumer = consumer;
            _profilePicCacheKey = DateTime.now().millisecondsSinceEpoch;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = normalizeNetworkErrorMessage(e.toString());
      });
    }
  }

  Future<void> _refresh() async {
    final authId = ref.read(consumerAuthIdProvider);
    if (authId == null || authId.isEmpty) return;
    try {
      final repo = ref.read(consumerRepositoryProvider);
      final result = await repo.refreshConsumerProfile(authId);
      if (!mounted) return;
      result.fold(
        (f) => setState(() {
          _error = normalizeNetworkErrorMessage(f.message.contains('401') || f.message.contains('Unauthorized')
              ? 'Session expired. Please log in again.'
              : f.message);
        }),
        (consumer) => setState(() {
          _consumer = consumer;
          _error = null;
          _profilePicCacheKey = DateTime.now().millisecondsSinceEpoch;
        }),
      );
    } catch (_) {}
  }

  Future<void> _pickAndUploadProfilePicture() async {
    final authId = ref.read(consumerAuthIdProvider);
    if (authId == null || _consumer == null) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    final picker = ImagePicker();
    final x = await picker.pickImage(source: source);
    if (x == null || !mounted) return;
    setState(() => _uploadingPic = true);
    final repo = ref.read(consumerRepositoryProvider);
    final result = await repo.uploadProfilePicture(authId, File(x.path));
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _uploadingPic = false;
        _error = f.message;
      }),
      (updated) async {
        final baseUrl = imageUrlFromPath(updated.profilePicture);
        final currentBusted = baseUrl.isNotEmpty
            ? '$baseUrl${baseUrl.contains('?') ? '&' : '?'}v=$_profilePicCacheKey'
            : '';
        if (baseUrl.isNotEmpty) {
          try {
            await DefaultCacheManager().removeFile(baseUrl);
            final withV0 = '$baseUrl${baseUrl.contains('?') ? '&' : '?'}v=0';
            await DefaultCacheManager().removeFile(withV0);
            if (currentBusted.isNotEmpty) await DefaultCacheManager().removeFile(currentBusted);
          } catch (_) {}
          if (mounted) {
            final cache = PaintingBinding.instance.imageCache;
            cache.evict(CachedNetworkImageProvider(baseUrl));
            cache.evict(CachedNetworkImageProvider('$baseUrl${baseUrl.contains('?') ? '&' : '?'}v=0'));
            if (currentBusted.isNotEmpty) cache.evict(CachedNetworkImageProvider(currentBusted));
          }
        }
        if (!mounted) return;
        setState(() {
          _consumer = updated;
          _uploadingPic = false;
          _error = null;
          _profilePicCacheKey = DateTime.now().millisecondsSinceEpoch;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'PROFILE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: ConsumerTheme.muted,
              letterSpacing: 0.14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'My profile',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: ConsumerTheme.primaryText,
            ),
          ),
          const SizedBox(height: 24),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _error!,
                style: TextStyle(color: ConsumerTheme.error, fontSize: 14),
              ),
            )
          else if (_consumer != null)
            _buildProfilePanel()
          else
            Text(
              'Log in to see your profile.',
              style: TextStyle(color: ConsumerTheme.muted),
            ),
          if (_consumer != null) ...[
            const SizedBox(height: 32),
            _buildShowMyReviewsButton(),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref.read(logoutUserProvider).call();
                ref.read(consumerAuthIdProvider.notifier).state = null;
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text('Log out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ConsumerTheme.muted,
                side: const BorderSide(color: ConsumerTheme.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildProfilePanel() {
    final c = _consumer!;
    final profilePicUrl = imageUrlFromPath(c.profilePicture);
    final cacheBustedUrl = profilePicUrl.isNotEmpty
        ? '$profilePicUrl${profilePicUrl.contains('?') ? '&' : '?'}v=$_profilePicCacheKey'
        : '';
    final initials = c.displayName
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0].toUpperCase())
        .join();
    final displayInitials = initials.isEmpty ? '?' : initials;

    return Container(
      decoration: BoxDecoration(
        color: ConsumerTheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ConsumerTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 100,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2A2420),
                  Color(0xFF1A1612),
                  Color(0xFF3A2E24),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ConsumerTheme.surface,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: cacheBustedUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  key: ValueKey('profile_pic_$_profilePicCacheKey'),
                                  imageUrl: cacheBustedUrl,
                                  cacheKey: cacheBustedUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: ConsumerTheme.accent,
                                    child: Center(
                                      child: Text(
                                        displayInitials,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: ConsumerTheme.accent,
                                    child: Center(
                                      child: Text(
                                        displayInitials,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        ConsumerTheme.accent,
                                        ConsumerTheme.accentDark,
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      displayInitials,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Material(
                          color: ConsumerTheme.primaryText,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: _uploadingPic ? null : _pickAndUploadProfilePicture,
                            customBorder: const CircleBorder(),
                            child: Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              child: _uploadingPic
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: ConsumerTheme.accent,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 16,
                                      color: ConsumerTheme.accent,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_uploadingPic) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ConsumerTheme.background,
                        border: Border.all(color: ConsumerTheme.border),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ConsumerTheme.muted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Uploading…',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: ConsumerTheme.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.displayName.isEmpty ? 'User' : c.displayName,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: ConsumerTheme.primaryText,
                    letterSpacing: -0.03,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@${(c.username != null && c.username!.isNotEmpty)
                      ? c.username!
                      : c.displayName.replaceAll(' ', '_').toLowerCase()}',
                  style: TextStyle(
                    fontSize: 14,
                    color: ConsumerTheme.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (c.bio != null && c.bio!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    '"${c.bio}"',
                    style: TextStyle(
                      fontSize: 14,
                      color: ConsumerTheme.bodyText,
                      height: 1.65,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
            decoration: BoxDecoration(
              color: ConsumerTheme.background.withValues(alpha: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PROFILE DETAILS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: ConsumerTheme.muted,
                    letterSpacing: 0.12,
                  ),
                ),
                const SizedBox(height: 12),
                if (c.phoneNumber != null && c.phoneNumber!.isNotEmpty ||
                    c.dob != null && c.dob!.isNotEmpty ||
                    c.gender != null && c.gender!.isNotEmpty ||
                    c.country != null && c.country!.isNotEmpty) ...[
                  if (c.phoneNumber != null && c.phoneNumber!.isNotEmpty)
                    _detailRow(Icons.phone_outlined, 'Phone', c.phoneNumber!),
                  if (c.country != null && c.country!.isNotEmpty)
                    _detailRow(Icons.location_on_outlined, 'Country', c.country!),
                  if (c.gender != null && c.gender!.isNotEmpty)
                    _detailRow(Icons.person_outline_rounded, 'Gender', c.gender!),
                  if (c.dob != null && c.dob!.isNotEmpty)
                    _detailRow(Icons.calendar_today_outlined, 'Date of birth', c.dob!),
                ] else
                  Text(
                    'Phone, location, and other details can be added when profile editing is available.',
                    style: TextStyle(
                      fontSize: 13,
                      color: ConsumerTheme.muted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.dark_mode_outlined, size: 20, color: ConsumerTheme.muted),
                        const SizedBox(width: 10),
                        Text(
                          'Dark theme',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: ConsumerTheme.primaryText,
                          ),
                        ),
                      ],
                    ),
                    Switch.adaptive(
                      value: ref.watch(themeModeProvider) == ThemeMode.dark,
                      onChanged: (_) => ref.read(themeModeProvider.notifier).toggleTheme(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowMyReviewsButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const ConsumerMyReviewsScreen(),
            ),
          );
        },
        icon: const Icon(Icons.rate_review_rounded, size: 22),
        label: const Text('Show my reviews'),
        style: FilledButton.styleFrom(
          backgroundColor: ConsumerTheme.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: ConsumerTheme.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: ConsumerTheme.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ConsumerTheme.primaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
