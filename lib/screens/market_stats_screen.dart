import 'dart:math' as math;

import 'package:crypto_mobile/bloc/market_stats_bloc.dart';
import 'package:crypto_mobile/bloc/market_stats_event.dart';
import 'package:crypto_mobile/bloc/market_stats_state.dart';
import 'package:crypto_mobile/constants/colors.dart';
import 'package:crypto_mobile/constants/font.dart';
import 'package:crypto_mobile/core/enum.dart';
import 'package:crypto_mobile/model/market_stats.dart';
import 'package:crypto_mobile/widgets/skeleton_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─── Format helpers ───────────────────────────────────────────────────────────

String _fmtLarge(double v) {
  if (v >= 1e12) return '\$${(v / 1e12).toStringAsFixed(2)}T';
  if (v >= 1e9) return '\$${(v / 1e9).toStringAsFixed(2)}B';
  if (v >= 1e6) return '\$${(v / 1e6).toStringAsFixed(2)}M';
  return '\$${v.toStringAsFixed(0)}';
}

String _fmtCount(int v) {
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return v.toString();
}

// ═══════════════════════════════════════════════════════════════════════════
//  MARKET STATS SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class MarketStatsScreen extends StatelessWidget {
  const MarketStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ────────────────────────────────────────────────
            _StatsAppBar(
              onRefresh: () =>
                  context.read<MarketStatsBloc>().add(MarketStatsRequested()),
            ),

            // ── Content ────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<MarketStatsBloc, MarketStatsState>(
                builder: (context, state) {
                  if (state.status == Status.loading) {
                    return const SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      child: _SkeletonBody(),
                    );
                  }

                  if (state.status == Status.error) {
                    return _ErrorView(
                      message: state.error,
                      onRetry: () => context.read<MarketStatsBloc>().add(
                        MarketStatsRequested(),
                      ),
                    );
                  }

                  final stats = state.data!;
                  return _StatsBody(stats: stats);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsAppBar extends StatelessWidget {
  final VoidCallback onRefresh;

  const _StatsAppBar({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 12, 8),
      child: Row(
        children: [
          const Expanded(
            child: Text('Market Statistics', style: AppFonts.screenTitle),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  STATS BODY — responsive layout
// ═══════════════════════════════════════════════════════════════════════════

class _StatsBody extends StatelessWidget {
  final MarketStats stats;

  const _StatsBody({required this.stats});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;

    return RefreshIndicator(
      color: AppColors.primaryColor,
      backgroundColor: AppColors.cardBackground,
      onRefresh: () async =>
          context.read<MarketStatsBloc>().add(MarketStatsRequested()),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          isTablet ? 24 : 16,
          8,
          isTablet ? 24 : 16,
          36,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero banner (total market cap + change) ───────────────
            _HeroBanner(stats: stats),

            const SizedBox(height: 18),

            // ── Stats grid (2-col on phone, 3-col on tablet) ──────────
            if (isTablet)
              _StatsGridTablet(stats: stats)
            else
              _StatsGridPhone(stats: stats),

            const SizedBox(height: 18),

            // ── BTC Dominance card ─────────────────────────────────────
            _BtcDominanceCard(dominance: stats.btcDominance),

            const SizedBox(height: 18),

            // ── Market health bar ──────────────────────────────────────
            _MarketHealthCard(stats: stats),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  HERO BANNER
// ═══════════════════════════════════════════════════════════════════════════

class _HeroBanner extends StatelessWidget {
  final MarketStats stats;

  const _HeroBanner({required this.stats});

  @override
  Widget build(BuildContext context) {
    final isGain = stats.marketCapChange24h >= 0;
    final sign = isGain ? '+' : '';
    final changeLbl = '$sign${stats.marketCapChange24h.toStringAsFixed(2)}%';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.selectorShadow,
            blurRadius: 28,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(
            children: [
              const Icon(
                Icons.public_rounded,
                color: AppColors.primaryOnColor,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'TOTAL MARKET CAP',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryOnColor.withValues(alpha: 0.75),
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Value
          Text(
            _fmtLarge(stats.totalMarketCap),
            style: const TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryOnColor,
              letterSpacing: -1.2,
              height: 1.0,
            ),
          ),

          const SizedBox(height: 12),

          // 24h change badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryOnColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isGain
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: AppColors.primaryOnColor,
                  size: 15,
                ),
                const SizedBox(width: 5),
                Text(
                  '$changeLbl 24h change',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryOnColor,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  STATS GRID — phone (2-col)
// ═══════════════════════════════════════════════════════════════════════════

class _StatsGridPhone extends StatelessWidget {
  final MarketStats stats;

  const _StatsGridPhone({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.bar_chart_rounded,
                iconColor: AppColors.primaryColor,
                iconBg: AppColors.primaryLight,
                label: 'Total Volume 24H',
                value: _fmtLarge(stats.totalVolume),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.currency_bitcoin_rounded,
                iconColor: AppColors.btcIcon,
                iconBg: AppColors.btcIconBg,
                label: 'BTC Dominance',
                value: '${stats.btcDominance.toStringAsFixed(1)}%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.diamond_rounded,
                iconColor: AppColors.ethIcon,
                iconBg: AppColors.ethIconBg,
                label: 'Active Cryptos',
                value: _fmtCount(stats.activeCryptocurrencies),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.trending_up_rounded,
                iconColor: stats.marketCapChange24h >= 0
                    ? AppColors.gainText
                    : AppColors.lossText,
                iconBg: stats.marketCapChange24h >= 0
                    ? AppColors.gainLight
                    : AppColors.lossLight,
                label: 'Market Cap Change',
                value:
                    '${stats.marketCapChange24h >= 0 ? '+' : ''}${stats.marketCapChange24h.toStringAsFixed(2)}%',
                isChange: true,
                isGain: stats.marketCapChange24h >= 0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  STATS GRID — tablet (3-col horizontal + 1 full-width)
// ═══════════════════════════════════════════════════════════════════════════

class _StatsGridTablet extends StatelessWidget {
  final MarketStats stats;

  const _StatsGridTablet({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.bar_chart_rounded,
                iconColor: AppColors.primaryColor,
                iconBg: AppColors.primaryLight,
                label: 'Total Volume 24H',
                value: _fmtLarge(stats.totalVolume),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.currency_bitcoin_rounded,
                iconColor: AppColors.btcIcon,
                iconBg: AppColors.btcIconBg,
                label: 'BTC Dominance',
                value: '${stats.btcDominance.toStringAsFixed(1)}%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.diamond_rounded,
                iconColor: AppColors.ethIcon,
                iconBg: AppColors.ethIconBg,
                label: 'Active Cryptos',
                value: _fmtCount(stats.activeCryptocurrencies),
                subValue: '${stats.activeCryptocurrencies} coins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _StatCard(
          icon: Icons.trending_up_rounded,
          iconColor: stats.marketCapChange24h >= 0
              ? AppColors.gainText
              : AppColors.lossText,
          iconBg: stats.marketCapChange24h >= 0
              ? AppColors.gainLight
              : AppColors.lossLight,
          label: 'Market Cap Change (24H)',
          value:
              '${stats.marketCapChange24h >= 0 ? '+' : ''}${stats.marketCapChange24h.toStringAsFixed(2)}%',
          isChange: true,
          isGain: stats.marketCapChange24h >= 0,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  INDIVIDUAL STAT CARD
// ═══════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final String? subValue;
  final bool isChange;
  final bool isGain;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    this.subValue,
    this.isChange = false,
    this.isGain = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 14),

          // Value
          Text(
            value,
            style: isChange
                ? TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: isGain ? AppColors.gainText : AppColors.lossText,
                    letterSpacing: -0.5,
                    height: 1.1,
                  )
                : AppFonts.detailStatValue.copyWith(fontSize: 22),
          ),

          const SizedBox(height: 5),

          // Label
          Text(label, style: AppFonts.detailStatLabel),

          if (subValue != null) ...[
            const SizedBox(height: 3),
            Text(
              subValue!,
              style: AppFonts.detailStatLabel.copyWith(
                fontSize: 10,
                color: AppColors.textMuted.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BtcDominanceCard extends StatelessWidget {
  final double dominance;

  const _BtcDominanceCard({required this.dominance});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 700;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowPrimary,
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: isTablet
          ? Row(
              children: [
                _DominanceDonut(dominance: dominance),
                const SizedBox(width: 28),
                Expanded(child: _DominanceLegend(dominance: dominance)),
              ],
            )
          : Column(
              children: [
                _DominanceDonut(dominance: dominance),
                const SizedBox(height: 20),
                _DominanceLegend(dominance: dominance),
              ],
            ),
    );
  }
}

class _DominanceDonut extends StatelessWidget {
  final double dominance;

  const _DominanceDonut({required this.dominance});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: CustomPaint(
        painter: _DonutPainter(pct: dominance / 100),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.currency_bitcoin_rounded,
                color: AppColors.btcIcon,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                '${dominance.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double pct;

  const _DonutPainter({required this.pct});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 10;
    const sw = 18.0;
    const start = -math.pi / 2;

    // Track
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = AppColors.statLabelBg
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );

    // BTC fill (teal)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      start,
      2 * math.pi * pct,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: start,
          endAngle: start + 2 * math.pi * pct,
          colors: const [AppColors.primaryLight, AppColors.primaryColor],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw
        ..strokeCap = StrokeCap.round,
    );

    // Others fill (BTC orange)
    final othersStart = start + 2 * math.pi * pct + 0.04;
    final othersEnd = 2 * math.pi * (1 - pct) - 0.04;
    if (othersEnd > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        othersStart,
        othersEnd,
        false,
        Paint()
          ..color = AppColors.btcIconBg
          ..style = PaintingStyle.stroke
          ..strokeWidth = sw
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.pct != pct;
}

class _DominanceLegend extends StatelessWidget {
  final double dominance;

  const _DominanceLegend({required this.dominance});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('BTC Dominance', style: AppFonts.detailCardTitle),
        const SizedBox(height: 4),
        Text(
          'Bitcoin\'s share of total crypto market cap',
          style: AppFonts.detailStatLabel,
        ),
        const SizedBox(height: 20),

        // BTC row
        _LegendRow(
          color: AppColors.primaryColor,
          label: 'Bitcoin (BTC)',
          pct: dominance,
        ),
        const SizedBox(height: 10),

        // Others row
        _LegendRow(
          color: AppColors.btcIconBorder,
          label: 'Others',
          pct: 100 - dominance,
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final double pct;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.pct,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: AppFonts.detailStatLabel)),
        Text('${pct.toStringAsFixed(1)}%', style: AppFonts.rangeBarValue),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  MARKET HEALTH BAR  (volume / market cap ratio)
// ═══════════════════════════════════════════════════════════════════════════

class _MarketHealthCard extends StatelessWidget {
  final MarketStats stats;

  const _MarketHealthCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final ratio = stats.totalVolume / stats.totalMarketCap;
    final pct = (ratio * 100).clamp(0.0, 100.0);

    final isHealthy = ratio >= 0.05;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowPrimary,
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Icon(
                Icons.favorite_rounded,
                size: 15,
                color: isHealthy ? AppColors.gainText : AppColors.neutralText,
              ),
              const SizedBox(width: 7),
              Text('Market Activity', style: AppFonts.detailCardTitle),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isHealthy
                      ? AppColors.gainLight
                      : AppColors.neutralLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isHealthy ? 'Active' : 'Slow',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isHealthy
                        ? AppColors.gainText
                        : AppColors.neutralText,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          const Divider(height: 1, thickness: 1, color: AppColors.cardBorder),
          const SizedBox(height: 16),

          // Stat rows
          _InfoRow(label: 'Total Volume', value: _fmtLarge(stats.totalVolume)),
          const SizedBox(height: 8),
          _InfoRow(label: 'Market Cap', value: _fmtLarge(stats.totalMarketCap)),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Volume / Market Cap Ratio',
            value: '${pct.toStringAsFixed(2)}%',
            highlight: true,
          ),

          const SizedBox(height: 16),

          // Activity bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(height: 10, color: AppColors.statLabelBg),
                FractionallySizedBox(
                  widthFactor: (ratio * 10).clamp(0.0, 1.0),
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isHealthy
                            ? const [
                                AppColors.primaryLight,
                                AppColors.primaryColor,
                              ]
                            : [AppColors.neutralLight, AppColors.neutralAccent],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Text(
            'Volume/Market Cap ratio indicates daily trading activity. '
            'Above 5% signals a highly active market.',
            style: AppFonts.lastUpdatedText,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _InfoRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppFonts.detailStatLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: highlight
                ? AppFonts.rangeBarValueHighlight
                : AppFonts.detailRowValue,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  SKELETON BODY
// ═══════════════════════════════════════════════════════════════════════════

class _SkeletonBody extends StatelessWidget {
  const _SkeletonBody();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final p = width >= 600 ? 24.0 : 16.0;

    return SkeletonShimmer(
      child: Padding(
        padding: EdgeInsets.fromLTRB(p, 8, p, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero banner skeleton
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.skeletonBase,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 18),
            // 2-col stat cards
            Row(
              children: [
                Expanded(child: _SkeletonStatCard()),
                const SizedBox(width: 12),
                Expanded(child: _SkeletonStatCard()),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _SkeletonStatCard()),
                const SizedBox(width: 12),
                Expanded(child: _SkeletonStatCard()),
              ],
            ),
            const SizedBox(height: 18),
            // Donut card skeleton
            _SkeletonCard(height: 200),
            const SizedBox(height: 18),
            // Health bar skeleton
            _SkeletonCard(height: 180),
          ],
        ),
      ),
    );
  }
}

class _SkeletonStatCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ClipRect(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            SkeletonBox(width: 40, height: 40, radius: 12),
            SizedBox(height: 12),
            SkeletonBox(width: 80, height: 20),
            SizedBox(height: 6),
            SkeletonBox(width: 100, height: 11),
          ],
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double height;

  const _SkeletonCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SkeletonBox(width: 140, height: 14),
            SizedBox(height: 12),
            SkeletonBox(width: double.infinity, height: 1, radius: 0),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  ERROR VIEW
// ═══════════════════════════════════════════════════════════════════════════

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.lossLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.lossText,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Unable to load market data',
              style: AppFonts.detailCardTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppFonts.detailStatLabel,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
                color: AppColors.primaryColor,
              ),
              label: const Text(
                'Try Again',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryLight,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
