import 'dart:math' as math;

import 'package:crypto_mobile/bloc/watchlist_bloc.dart';
import 'package:crypto_mobile/bloc/watchlist_event.dart';
import 'package:crypto_mobile/bloc/watchlist_state.dart';
import 'package:crypto_mobile/constants/colors.dart';
import 'package:crypto_mobile/constants/font.dart';
import 'package:crypto_mobile/core/enum.dart';
import 'package:crypto_mobile/model/watchlist_item.dart';
import 'package:crypto_mobile/widgets/skeleton_loader.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

String _fmtPrice(double v) {
  if (v >= 1000) {
    final s = v.toStringAsFixed(2);
    final parts = s.split('.');
    final buf = StringBuffer();
    final digits = parts[0];
    for (int i = 0; i < digits.length; i++) {
      final pos = digits.length - i;
      buf.write(digits[i]);
      if (pos > 1 && pos % 3 == 1 && i != digits.length - 1) buf.write(',');
    }
    return '\$$buf.${parts[1]}';
  }
  if (v >= 1) return '\$${v.toStringAsFixed(2)}';
  return '\$${v.toStringAsFixed(4)}';
}

List<double> _simulatePriceHistory(WatchlistItem item) {
  const points = 14;
  final seed = item.id.codeUnits.fold(0, (a, b) => a + b);
  final rng = math.Random(seed);

  final endPrice = item.currentPrice;
  final pct = item.priceChangePercentage24h / 100;
  final startPrice = endPrice / (1 + pct);

  final prices = <double>[];
  for (int i = 0; i < points; i++) {
    final t = i / (points - 1);
    final trend = startPrice + (endPrice - startPrice) * t;
    final noise = (rng.nextDouble() - 0.5) * endPrice * 0.015;
    prices.add((trend + noise).clamp(endPrice * 0.8, endPrice * 1.2));
  }
  prices[prices.length - 1] = endPrice;
  return prices;
}

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            _WatchlistAppBar(
              onRefresh: () =>
                  context.read<WatchlistBloc>().add(WatchlistRequested()),
            ),
            Expanded(
              child: BlocBuilder<WatchlistBloc, WatchlistState>(
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
                      onRetry: () => context.read<WatchlistBloc>().add(
                        WatchlistRequested(),
                      ),
                    );
                  }
                  if (state.items.isEmpty) {
                    return const _EmptyView();
                  }
                  return _WatchlistBody(items: state.items);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WatchlistAppBar extends StatelessWidget {
  final VoidCallback onRefresh;

  const _WatchlistAppBar({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 12, 8),
      child: Row(
        children: [
          const Expanded(child: Text('Watchlist', style: AppFonts.screenTitle)),
        
        ],
      ),
    );
  }
}

class _WatchlistBody extends StatelessWidget {
  final List<WatchlistItem> items;

  const _WatchlistBody({required this.items});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;
    final hPad = isTablet ? 24.0 : 16.0;

    final totalValue = items.fold(0.0, (s, i) => s + i.currentPrice);
    final avgChange = items.isEmpty
        ? 0.0
        : items.fold(0.0, (s, i) => s + i.priceChangePercentage24h) /
              items.length;

    return RefreshIndicator(
      color: AppColors.primaryColor,
      backgroundColor: AppColors.cardBackground,
      onRefresh: () async =>
          context.read<WatchlistBloc>().add(WatchlistRequested()),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PortfolioSummary(
              itemCount: items.length,
              totalValue: totalValue,
              avgChange: avgChange,
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${items.length} coins tracked',
                  style: AppFonts.detailCardTitle,
                ),
                
              ],
            ),

            const SizedBox(height: 12),

            if (isTablet)
              _TabletGrid(items: items)
            else
              _PhoneList(items: items),
          ],
        ),
      ),
    );
  }
}

class _PhoneList extends StatelessWidget {
  final List<WatchlistItem> items;

  const _PhoneList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _WatchlistCard(item: item),
            ),
          )
          .toList(),
    );
  }
}

class _TabletGrid extends StatelessWidget {
  final List<WatchlistItem> items;

  const _TabletGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _WatchlistCard(item: items[i])),
                const SizedBox(width: 14),
                if (i + 1 < items.length)
                  Expanded(child: _WatchlistCard(item: items[i + 1]))
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ),
      ],
    );
  }
}

class _PortfolioSummary extends StatelessWidget {
  final int itemCount;
  final double totalValue;
  final double avgChange;

  const _PortfolioSummary({
    required this.itemCount,
    required this.totalValue,
    required this.avgChange,
  });

