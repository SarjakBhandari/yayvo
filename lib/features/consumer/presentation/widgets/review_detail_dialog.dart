import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yayvo/core/utils/image_url_helper.dart';
import 'package:yayvo/features/consumer/domain/entities/review_entity.dart';
import 'package:yayvo/features/consumer/presentation/theme/consumer_theme.dart';
import 'package:yayvo/features/consumer/presentation/widgets/sentiment_picker.dart';
import 'package:yayvo/features/consumer/data/repositories/review_repository_impl.dart';

/// Full-screen dialog showing review details. When [isOwner] and [isOnline], shows Edit and Delete.
class ReviewDetailDialog extends ConsumerStatefulWidget {
  const ReviewDetailDialog({
    super.key,
    required this.review,
    this.authorName,
    this.isOwner = false,
    this.isOnline = true,
    this.onDeleted,
    this.onUpdated,
  });

  final ReviewEntity review;
  final String? authorName;
  final bool isOwner;
  final bool isOnline;
  final VoidCallback? onDeleted;
  final void Function(ReviewEntity updated)? onUpdated;

  static Future<void> show(
    BuildContext context,
    ReviewEntity review, {
    String? authorName,
    bool isOwner = false,
    bool isOnline = true,
    VoidCallback? onDeleted,
    void Function(ReviewEntity updated)? onUpdated,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => ReviewDetailDialog(
        review: review,
        authorName: authorName,
        isOwner: isOwner,
        isOnline: isOnline,
        onDeleted: onDeleted,
        onUpdated: onUpdated,
      ),
    );
  }

  @override
  ConsumerState<ReviewDetailDialog> createState() => _ReviewDetailDialogState();
}

class _ReviewDetailDialogState extends ConsumerState<ReviewDetailDialog> {
  bool _editing = false;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late List<String> _sentiments;
  bool _saving = false;
  bool _deleting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.review.title);
    _descriptionController = TextEditingController(
      text: widget.review.description,
    );
    _sentiments = List.from(widget.review.sentiments);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String get _imageUrl => imageUrlFromPath(widget.review.imageUrl);

  String get _dateStr {
    if (widget.review.createdAt == null) return '';
    final d = widget.review.createdAt!;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _saveEdit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Title is required');
      return;
    }
    setState(() {
      _error = null;
      _saving = true;
    });
    final repo = ref.read(reviewRepositoryProvider);
    final updated = widget.review.copyWith(
      title: title,
      description: _descriptionController.text.trim(),
      sentiments: _sentiments,
    );
    final result = await repo.updateReview(widget.review.id, updated);
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _error = f.message;
        _saving = false;
      }),
      (_) {
        setState(() => _saving = false);
        widget.onUpdated?.call(updated);
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        messenger.showSnackBar(const SnackBar(content: Text('Review updated')));
      },
    );
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete review?'),
        content: const Text(
          'This review will be permanently deleted. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: ConsumerTheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _deleting = true);
    final repo = ref.read(reviewRepositoryProvider);
    final result = await repo.deleteReview(widget.review.id);
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _error = f.message;
        _deleting = false;
      }),
      (_) {
        widget.onDeleted?.call();
        // Capture messenger before pop since mounted=false after pop
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        messenger.showSnackBar(const SnackBar(content: Text('Review deleted')));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final showActions = widget.isOwner && widget.isOnline && !_editing;

    return Dialog(
      backgroundColor: ConsumerTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  if (widget.authorName != null &&
                      widget.authorName!.isNotEmpty)
                    Expanded(
                      child: Text(
                        widget.authorName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: ConsumerTheme.primaryText,
                        ),
                      ),
                    ),
                  if (review.createdAt != null && !_editing)
                    Text(
                      _dateStr,
                      style: TextStyle(
                        fontSize: 12,
                        color: ConsumerTheme.muted,
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _deleting || _saving
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: ConsumerTheme.borderLight,
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _error!,
                  style: const TextStyle(
                    color: ConsumerTheme.error,
                    fontSize: 13,
                  ),
                ),
              ),
            if (_editing) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  'Edit Review',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ConsumerTheme.primaryText,
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sentiments',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ConsumerTheme.muted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SentimentPicker(
                        selected: _sentiments,
                        onChange: (v) => setState(() => _sentiments = v),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: _saving
                                ? null
                                : () => setState(() => _editing = false),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: _saving ? null : _saveEdit,
                            child: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              if (review.title.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    review.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: ConsumerTheme.primaryText,
                    ),
                  ),
                ),
              if (_imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: CachedNetworkImage(
                        imageUrl: _imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: ConsumerTheme.borderLight),
                        errorWidget: (_, __, ___) =>
                            Container(color: ConsumerTheme.borderLight),
                      ),
                    ),
                  ),
                ),
              if (review.productName != null &&
                  review.productName!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Product: ${review.productName}',
                    style: TextStyle(
                      fontSize: 13,
                      color: ConsumerTheme.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (review.description.isNotEmpty)
                        Text(
                          review.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: ConsumerTheme.bodyText,
                            height: 1.5,
                          ),
                        ),
                      if (review.sentiments.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: review.sentiments
                              .map(
                                (s) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ConsumerTheme.borderLight,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '#$s',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: ConsumerTheme.bodyText,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        '${review.likes} ${review.likes == 1 ? 'like' : 'likes'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: ConsumerTheme.muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (showActions) ...[
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _deleting
                                  ? null
                                  : () => setState(() => _editing = true),
                              icon: const Icon(Icons.edit_rounded, size: 18),
                              label: const Text('Edit'),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: _deleting ? null : _confirmDelete,
                              style: FilledButton.styleFrom(
                                backgroundColor: ConsumerTheme.error,
                              ),
                              icon: _deleting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                    ),
                              label: Text(_deleting ? 'Deleting…' : 'Delete'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
