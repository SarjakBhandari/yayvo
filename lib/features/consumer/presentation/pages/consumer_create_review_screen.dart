import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yayvo/features/consumer/presentation/shell/consumer_shell.dart';
import 'package:yayvo/features/consumer/presentation/shell/consumer_routes.dart';
import 'package:yayvo/features/consumer/data/repositories/review_repository_impl.dart';
import 'package:yayvo/features/consumer/domain/entities/review_entity.dart';
import 'package:yayvo/features/consumer/domain/usecases/create_review.dart';
import 'package:yayvo/features/consumer/presentation/theme/consumer_theme.dart';
import 'package:yayvo/features/consumer/presentation/widgets/sentiment_picker.dart';
import 'package:yayvo/core/services/connectivity/network_info.dart';
import 'package:yayvo/core/utils/network_error_helper.dart';

final createReviewProvider = Provider<CreateReview>((ref) {
  return CreateReview(ref.read(reviewRepositoryProvider));
});

class ConsumerCreateReviewScreen extends ConsumerStatefulWidget {
  const ConsumerCreateReviewScreen({super.key});

  @override
  ConsumerState<ConsumerCreateReviewScreen> createState() =>
      _ConsumerCreateReviewScreenState();
}

class _ConsumerCreateReviewScreenState
    extends ConsumerState<ConsumerCreateReviewScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _productNameController = TextEditingController();

  List<String> _sentiments = [];
  File? _imageFile;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _productNameController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _productNameController.clear();
    setState(() {
      _sentiments = [];
      _imageFile = null;
      _error = null;
    });
  }

  Future<void> _pickImage() async {
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
    if (x != null && mounted) {
      setState(() => _imageFile = File(x.path));
    }
  }

  Future<void> _submit() async {
    final authId = ref.read(consumerAuthIdProvider);
    if (authId == null || authId.isEmpty) {
      setState(() => _error = 'Please log in to create a review.');
      return;
    }
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Title is required.');
      return;
    }

    final connected = await ref.read(networkInfoProvider).isConnected;
    if (!connected && mounted) {
      setState(() => _error = 'No internet connection');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection')),
      );
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final entity = ReviewEntity(
      id: '',
      title: title,
      description: _descriptionController.text.trim(),
      authorId: authId,
      productName: _productNameController.text.trim().isEmpty
          ? null
          : _productNameController.text.trim(),
      sentiments: _sentiments,
      likes: 0,
      likedBy: const [],
    );

    final usecase = ref.read(createReviewProvider);
    final result = await usecase.call(entity);

    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _error = normalizeNetworkErrorMessage(f.message);
        _submitting = false;
      }),
      (created) async {
        if (_imageFile != null && created.id.isNotEmpty) {
          final repo = ref.read(reviewRepositoryProvider);
          await repo.uploadReviewImage(created.id, _imageFile!);
        }
        if (!mounted) return;
        setState(() => _submitting = false);
        ref.read(currentConsumerRouteProvider.notifier).state =
            ConsumerRoute.home;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(reloadTriggerProvider, (prev, next) {
      if (prev != next && next > 0) _resetForm();
    });

    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => ref.read(currentConsumerRouteProvider.notifier).state =
                      ConsumerRoute.home,
                  icon: const Icon(Icons.arrow_back_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: ConsumerTheme.surface,
                    side: const BorderSide(color: ConsumerTheme.border),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SHARE YOUR THOUGHTS',
                      style: TextStyle(
                        fontSize: 11,
                        color: ConsumerTheme.muted,
                        letterSpacing: 0.14,
                      ),
                    ),
                    Text(
                      'Create Review',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: ConsumerTheme.primaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8F5),
                  border: Border.all(color: ConsumerTheme.errorBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: ConsumerTheme.error),
                ),
              ),
              const SizedBox(height: 20),
            ],
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Short, descriptive title…',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Write your review in detail…',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _productNameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                hintText: 'What product are you reviewing? (optional)',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'SENTIMENTS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ConsumerTheme.bodyText,
                letterSpacing: 0.08,
              ),
            ),
            const SizedBox(height: 6),
            SentimentPicker(
              selected: _sentiments,
              onChange: (v) => setState(() => _sentiments = v),
            ),
            const SizedBox(height: 20),
            Text(
              'PRODUCT IMAGE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ConsumerTheme.bodyText,
              ),
            ),
            const SizedBox(height: 6),
            if (_imageFile != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      _imageFile!,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      onPressed: () => setState(() => _imageFile = null),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            else
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                  decoration: BoxDecoration(
                    color: ConsumerTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: ConsumerTheme.border,
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.upload_rounded,
                          size: 44, color: ConsumerTheme.accent),
                      const SizedBox(height: 10),
                      Text(
                        'Drop an image here or tap to browse',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: ConsumerTheme.bodyText,
                        ),
                      ),
                      Text(
                        'PNG, JPG, WEBP up to 10 MB',
                        style: TextStyle(
                          fontSize: 12,
                          color: ConsumerTheme.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Publish Review'),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: _submitting
                      ? null
                      : () => ref.read(currentConsumerRouteProvider.notifier).state =
                          ConsumerRoute.home,
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
  }
}
