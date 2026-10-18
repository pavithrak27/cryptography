import 'package:crypto_mobile/constants/colors.dart';
import 'package:crypto_mobile/constants/font.dart';
import 'package:crypto_mobile/model/coin.dart';
import 'package:crypto_mobile/widgets/skeleton_loader.dart';
import 'package:flutter/material.dart';


String _fmtPrice(double price) {
  if (price >= 1000) {
    final i = price.toInt().toString();
    final b = StringBuffer();
    for (int k = 0; k < i.length; k++) {
      final pos = i.length - k;
      b.write(i[k]);
      if (pos > 1 && pos % 3 == 1 && k != i.length - 1) b.write(',');
    }
    return '\$$b.${(price % 1 * 100).toStringAsFixed(0).padLeft(2, '0')}';
  }
  if (price >= 1) return '\$${price.toStringAsFixed(2)}';
  return '\$${price.toStringAsFixed(4)}';
}

String _fmtCompact(double v) {
  if (v >= 1e12) return '\$${(v / 1e12).toStringAsFixed(2)}T';
  if (v >= 1e9) return '\$${(v / 1e9).toStringAsFixed(2)}B';
  if (v >= 1e6) return '\$${(v / 1e6).toStringAsFixed(2)}M';
  if (v >= 1e3) return '\$${(v / 1e3).toStringAsFixed(1)}K';
  return '\$${v.toStringAsFixed(2)}';
}

String _fmtSupply(double v, String sym) {
  if (v >= 1e9) return '${(v / 1e9).toStringAsFixed(2)}B $sym';
  if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(2)}M $sym';
  if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(1)}K $sym';
  return '${v.toStringAsFixed(0)} $sym';
}


class CoinDetailScreen extends StatefulWidget {
  final List<Coin> coins;
  final Coin selectedCoin;

  const CoinDetailScreen({
    super.key,
    required this.coins,
    required this.selectedCoin,
  });

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  late Coin _coin;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _coin = widget.selectedCoin;
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            _DetailAppBar(onBack: () => Navigator.pop(context)),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _isLoading
                    ? const SingleChildScrollView(
                        key: ValueKey('skeleton'),
                        physics: NeverScrollableScrollPhysics(),
                        child: SkeletonCoinDetail(),
                      )
                    : SingleChildScrollView(
                        key: const ValueKey('content'),
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 2. Price card (name + price + 24h change)
                          _PriceCard(coin: _coin),

                          const SizedBox(height: 14),

                          _RangeCard(coin: _coin),

                          const SizedBox(height: 14),

                          _StatsRow(coin: _coin),

                          const SizedBox(height: 14),

                          // 5. Token supply (circ, total, max + bar)
                          _SupplyCard(coin: _coin),

                          const SizedBox(height: 14),

                          // 6. All time high / low (ath, atl + range bar)
                          _AllTimeCard(coin: _coin),

                          // 7. Last updated (only if field exists)
                          if (_coin.lastUpdated != null) ...[
                            const SizedBox(height: 14),
                            _LastUpdatedRow(lastUpdated: _coin.lastUpdated!),
                          ],
                        ],
                      ),
                    ),
                  ],          // closes Column.children
                ),            // closes Column
              ),              // closes SingleChildScrollView (content)
            ),                // closes AnimatedSwitcher
          ),                  // closes Expanded
          ],
        ),
      ),
    );
  }
}


class _DetailAppBar extends StatelessWidget {
  final VoidCallback onBack;

