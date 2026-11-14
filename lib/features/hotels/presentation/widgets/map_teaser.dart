import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// The "show on map" card that sits above the filter rail.
///
/// The map itself is out of scope for this screen, so the card is drawn from
/// a gradient and a grid rather than pretending to load a tile server — it
/// reads as a deliberate entry point instead of a failed map.
class MapTeaser extends StatelessWidget {
  const MapTeaser({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Stack(
        children: [
          Container(
            height: 150,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFDCE8D6), Color(0xFFCADDEC)],
              ),
            ),
            child: CustomPaint(
              painter: _MapLinesPainter(),
              child: const SizedBox.expand(),
            ),
          ),
          Positioned.fill(
            child: Container(color: AppColors.overlay),
          ),
          Positioned.fill(
            child: Center(
              child: FilledButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.map_rounded, size: 18),
                label: const Text('Show on map'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  foregroundColor: AppColors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws a sparse street-like grid so the card reads as a map placeholder.
class _MapLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final lane = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(0, size.height * 0.68),
      Offset(size.width, size.height * 0.42),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.28, 0),
      Offset(size.width * 0.44, size.height),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.72, 0),
      Offset(size.width * 0.62, size.height),
      lane,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.22),
      Offset(size.width, size.height * 0.16),
      lane,
    );
  }

  @override
  bool shouldRepaint(_MapLinesPainter oldDelegate) => false;
}
