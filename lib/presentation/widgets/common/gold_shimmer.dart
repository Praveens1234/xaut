import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_theme.dart';

class GoldShimmer extends StatelessWidget {
  const GoldShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.darkCard,
      highlightColor: AppTheme.darkCardElevated,
      period: const Duration(milliseconds: 1200),
      child: Column(
        children: <Widget>[
          const _ShimmerBox(height: 180, radius: 20),
          const SizedBox(height: 12),
          Row(
            children: const <Widget>[
              Expanded(child: _ShimmerBox(height: 72, radius: 14)),
              SizedBox(width: 8),
              _ShimmerBox(width: 68, height: 72, radius: 14),
              SizedBox(width: 8),
              Expanded(child: _ShimmerBox(height: 72, radius: 14)),
            ],
          ),
          const SizedBox(height: 12),
          const _ShimmerBox(height: 60, radius: 14),
          const SizedBox(height: 16),
          const _ShimmerBox(height: 180, radius: 16),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;

  const _ShimmerBox({
    required this.height,
    this.width,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
