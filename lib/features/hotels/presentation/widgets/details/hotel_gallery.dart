import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/responsive/breakpoints.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_network_image.dart';

/// The property photo grid.
///
/// Wide viewports get a hero plus a four-up grid; narrow ones get a swipeable
/// pager with a counter. Both open the same full-screen viewer, so there is
/// one place that knows how browsing photos works.
class HotelGallery extends StatelessWidget {
  const HotelGallery({
    required this.imageUrls,
    required this.hotelName,
    super.key,
  });

  final List<String> imageUrls;
  final String hotelName;

  void _openViewer(BuildContext context, int initialIndex) {
    if (imageUrls.isEmpty) return;
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, _, _) => _GalleryViewer(
          imageUrls: imageUrls,
          hotelName: hotelName,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: const AppNetworkImage(url: null, height: 280),
      );
    }

    if (context.formFactor.isCompact) {
      return _PagedGallery(
        imageUrls: imageUrls,
        hotelName: hotelName,
        onOpen: (index) => _openViewer(context, index),
      );
    }

    return _GridGallery(
      imageUrls: imageUrls,
      hotelName: hotelName,
      onOpen: (index) => _openViewer(context, index),
    );
  }
}

class _GridGallery extends StatelessWidget {
  const _GridGallery({
    required this.imageUrls,
    required this.hotelName,
    required this.onOpen,
  });

  final List<String> imageUrls;
  final String hotelName;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    final secondary = imageUrls.skip(1).take(4).toList(growable: false);
    final hiddenCount = imageUrls.length - 1 - secondary.length;

    return SizedBox(
      height: 360,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: _GalleryTile(
              url: imageUrls.first,
              label: '$hotelName, main photo',
              onTap: () => onOpen(0),
              radius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                bottomLeft: Radius.circular(AppRadius.lg),
              ),
            ),
          ),
          if (secondary.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              flex: 2,
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.xs,
                crossAxisSpacing: AppSpacing.xs,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (var index = 0; index < secondary.length; index++)
                    _GalleryTile(
                      url: secondary[index],
                      label: '$hotelName, photo ${index + 2}',
                      onTap: () => onOpen(index + 1),
                      // Only the last tile carries the remaining-count badge.
                      overlayCount: index == secondary.length - 1 &&
                              hiddenCount > 0
                          ? hiddenCount
                          : null,
                      radius: _cornerFor(index, secondary.length),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Rounds only the outer corners of the grid so the block reads as one shape.
  BorderRadius _cornerFor(int index, int count) {
    const radius = Radius.circular(AppRadius.lg);
    return BorderRadius.only(
      topRight: index == 1 ? radius : Radius.zero,
      bottomRight: index == 3 || (count < 4 && index == count - 1)
          ? radius
          : Radius.zero,
    );
  }
}

class _PagedGallery extends StatefulWidget {
  const _PagedGallery({
    required this.imageUrls,
    required this.hotelName,
    required this.onOpen,
  });

  final List<String> imageUrls;
  final String hotelName;
  final ValueChanged<int> onOpen;

  @override
  State<_PagedGallery> createState() => _PagedGalleryState();
}

class _PagedGalleryState extends State<_PagedGallery> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: SizedBox(
        height: 240,
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (_, index) => GestureDetector(
                onTap: () => widget.onOpen(index),
                child: AppNetworkImage(
                  url: widget.imageUrls[index],
                  semanticLabel: '${widget.hotelName}, photo ${index + 1}',
                ),
              ),
            ),
            Positioned(
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: _CountBadge(
                label: '${_index + 1} / ${widget.imageUrls.length}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    required this.url,
    required this.label,
    required this.onTap,
    this.overlayCount,
    this.radius = BorderRadius.zero,
  });

  final String url;
  final String label;
  final VoidCallback onTap;
  final int? overlayCount;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppNetworkImage(url: url, semanticLabel: label),
          if (overlayCount != null)
            ColoredBox(
              color: AppColors.overlay,
              child: Center(
                child: Text(
                  '+$overlayCount photos',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ),
          Material(
            color: Colors.transparent,
            child: InkWell(onTap: onTap),
          ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.overlay,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: Colors.white),
      ),
    );
  }
}

/// Full-screen photo browser, reachable from either gallery arrangement.
class _GalleryViewer extends StatefulWidget {
  const _GalleryViewer({
    required this.imageUrls,
    required this.hotelName,
    required this.initialIndex,
  });

  final List<String> imageUrls;
  final String hotelName;
  final int initialIndex;

  @override
  State<_GalleryViewer> createState() => _GalleryViewerState();
}

class _GalleryViewerState extends State<_GalleryViewer> {
  late final PageController _controller =
      PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _step(int delta) {
    final next = _index + delta;
    if (next < 0 || next >= widget.imageUrls.length) return;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = context.formFactor.isCompact;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _step(-1),
          const SingleActivator(LogicalKeyboardKey.arrowRight): () => _step(1),
        },
        child: Focus(
          autofocus: true,
          child: Stack(
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: widget.imageUrls.length,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (_, index) => InteractiveViewer(
                  maxScale: 4,
                  child: Center(
                    child: AppNetworkImage(
                      url: widget.imageUrls[index],
                      fit: BoxFit.contain,
                      semanticLabel:
                          '${widget.hotelName}, photo ${index + 1}',
                    ),
                  ),
                ),
              ),
              Positioned(
                top: AppSpacing.lg + MediaQuery.paddingOf(context).top,
                right: AppSpacing.lg,
                child: IconButton.filled(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close photos',
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              if (!isCompact) ...[
                _ViewerArrow(
                  alignment: Alignment.centerLeft,
                  icon: Icons.chevron_left_rounded,
                  tooltip: 'Previous photo',
                  onPressed: _index > 0 ? () => _step(-1) : null,
                ),
                _ViewerArrow(
                  alignment: Alignment.centerRight,
                  icon: Icons.chevron_right_rounded,
                  tooltip: 'Next photo',
                  onPressed: _index < widget.imageUrls.length - 1
                      ? () => _step(1)
                      : null,
                ),
              ],
              Positioned(
                bottom: AppSpacing.xxl + MediaQuery.paddingOf(context).bottom,
                left: 0,
                right: 0,
                child: Center(
                  child: _CountBadge(
                    label: '${_index + 1} of ${widget.imageUrls.length}',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewerArrow extends StatelessWidget {
  const _ViewerArrow({
    required this.alignment,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final Alignment alignment;
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: IconButton.filled(
          onPressed: onPressed,
          tooltip: tooltip,
          iconSize: 28,
          icon: Icon(icon),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white24,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.white10,
            padding: const EdgeInsets.all(AppSpacing.md),
          ),
        ),
      ),
    );
  }
}
