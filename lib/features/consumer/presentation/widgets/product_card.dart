import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yayvo/core/utils/image_url_helper.dart';
import 'package:yayvo/features/consumer/domain/entities/product_entity.dart';
import 'package:yayvo/features/consumer/presentation/theme/consumer_theme.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.currentUserId,
    this.onLikeChanged,
    this.onSaveChanged,
    this.onTap,
    this.isLiked = false,
    this.isSaved = false,
  });

  final ProductEntity product;
  final String? currentUserId;
  final VoidCallback? onLikeChanged;
  final VoidCallback? onSaveChanged;

  /// When set, tapping the card opens product detail.
  final VoidCallback? onTap;
  final bool isLiked;
  final bool isSaved;

  String get _imageUrl => imageUrlFromPath(product.imageUrl);
  String get _retailerIconUrl => imageUrlFromPath(product.retailerIconUrl);

  @override
  Widget build(BuildContext context) {
    final surfaceColor = ConsumerTheme.surfaceOf(context);
    final borderColor = ConsumerTheme.borderOf(context);
    final primaryTextColor = ConsumerTheme.primaryTextOf(context);
    final mutedColor = ConsumerTheme.mutedOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imagePlaceholderColor = isDark
        ? const Color(0xFF3A2E24)
        : const Color(0xFFE8E4DC);

    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: _imageUrl.isEmpty
                      ? Container(
                          color: imagePlaceholderColor,
                          child: Center(
                            child: Icon(
                              Icons.inventory_2_outlined,
                              color: mutedColor,
                              size: 48,
                            ),
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: _imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: imagePlaceholderColor),
                          errorWidget: (_, __, ___) => Container(
                            color: imagePlaceholderColor,
                            child: Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: mutedColor,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title.isNotEmpty ? product.title : 'Product',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: primaryTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.retailerName != null &&
                        product.retailerName!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (_retailerIconUrl.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: CachedNetworkImage(
                                imageUrl: _retailerIconUrl,
                                width: 22,
                                height: 22,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Icon(
                                    Icons.store,
                                    size: 14,
                                    color: mutedColor,
                                  ),
                                ),
                              ),
                            ),
                          if (_retailerIconUrl.isNotEmpty)
                            const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              product.retailerName!,
                              style: TextStyle(
                                fontSize: 12,
                                color: mutedColor,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: currentUserId != null
                              ? onLikeChanged
                              : null,
                          icon: Icon(
                            Icons.favorite_rounded,
                            size: 26,
                            color: isLiked ? ConsumerTheme.error : mutedColor,
                            fill: isLiked ? 1.0 : 0,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                        ),
                        Text(
                          '${product.likes}',
                          style: TextStyle(fontSize: 12, color: mutedColor),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: currentUserId != null
                              ? onSaveChanged
                              : null,
                          icon: Icon(
                            Icons.bookmark_rounded,
                            size: 26,
                            color: isSaved ? primaryTextColor : mutedColor,
                            fill: isSaved ? 1.0 : 0,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 44,
                            minHeight: 44,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
