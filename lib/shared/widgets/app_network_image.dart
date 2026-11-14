import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A remote image with a settled placeholder and a non-alarming fallback.
///
/// Every photo in the product goes through this widget so that a slow or dead
/// URL degrades into something that still looks deliberate, rather than a
/// broken-image glyph or a layout jump.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.url,
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.semanticLabel,
  });

  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final address = url;
    if (address == null || address.isEmpty) {
      return _Fallback(width: width, height: height);
    }

    return Semantics(
      label: semanticLabel,
      image: true,
      child: CachedNetworkImage(
        imageUrl: address,
        fit: fit,
        width: width,
        height: height,
        fadeInDuration: const Duration(milliseconds: 180),
        placeholder: (_, _) => _Placeholder(width: width, height: height),
        errorWidget: (_, _, _) => _Fallback(width: width, height: height),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.skeletonBase,
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.skeletonBase,
      alignment: Alignment.center,
      child: const Icon(
        Icons.apartment_rounded,
        color: AppColors.inkSubtle,
        size: 28,
      ),
    );
  }
}
