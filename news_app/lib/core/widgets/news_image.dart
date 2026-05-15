import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class NewsImage extends StatelessWidget {
  const NewsImage({
    super.key,
    required this.post,
    this.height = 200,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  final Map<String, dynamic> post;
  final double height;
  final double? width;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final url = ApiService.resolvePostImageUrl(post);
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: height,
        width: width ?? double.infinity,
        child: url == null || url.isEmpty
            ? _fallback(context)
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (_, __) => _shimmer(context),
                errorWidget: (_, __, ___) => _fallback(context),
              ),
      ),
    );
  }

  Widget _shimmer(BuildContext context) {
    final c = Theme.of(context).colorScheme.surfaceContainerHighest;
    return ColoredBox(
      color: c,
      child: const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: scheme.outline,
        ),
      ),
    );
  }
}
