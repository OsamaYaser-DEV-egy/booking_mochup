import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Placeholder shown while the first page of results loads.
///
/// It mirrors the real card's proportions so the list does not jump when the
/// data arrives.
class HotelCardSkeleton extends StatelessWidget {
  const HotelCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isStacked = context.formFactor.isCompact;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Shimmer.fromColors(
          baseColor: AppColors.skeletonBase,
          highlightColor: AppColors.skeletonHighlight,
          child: isStacked ? const _StackedSkeleton() : const _RowSkeleton(),
        ),
      ),
    );
  }
}

class _RowSkeleton extends StatelessWidget {
  const _RowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Block(width: 232, height: 212, radius: AppRadius.md),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Block(width: 260, height: 20),
              SizedBox(height: AppSpacing.sm),
              _Block(width: 180, height: 14),
              SizedBox(height: AppSpacing.lg),
              _Block(width: double.infinity, height: 12),
              SizedBox(height: AppSpacing.sm),
              _Block(width: 220, height: 12),
              SizedBox(height: AppSpacing.lg),
              _Block(width: 150, height: 16),
              SizedBox(height: AppSpacing.sm),
              _Block(width: 200, height: 12),
            ],
          ),
        ),
        SizedBox(width: AppSpacing.lg),
        SizedBox(
          width: 196,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _Block(width: 120, height: 36),
              SizedBox(height: AppSpacing.huge),
              _Block(width: 90, height: 12),
              SizedBox(height: AppSpacing.sm),
              _Block(width: 130, height: 24),
              SizedBox(height: AppSpacing.md),
              _Block(width: double.infinity, height: 44, radius: AppRadius.md),
            ],
          ),
        ),
      ],
    );
  }
}

class _StackedSkeleton extends StatelessWidget {
  const _StackedSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Block(width: double.infinity, height: 180, radius: AppRadius.md),
        SizedBox(height: AppSpacing.md),
        _Block(width: 220, height: 20),
        SizedBox(height: AppSpacing.sm),
        _Block(width: 160, height: 12),
        SizedBox(height: AppSpacing.lg),
        _Block(width: double.infinity, height: 12),
        SizedBox(height: AppSpacing.sm),
        _Block(width: 180, height: 12),
        SizedBox(height: AppSpacing.lg),
        _Block(width: 140, height: 24),
        SizedBox(height: AppSpacing.md),
        _Block(width: double.infinity, height: 44, radius: AppRadius.md),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.width,
    required this.height,
    this.radius = AppRadius.xs,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.skeletonBase,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