  const _DetailAppBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          const Expanded(
            child: Text(
              'Coin Details',
              textAlign: TextAlign.center,
              style: AppFonts.screenTitle,
            ),
          ),
          // Spacer to keep title centred
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _CoinAvatar extends StatelessWidget {
  final Coin coin;
  final double size;
  final bool isActive;

  const _CoinAvatar({
    required this.coin,
    required this.size,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final sym = coin.symbol.toUpperCase();

    if (coin.image.isNotEmpty && coin.image.startsWith('http')) {
      return ClipOval(
        child: Image.network(
          coin.image,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, e, s) => _fallback(sym),
        ),
      );
    }
    return _fallback(sym);
  }

  Widget _fallback(String sym) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primaryOnColor.withValues(alpha: 0.2)
            : _bg(sym),
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive
              ? AppColors.primaryOnColor.withValues(alpha: 0.3)
              : _border(sym),
          width: 1.5,
        ),
      ),
      child: Center(child: _icon(sym)),
    );
  }

  Widget _icon(String sym) {
    final color = isActive ? AppColors.primaryOnColor : _iconColor(sym);
    switch (sym) {
      case 'BTC':
        return Icon(Icons.currency_bitcoin_rounded, color: color, size: size * 0.50);
      case 'SOL':
        return Icon(Icons.bolt_rounded, color: color, size: size * 0.52);
      case 'BNB':
        return Icon(Icons.diamond_outlined, color: color, size: size * 0.48);
      default:
        return Text(
          sym.length > 3 ? sym.substring(0, 3) : sym,
          style: TextStyle(
            fontSize: size * 0.26,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        );
    }
  }

  Color _iconColor(String sym) {
    switch (sym) {
      case 'BTC':  return AppColors.btcIcon;
      case 'ETH':  return AppColors.ethIcon;
      case 'USDT': return AppColors.usdtIcon;
      case 'SOL':  return AppColors.solIcon;
      case 'BNB':  return AppColors.bnbIcon;
      default:     return AppColors.defaultCoinIcon;
    }
  }

  Color _bg(String sym) {
    switch (sym) {
      case 'BTC':  return AppColors.btcIconBg;
      case 'ETH':  return AppColors.ethIconBg;
      case 'USDT': return AppColors.usdtIconBg;
      case 'SOL':  return AppColors.solIconBg;
      case 'BNB':  return AppColors.bnbIconBg;
      default:     return AppColors.defaultCoinBg;
    }
  }

  Color _border(String sym) {
    switch (sym) {
      case 'BTC':  return AppColors.btcIconBorder;
      case 'ETH':  return AppColors.ethIconBorder;
      case 'USDT': return AppColors.usdtIconBorder;
      case 'SOL':  return AppColors.solIconBorder;
      case 'BNB':  return AppColors.bnbIconBorder;
      default:     return AppColors.defaultCoinBorder;
    }
  }
}


class _PriceCard extends StatelessWidget {
  final Coin coin;

  const _PriceCard({required this.coin});

  @override
  Widget build(BuildContext context) {
    final isGain = coin.priceChangePercentage24h >= 0;
    final sign = isGain ? '+' : '';
    final pctLabel = '$sign${coin.priceChangePercentage24h.toStringAsFixed(2)}%';
    final change24h = coin.priceChange24h.abs();
    final changeLabel = '${isGain ? '+' : '-'}${_fmtPrice(change24h)} today';

    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coin identity row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _CoinAvatar(coin: coin, size: 48),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coin.name,
                      style: AppFonts.detailCoinName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      coin.symbol.toUpperCase(),
                      style: AppFonts.detailCoinSymbol,
                    ),
                  ],
                ),
              ),
              // market_cap_rank badge
              _RankBadge(rank: coin.marketCapRank),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: AppColors.cardBorder),
          const SizedBox(height: 16),

          // current_price (large)
          Text(_fmtPrice(coin.currentPrice), style: AppFonts.detailPriceMain),

          const SizedBox(height: 10),

          // Change row: % badge + absolute change label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isGain ? AppColors.gainLight : AppColors.lossLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isGain
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 14,
                      color: isGain ? AppColors.gainText : AppColors.lossText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      pctLabel,
                      style: isGain
                          ? AppFonts.percentGain
                          : AppFonts.percentLoss,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                changeLabel,
                style: isGain
                    ? AppFonts.detailPriceChangeGain
                    : AppFonts.detailPriceChangeLoss,
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.rankBadgeBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.rankBadgeBorder),
      ),
      child: Text('#$rank', style: AppFonts.rankBadge),
    );
  }
}


class _RangeCard extends StatelessWidget {
  final Coin coin;

  const _RangeCard({required this.coin});

