import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yayvo/core/utils/image_url_helper.dart';
import 'package:yayvo/features/consumer/domain/entities/product_entity.dart';
import 'package:yayvo/features/consumer/presentation/theme/consumer_theme.dart';

/// Dialog showing full product details (title, description, image, retailer, sentiments, likes).
class ProductDetailDialog extends StatelessWidget {
  const ProductDetailDialog({
    super.key,
    required this.product,
  });

  final ProductEntity product;

  static Future<void> show(BuildContext context, ProductEntity product) {
    return showDialog<void>(
      context: context,
      builder: (context) => ProductDetailDialog(product: product),
    );
  }

  String get _imageUrl => imageUrlFromPath(product.imageUrl);
  String get _retailerIconUrl => imageUrlFromPath(product.retailerIconUrl);

  @override
  Widget build(BuildContext context) {
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
                  Expanded(
                    child: Text(
                      product.title.isNotEmpty ? product.title : 'Product',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: ConsumerTheme.primaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: ConsumerTheme.borderLight,
                    ),
                  ),
                ],
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
                      placeholder: (_, __) => Container(color: ConsumerTheme.borderLight),
                      errorWidget: (_, __, ___) => Container(color: ConsumerTheme.borderLight),
                    ),
                  ),
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (product.retailerName != null && product.retailerName!.isNotEmpty) ...[
                      Row(
                        children: [
                          if (_retailerIconUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: _retailerIconUrl,
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => const Icon(Icons.store, size: 24),
                              ),
                            ),
                          if (_retailerIconUrl.isNotEmpty) const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              product.retailerName!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ConsumerTheme.bodyText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (product.description != null && product.description!.isNotEmpty)
                      Text(
                        product.description!,
                        style: TextStyle(
                          fontSize: 15,
                          color: ConsumerTheme.bodyText,
                          height: 1.5,
                        ),
                      ),
                    if (product.targetSentiment.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.targetSentiment
                            .map((s) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
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
                                ))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      '${product.likes} ${product.likes == 1 ? 'like' : 'likes'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: ConsumerTheme.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