  @override
  Widget build(BuildContext context) {
    final isGain = avgChange >= 0;
    final sign = isGain ? '+' : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryOnColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.bookmark_rounded,
              color: AppColors.primaryOnColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Watchlist',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryOnColor.withValues(alpha: 0.75),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$itemCount coins',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryOnColor,
                    letterSpacing: -0.8,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Avg 24H',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryOnColor.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$sign${avgChange.toStringAsFixed(2)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryOnColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WatchlistCard extends StatelessWidget {
  final WatchlistItem item;

  const _WatchlistCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final history = _simulatePriceHistory(item);
    final isGain = item.isGain;
    final accentColor = isGain ? AppColors.gainAccent : AppColors.lossAccent;
    final accentLight = isGain ? AppColors.gainLight : AppColors.lossLight;
    final accentText = isGain ? AppColors.gainText : AppColors.lossText;
    final sign = isGain ? '+' : '';

    return GestureDetector(
      onTap: () => _showChartSheet(context, item, history),
      child: Container(
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accentColor.withValues(alpha: 0.25),
                            accentColor.withValues(alpha: 0.10),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          item.symbol.length >= 2
                              ? item.symbol.substring(0, 2)
                              : item.symbol,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.coinName,
                          ),
                          const SizedBox(height: 2),
                          Text(item.symbol, style: AppFonts.coinSymbol),
                        ],
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _fmtPrice(item.currentPrice),
                          style: AppFonts.coinPrice,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: accentLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$sign${item.priceChangePercentage24h.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: accentText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              _MiniSparkline(
                prices: history,
                isGain: isGain,
                accentColor: accentColor,
                height: 56,
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9),
                color: accentLight.withValues(alpha: 0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.show_chart_rounded, size: 13, color: accentText),
                    const SizedBox(width: 5),
                    Text(
                      'Tap to view price chart',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: accentText,
                      ),
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

  void _showChartSheet(
    BuildContext context,
    WatchlistItem item,
    List<double> history,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChartBottomSheet(item: item, history: history),
    );
  }
}

class _MiniSparkline extends StatelessWidget {
  final List<double> prices;
  final bool isGain;
  final Color accentColor;
  final double height;

  const _MiniSparkline({
    required this.prices,
    required this.isGain,
    required this.accentColor,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final spots = prices
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: accentColor,
              barWidth: 2.2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    accentColor.withValues(alpha: 0.22),
                    accentColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
        duration: Duration.zero,
      ),
    );
  }
}

class _ChartBottomSheet extends StatefulWidget {
  final WatchlistItem item;
  final List<double> history;

  const _ChartBottomSheet({required this.item, required this.history});

  @override
  State<_ChartBottomSheet> createState() => _ChartBottomSheetState();
}

class _ChartBottomSheetState extends State<_ChartBottomSheet> {
  int? _touchedIndex;
  double? _touchedPrice;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isGain = item.isGain;
    final accentColor = isGain ? AppColors.gainAccent : AppColors.lossAccent;
    final accentLight = isGain ? AppColors.gainLight : AppColors.lossLight;
    final accentText = isGain ? AppColors.gainText : AppColors.lossText;
    final sign = isGain ? '+' : '';

