import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonContainer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const SkeletonContainer({
    Key? key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(0)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
      ),
    );
  }
}

class SkeletonText extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonText({
    Key? key,
    this.width = double.infinity,
    this.height = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      width: width,
      height: height,
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double height;

  const SkeletonCard({Key? key, this.height = 200}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      height: height,
      borderRadius: BorderRadius.circular(12),
    );
  }
}

class SkeletonAvatar extends StatelessWidget {
  final double size;

  const SkeletonAvatar({Key? key, this.size = 50}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }
}

class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SkeletonAvatar(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonText(width: 120),
                const SizedBox(height: 8),
                SkeletonText(width: MediaQuery.of(context).size.width * 0.6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerLoading extends StatelessWidget {
  final Widget child;

  const ShimmerLoading({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }
}