  @override
  Widget build(BuildContext context) {
    final lo = coin.low24h;
    final hi = coin.high24h;
    final cur = coin.currentPrice;
    final range = hi - lo;
    final pct = range > 0 ? ((cur - lo) / range).clamp(0.0, 1.0) : 0.5;
    final pctLabel =
        '${(pct * 100).toStringAsFixed(0)}% through today\'s range';

    return _DetailCard(
      title: '24H Price Range',
      titleIcon: Icons.candlestick_chart_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final dotX = w * pct;
              const barH = 8.0;
              const dotR = 11.0;

              return SizedBox(
                height: 30,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Background track
                    Positioned(
                      left: 0,
                      right: 0,
                      child: Container(
                        height: barH,
                        decoration: BoxDecoration(
                          color: AppColors.statLabelBg,
                          borderRadius: BorderRadius.circular(barH / 2),
                        ),
                      ),
                    ),

                    // Filled portion (low → current)
                    Positioned(
                      left: 0,
                      child: Container(
                        width: dotX.clamp(barH, w),
                        height: barH,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryLight,
                              AppColors.primaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(barH / 2),
                        ),
                      ),
                    ),

                    // Current price dot
                    Positioned(
                      left: (dotX - dotR).clamp(0.0, w - dotR * 2),
                      child: Container(
                        width: dotR * 2,
                        height: dotR * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.cardBackground,
                          border: Border.all(
                            color: AppColors.primaryColor,
                            width: 3,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.selectorShadow,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RangeLabelCol(
                label: 'LOW',
                value: _fmtPrice(lo),
                align: CrossAxisAlignment.start,
                highlight: false,
              ),
              _RangeLabelCol(
                label: 'CURRENT',
                value: _fmtPrice(cur),
                align: CrossAxisAlignment.center,
                highlight: true,
              ),
              _RangeLabelCol(
                label: 'HIGH',
                value: _fmtPrice(hi),
                align: CrossAxisAlignment.end,
                highlight: false,
              ),
            ],
          ),

          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              pctLabel,
              textAlign: TextAlign.center,
              style: AppFonts.supplyPercentLabel,
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeLabelCol extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment align;
  final bool highlight;

  const _RangeLabelCol({
    required this.label,
    required this.value,
    required this.align,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(label, style: AppFonts.rangeBarLabel),
        const SizedBox(height: 3),
        Text(
          value,
          style: highlight
              ? AppFonts.rangeBarValueHighlight
              : AppFonts.rangeBarValue,
        ),
      ],
    );
  }
}


class _StatsRow extends StatelessWidget {
  final Coin coin;

  const _StatsRow({required this.coin});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            label: 'Volume 24H',
            value: _fmtCompact(coin.totalVolume),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            label: 'Market Cap',
            value: _fmtCompact(coin.marketCap),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatChip(
            label: 'CMC Rank',
            value: '#${coin.marketCapRank}',
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowPrimary,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppFonts.detailStatValue),
          const SizedBox(height: 4),
          Text(label, style: AppFonts.detailStatLabel),
        ],
      ),
    );
  }
}


class _SupplyCard extends StatelessWidget {
  final Coin coin;

  const _SupplyCard({required this.coin});