    final spots = widget.history
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    final minY = widget.history.reduce(math.min);
    final maxY = widget.history.reduce(math.max);
    final padding = (maxY - minY) * 0.12;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (context, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accentColor.withValues(alpha: 0.25),
                                accentColor.withValues(alpha: 0.10),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              item.symbol.length >= 2
                                  ? item.symbol.substring(0, 2)
                                  : item.symbol,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, style: AppFonts.detailCoinName),
                              Text(item.symbol, style: AppFonts.coinSymbol),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _touchedPrice != null
                                  ? _fmtPrice(_touchedPrice!)
                                  : _fmtPrice(item.currentPrice),
                              style: AppFonts.detailPriceMain,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: accentLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$sign${item.priceChangePercentage24h.toStringAsFixed(2)}% 24H',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: accentText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Price chart · Last 7 days',
                      style: AppFonts.detailCardTitle,
                    ),

                    const SizedBox(height: 4),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.cardBorder,
                    ),
                    const SizedBox(height: 16),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeOut,
                      child: _touchedIndex != null
                          ? SizedBox()
                          : Container(
                              key: const ValueKey('price-hint'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.statLabelBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.touch_app_rounded,
                                    size: 14,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    'Touch the chart to explore prices',
                                    style: AppFonts.lastUpdatedText,
                                  ),
                                ],
                              ),
                            ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      height: 220,
                      child: LineChart(
                        LineChartData(
                          minY: minY - padding,
                          maxY: maxY + padding,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: (maxY - minY) / 4,
                            getDrawingHorizontalLine: (_) => FlLine(
                              color: AppColors.cardBorder,
                              strokeWidth: 1,
                              dashArray: [4, 4],
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 82,
                                interval: (maxY - minY) / 4,
                                getTitlesWidget: (value, meta) {
                                  // Skip labels at the very edges to prevent overflow
                                  if (value <= meta.min || value >= meta.max) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: Text(
                                      _fmtPrice(value),
                                      style: const TextStyle(
                                        fontSize: 9.5,
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                interval: (spots.length - 1) / 3,
                                getTitlesWidget: (value, meta) {
                                  const labels = ['7d', '5d', '3d', 'Now'];
                                  final idx = (value / ((spots.length - 1) / 3))
                                      .round()
                                      .clamp(0, labels.length - 1);
                                  return Text(
                                    labels[idx],
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineTouchData: LineTouchData(
                            enabled: true,
                            handleBuiltInTouches: true,
                            touchCallback: (event, response) {
                              if (response != null &&
                                  response.lineBarSpots != null &&
                                  response.lineBarSpots!.isNotEmpty) {
                                final idx = response.lineBarSpots![0].spotIndex;
                                setState(() {
                                  _touchedIndex = idx;
                                  _touchedPrice = widget.history[idx];
                                });
                              } else if (event is FlPointerExitEvent ||
                                  event is FlTapUpEvent) {
                                setState(() {
                                  _touchedIndex = null;
                                  _touchedPrice = null;
                                });
                              }
                            },
                            getTouchedSpotIndicator: (barData, spotIndexes) =>
                                spotIndexes
                                    .map(
                                      (i) => TouchedSpotIndicatorData(
                                        FlLine(
                                          color: accentColor,
                                          strokeWidth: 1.5,
                                          dashArray: [4, 3],
                                        ),
                                        FlDotData(
                                          show: true,
                                          getDotPainter: (sp, pct, bar, idx) =>
                                              FlDotCirclePainter(
                                                radius: 5,
                                                color: AppColors.cardBackground,
                                                strokeColor: accentColor,
                                                strokeWidth: 2.5,
                                              ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (_) => accentColor,
                              tooltipRoundedRadius: 8,
                              getTooltipItems: (spots) => spots
                                  .map(
                                    (s) => LineTooltipItem(
                                      _fmtPrice(s.y),
                                      const TextStyle(
                                        color: AppColors.primaryOnColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              curveSmoothness: 0.35,
                              color: accentColor,
                              barWidth: 2.5,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    accentColor.withValues(alpha: 0.22),
                                    accentColor.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        duration: const Duration(milliseconds: 300),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _QuickStatsRow(item: item, history: widget.history),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  final WatchlistItem item;
  final List<double> history;

  const _QuickStatsRow({required this.item, required this.history});

  @override
  Widget build(BuildContext context) {
    final high = history.reduce(math.max);
    final low = history.reduce(math.min);
    final isGain = item.isGain;
    final accentText = isGain ? AppColors.gainText : AppColors.lossText;
    final accentLight = isGain ? AppColors.gainLight : AppColors.lossLight;

    return Row(
      children: [
        Expanded(
          child: _QuickStat(
            label: '7D High',
            value: _fmtPrice(high),
            accentText: AppColors.gainText,
            accentLight: AppColors.gainLight,
            icon: Icons.arrow_upward_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickStat(
            label: '7D Low',
            value: _fmtPrice(low),
            accentText: AppColors.lossText,
            accentLight: AppColors.lossLight,
            icon: Icons.arrow_downward_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickStat(
            label: '24H Change',
            value:
                '${isGain ? '+' : ''}${item.priceChangePercentage24h.toStringAsFixed(2)}%',
            accentText: accentText,
            accentLight: accentLight,
            icon: isGain
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
          ),
        ),
      ],
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final Color accentText;
  final Color accentLight;
  final IconData icon;

  const _QuickStat({
    required this.label,
    required this.value,
    required this.accentText,
    required this.accentLight,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentText.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: accentText),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: accentText,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppFonts.detailStatLabel),
        ],
      ),
    );
  }
}

class _SkeletonBody extends StatelessWidget {
  const _SkeletonBody();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final p = width >= 600 ? 24.0 : 16.0;

    return SkeletonShimmer(
      child: Padding(
        padding: EdgeInsets.fromLTRB(p, 4, p, 32),
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.skeletonBase,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Container(
                  height: 148,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            SkeletonBox(width: 46, height: 46, radius: 14),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SkeletonBox(width: 100, height: 13),
                                SizedBox(height: 6),
                                SkeletonBox(width: 50, height: 10),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 14),
                        SkeletonBox(width: double.infinity, height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                color: AppColors.primaryColor,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No coins in your watchlist',
              style: AppFonts.detailCardTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add coins from the market to track them here.',
              style: AppFonts.detailStatLabel,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

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
              decoration: const BoxDecoration(
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
              'Unable to load watchlist',
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
