import 'package:crypto_mobile/constants/colors.dart';
import 'package:flutter/material.dart';



class SkeletonShimmer extends StatefulWidget {
  final Widget child;

  const SkeletonShimmer({super.key, required this.child});

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
    _anim = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.centerRight,
            stops: const [0.0, 0.5, 1.0],
            transform: _SweepTransform(_anim.value),
            colors: const [
              AppColors.skeletonBase,
              AppColors.skeletonHighlight,
              AppColors.skeletonBase,
            ],
          ).createShader(bounds),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SweepTransform extends GradientTransform {
  final double offset;

  const _SweepTransform(this.offset);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * offset * 0.5, 0, 0);
  }
}


class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });

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

class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.skeletonBase,
        shape: BoxShape.circle,
      ),
    );
  }
}


class SkeletonCoinCardList extends StatelessWidget {
  final int cardCount;

  const SkeletonCoinCardList({super.key, this.cardCount = 6});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        children: List.generate(
          cardCount,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _SkeletonCoinCard(),
          ),
        ),
      ),
    );
  }
}

class _SkeletonCoinCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowPrimary,
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SkeletonBox(width: 4, height: double.infinity, radius: 0),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SkeletonCircle(size: 44),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                SkeletonBox(width: 110, height: 13),
                                SizedBox(height: 6),
                                SkeletonBox(width: 60, height: 10),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const SkeletonBox(width: 38, height: 24, radius: 8),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                SkeletonBox(width: 130, height: 20),
                                SizedBox(height: 6),
                                SkeletonBox(width: 85, height: 11),
                              ],
                            ),
                          ),
                          const SkeletonBox(width: 68, height: 30, radius: 10),
                        ],
                      ),

                      const SizedBox(height: 12),

                      const SkeletonBox(
                          width: double.infinity, height: 1, radius: 0),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                              child: SkeletonBox(height: 34, radius: 6)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: SkeletonBox(height: 34, radius: 6)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: SkeletonBox(height: 34, radius: 6)),
                        ],
                      ),
                    ],
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


class SkeletonCoinDetail extends StatelessWidget {
  const SkeletonCoinDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (_, i) => const SizedBox(width: 10),
                itemBuilder: (_, i) => const _SkeletonSelectorChip(),
              ),
            ),

            const SizedBox(height: 20),

            _SkeletonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SkeletonCircle(size: 48),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SkeletonBox(width: 120, height: 15),
                            SizedBox(height: 6),
                            SkeletonBox(width: 70, height: 11),
                          ],
                        ),
                      ),
                      const SkeletonBox(width: 40, height: 26, radius: 8),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const SkeletonBox(width: double.infinity, height: 1, radius: 0),
                  const SizedBox(height: 16),
                  const SkeletonBox(width: 190, height: 36),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      SkeletonBox(width: 80, height: 28, radius: 8),
                      SizedBox(width: 10),
                      SkeletonBox(width: 110, height: 14),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _SkeletonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonCardTitle(),
                  const SizedBox(height: 16),
                  const SkeletonBox(
                      width: double.infinity, height: 22, radius: 11),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      SkeletonBox(width: 60, height: 30),
                      SkeletonBox(width: 60, height: 30),
                      SkeletonBox(width: 60, height: 30),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const SkeletonBox(
                      width: double.infinity, height: 30, radius: 8),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(child: _SkeletonStatChip()),
                const SizedBox(width: 10),
                Expanded(child: _SkeletonStatChip()),
                const SizedBox(width: 10),
                Expanded(child: _SkeletonStatChip()),
              ],
            ),

            const SizedBox(height: 14),

            _SkeletonCard(
              child: Column(
                children: [
                  _SkeletonCardTitle(),
                  const SizedBox(height: 16),
                  ...List.generate(
                    3,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          SkeletonBox(width: 90, height: 13),
                          SkeletonBox(width: 100, height: 13),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SkeletonBox(
                      width: double.infinity, height: 8, radius: 4),
                ],
              ),
            ),

            const SizedBox(height: 14),

            _SkeletonCard(
              child: Column(
                children: [
                  _SkeletonCardTitle(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SkeletonBox(width: 36, height: 22, radius: 6),
                            SizedBox(height: 8),
                            SkeletonBox(width: 100, height: 20),
                            SizedBox(height: 6),
                            SkeletonBox(width: 80, height: 12),
                          ],
                        ),
                      ),
                      Container(
                          width: 1, height: 58, color: AppColors.cardBorder),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              SkeletonBox(width: 36, height: 22, radius: 6),
                              SizedBox(height: 8),
                              SkeletonBox(width: 80, height: 20),
                              SizedBox(height: 6),
                              SkeletonBox(width: 100, height: 12),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const SkeletonBox(
                      width: double.infinity, height: 22, radius: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonSelectorChip extends StatelessWidget {
  const _SkeletonSelectorChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      decoration: BoxDecoration(
        color: AppColors.skeletonBase,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final Widget child;

  const _SkeletonCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowPrimary,
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SkeletonCardTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SkeletonBox(width: 130, height: 14),
        SizedBox(height: 12),
        SkeletonBox(width: double.infinity, height: 1, radius: 0),
      ],
    );
  }
}

class _SkeletonStatChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonBox(width: double.infinity, height: 18),
          SizedBox(height: 6),
          SkeletonBox(width: 50, height: 11),
        ],
      ),
    );
  }
}