  @override
  Widget build(BuildContext context) {
    final sym = coin.symbol.toUpperCase();
    final hasMax = coin.maxSupply != null && coin.maxSupply! > 0;
    final pct = hasMax
        ? (coin.circulatingSupply / coin.maxSupply!).clamp(0.0, 1.0)
        : null;

    return _DetailCard(
      title: 'Token Supply',
      titleIcon: Icons.pie_chart_outline_rounded,
      child: Column(
        children: [
          _SupplyRow(
            label: 'Circulating',
            value: _fmtSupply(coin.circulatingSupply, sym),
            primary: true,
          ),

          if (coin.totalSupply != null) ...[
            const SizedBox(height: 10),
            _SupplyRow(
              label: 'Total Supply',
              value: _fmtSupply(coin.totalSupply!, sym),
            ),
          ],

          if (hasMax) ...[
            const SizedBox(height: 10),
            _SupplyRow(
              label: 'Max Supply',
              value: _fmtSupply(coin.maxSupply!, sym),
            ),

            const SizedBox(height: 16),

            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  Container(height: 8, color: AppColors.statLabelBg),
                  FractionallySizedBox(
                    widthFactor: pct,
                    child: Container(
                      height: 8,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryLight,
                            AppColors.primaryColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Circulating', style: AppFonts.rangeBarLabel),
                Text(
                  '${(pct! * 100).toStringAsFixed(1)}% of max supply',
                  style: AppFonts.supplyPercentLabel,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SupplyRow extends StatelessWidget {
  final String label;
  final String value;
  final bool primary;

  const _SupplyRow({
    required this.label,
    required this.value,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppFonts.detailStatLabel),
        Text(
          value,
          style: primary
              ? AppFonts.rangeBarValueHighlight
              : AppFonts.detailRowValue,
        ),
      ],
    );
  }
}


class _AllTimeCard extends StatelessWidget {
  final Coin coin;

  const _AllTimeCard({required this.coin});

  @override
  Widget build(BuildContext context) {
    final athPct = (coin.currentPrice - coin.ath) / coin.ath * 100;
    final atlPct = (coin.currentPrice - coin.atl) / coin.atl * 100;

    final athLabel =
        '${athPct.toStringAsFixed(1)}% from ATH';
    final atlLabel = atlPct > 999
        ? '+${(atlPct / 1000).toStringAsFixed(1)}K% from ATL'
        : '+${atlPct.toStringAsFixed(0)}% from ATL';

    final range = coin.ath - coin.atl;
    final barPct = range > 0
        ? ((coin.currentPrice - coin.atl) / range).clamp(0.0, 1.0)
        : 0.5;

    return _DetailCard(
      title: 'All Time',
      titleIcon: Icons.auto_graph_rounded,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _AllTimeItem(
                  badge: 'ATH',
                  badgeGain: false,
                  value: _fmtPrice(coin.ath),
                  changeLabel: athLabel,
                  changeGain: false, // current is below ATH
                ),
              ),
              Container(
                width: 1,
                height: 58,
                color: AppColors.cardBorder,
              ),
              Expanded(
                child: _AllTimeItem(
                  badge: 'ATL',
                  badgeGain: true,
                  value: _fmtPrice(coin.atl),
                  changeLabel: atlLabel,
                  changeGain: true, // current is above ATL
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final dotX = w * barPct;
              const barH = 8.0;
              const dotR = 10.0;

              return SizedBox(
                height: 26,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Full gradient bar (ATL=red-ish → ATH=teal)
                    Positioned(
                      left: 0,
                      right: 0,
                      child: Container(
                        height: barH,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.lossLight,
                              AppColors.primaryLight,
                              AppColors.primaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(barH / 2),
                        ),
                      ),
                    ),
                    Positioned(
                      left: (dotX - dotR).clamp(0.0, w - dotR * 2),
                      child: Container(
                        width: dotR * 2,
                        height: dotR * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.cardBackground,
                          border: Border.all(
                            color: AppColors.primaryColor,
                            width: 2.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.selectorShadow,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 7),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ATL  ${_fmtPrice(coin.atl)}', style: AppFonts.rangeBarLabel),
              Text('ATH  ${_fmtPrice(coin.ath)}', style: AppFonts.rangeBarLabel),
            ],
          ),
        ],
      ),
    );
  }
}

class _AllTimeItem extends StatelessWidget {
  final String badge;
  final bool badgeGain;
  final String value;
  final String changeLabel;
  final bool changeGain;

  const _AllTimeItem({
    required this.badge,
    required this.badgeGain,
    required this.value,
    required this.changeLabel,
    required this.changeGain,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coloured badge: ATH / ATL
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeGain ? AppColors.gainLight : AppColors.lossLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: badgeGain ? AppColors.gainText : AppColors.lossText,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(value, style: AppFonts.detailStatValue),
          const SizedBox(height: 3),
          Text(
            changeLabel,
            style: changeGain
                ? AppFonts.athChangeGain
                : AppFonts.athChangeLoss,
          ),
        ],
      ),
    );
  }
}


class _LastUpdatedRow extends StatelessWidget {
  final String lastUpdated;

  const _LastUpdatedRow({required this.lastUpdated});

  String _fmt(String raw) {
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $h:$m UTC';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.access_time_rounded,
          size: 13,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 5),
        Text(
          'Last updated: ${_fmt(lastUpdated)}',
          style: AppFonts.lastUpdatedText,
        ),
      ],
    );
  }
}


class _DetailCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final IconData? titleIcon;

  const _DetailCard({
    required this.child,
    this.title,
    this.titleIcon,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && titleIcon != null) ...[
            Row(
              children: [
                Icon(titleIcon, size: 15, color: AppColors.primaryColor),
                const SizedBox(width: 7),
                Text(title!, style: AppFonts.detailCardTitle),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: AppColors.cardBorder),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}
