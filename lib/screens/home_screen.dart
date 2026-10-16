import 'package:crypto_mobile/bloc/coin_bloc.dart';
import 'package:crypto_mobile/bloc/coin_event.dart';
import 'package:crypto_mobile/bloc/coin_state.dart';
import 'package:crypto_mobile/constants/colors.dart';
import 'package:crypto_mobile/constants/font.dart';
import 'package:crypto_mobile/core/enum.dart';
import 'package:crypto_mobile/model/coin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<CoinListBloc>();
    if (bloc.state.coins.isEmpty) {
      bloc.add(CoinsRequested());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final bool isWide = screenWidth >= 640;
            final double hPad = isWide ? 32.0 : 16.0;
            final double maxW = isWide ? 620.0 : double.infinity;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: RefreshIndicator(
                  color: AppColors.refreshSpinner,
                  backgroundColor: AppColors.cardBackground,
                  onRefresh: () async =>
                      context.read<CoinListBloc>().add(CoinsRequested()),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      // ── Header ────────────────────────────────────────────
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 14),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Crypto Market',
                                style: AppFonts.screenTitle,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Live prices & real-time performance',
                                style: AppFonts.screenSubtitle,
                              ),
                              const SizedBox(height: 18),
                              _SearchBar(
                                controller: _searchController,
                                onChanged: (q) => context
                                    .read<CoinListBloc>()
                                    .add(SearchChanged(q)),
                              ),
                              const SizedBox(height: 14),
                              _FilterChips(),
                            ],
                          ),
                        ),
                      ),

                      // ── Coin Cards ────────────────────────────────────────
                      BlocBuilder<CoinListBloc, CoinListState>(
                        builder: (context, state) {
                          // Loading
                          if (state.status == Status.loading &&
                              state.coins.isEmpty) {
                            return SliverPadding(
                              padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 24),
                              sliver: const SliverToBoxAdapter(
                                child: _LoadingPlaceholder(),
                              ),
                            );
                          }

                          // Error
                          if (state.status == Status.error &&
                              state.coins.isEmpty) {
                            return SliverPadding(
                              padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 24),
                              sliver: SliverToBoxAdapter(
                                child: _ErrorCard(
                                  message: state.error,
                                  onRetry: () => context
                                      .read<CoinListBloc>()
                                      .add(CoinsRequested()),
                                ),
                              ),
                            );
                          }

                          final coins = state.visible;

                          // Empty
                          if (coins.isEmpty) {
                            return SliverPadding(
                              padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 24),
                              sliver: const SliverToBoxAdapter(
                                child: _EmptyCard(),
                              ),
                            );
                          }

                          return SliverPadding(
                            padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 32),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _CoinCard(coin: coins[index]),
                                ),
                                childCount: coins.length,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  FUTURISTIC COIN CARD
// ═══════════════════════════════════════════════════════════════════════════

class _CoinCard extends StatelessWidget {
  final Coin coin;

  const _CoinCard({required this.coin});

  bool get _isGain => coin.priceChangePercentage24h > 0;
  bool get _isNeutral => coin.priceChangePercentage24h == 0;

  Color get _accentColor =>
      _isNeutral ? AppColors.neutralAccent : (_isGain ? AppColors.gainAccent : AppColors.lossAccent);

  Color get _accentLight =>
      _isNeutral ? AppColors.neutralLight : (_isGain ? AppColors.gainLight : AppColors.lossLight);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowPrimary,
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: AppColors.cardShadowSecond,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Coloured left accent bar ─────────────────────────────────
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: _accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),

              // ── Card content ─────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Avatar + Name/Symbol + Rank badge + % pill
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _CoinAvatar(coin: coin),
                          const SizedBox(width: 12),

                          // Name & Symbol
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  coin.name,
                                  style: AppFonts.coinName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  coin.symbol,
                                  style: AppFonts.coinSymbol,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // ── Rank badge ────────────────────────────────────
                          _RankBadge(rank: coin.marketCapRank),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Row 2: Price + Change % pill
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Price column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatPrice(coin.currentPrice),
                                  style: AppFonts.coinPrice,
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Icon(
                                      _isGain
                                          ? Icons.arrow_upward_rounded
                                          : _isNeutral
                                              ? Icons.remove_rounded
                                              : Icons.arrow_downward_rounded,
                                      size: 12,
                                      color: _isNeutral
                                          ? AppColors.neutralText
                                          : (_isGain
                                              ? AppColors.gainText
                                              : AppColors.lossText),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      _formatPriceChange(coin.priceChange24h),
                                      style: _isNeutral
                                          ? AppFonts.priceChangeNeutral
                                          : (_isGain
                                              ? AppFonts.priceChangeGain
                                              : AppFonts.priceChangeLoss),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // ── Percent pill ──────────────────────────────────
                          _PercentBadge(
                            value: coin.priceChangePercentage24h,
                            bgColor: _accentLight,
                            textStyle: _isNeutral
                                ? AppFonts.percentNeutral
                                : (_isGain
                                    ? AppFonts.percentGain
                                    : AppFonts.percentLoss),
                            icon: _isGain
                                ? Icons.trending_up_rounded
                                : _isNeutral
                                    ? Icons.trending_flat_rounded
                                    : Icons.trending_down_rounded,
                            iconColor: _accentColor,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ── Divider ───────────────────────────────────────────
                      Container(
                        height: 1,
                        color: AppColors.cardBorder,
                      ),

                      const SizedBox(height: 10),

                      // Row 3: 24H stats row
                      _StatRow(coin: coin),
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

  String _formatPrice(double price) {
    if (price >= 1000) {
      // 67,250.50
      final intStr = price.toInt().toString();
      final buffer = StringBuffer();
      for (int i = 0; i < intStr.length; i++) {
        final pos = intStr.length - i;
        buffer.write(intStr[i]);
        if (pos > 1 && pos % 3 == 1 && i != intStr.length - 1) {
          buffer.write(',');
        }
      }
      return '\$${buffer.toString()}.${(price % 1 * 100).toStringAsFixed(0).padLeft(2, '0')}';
    } else if (price >= 1) {
      return '\$${price.toStringAsFixed(2)}';
    } else {
      return '\$${price.toStringAsFixed(4)}';
    }
  }

  String _formatPriceChange(double change) {
    final abs = change.abs();
    final formatted = abs >= 1000
        ? '\$${(abs / 1000).toStringAsFixed(2)}K'
        : '\$${abs.toStringAsFixed(2)}';
    return formatted;
  }
}

// ─── Stat Row (24H High / Low / Volume) ──────────────────────────────────────

class _StatRow extends StatelessWidget {
  final Coin coin;

  const _StatRow({required this.coin});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(label: '24H HIGH', value: _compact(coin.high24h, prefix: '\$')),
        const SizedBox(width: 6),
        _StatChip(label: '24H LOW', value: _compact(coin.low24h, prefix: '\$')),
        const SizedBox(width: 6),
        _StatChip(label: 'VOLUME', value: _compact(coin.totalVolume, prefix: '\$')),
      ],
    );
  }

  String _compact(double v, {String prefix = ''}) {
    if (v >= 1e12) return '$prefix${(v / 1e12).toStringAsFixed(2)}T';
    if (v >= 1e9) return '$prefix${(v / 1e9).toStringAsFixed(2)}B';
    if (v >= 1e6) return '$prefix${(v / 1e6).toStringAsFixed(2)}M';
    if (v >= 1e3) return '$prefix${(v / 1e3).toStringAsFixed(1)}K';
    return '$prefix${v.toStringAsFixed(2)}';
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.statLabelBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.statLabelBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppFonts.statLabel),
            const SizedBox(height: 2),
            Text(value, style: AppFonts.statValue),
          ],
        ),
      ),
    );
  }
}

// ─── Percentage Pill ─────────────────────────────────────────────────────────

class _PercentBadge extends StatelessWidget {
  final double value;
  final Color bgColor;
  final TextStyle textStyle;
  final IconData icon;
  final Color iconColor;

  const _PercentBadge({
    required this.value,
    required this.bgColor,
    required this.textStyle,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final sign = value > 0 ? '+' : '';
    final label = '$sign${value.toStringAsFixed(2)}%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(label, style: textStyle),
        ],
      ),
    );
  }
}

// ─── Rank Badge ───────────────────────────────────────────────────────────────

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.rankBadgeBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.rankBadgeBorder, width: 1),
      ),
      child: Text('#$rank', style: AppFonts.rankBadge),
    );
  }
}

// ─── Coin Avatar ─────────────────────────────────────────────────────────────

class _CoinAvatar extends StatelessWidget {
  final Coin coin;

  const _CoinAvatar({required this.coin});

  static const double _size = 46.0;

  @override
  Widget build(BuildContext context) {
    final symbol = coin.symbol.toUpperCase();

    // Try network image first (CoinGecko URL)
    if (coin.image.isNotEmpty && coin.image.startsWith('http')) {
      return _avatarShell(
        symbol: symbol,
        bgColor: _symbolBg(symbol),
        borderColor: _symbolBorder(symbol),
        child: ClipOval(
          child: Image.network(
            coin.image,
            width: _size,
            height: _size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _localIcon(symbol),
          ),
        ),
      );
    }

    return _avatarShell(
      symbol: symbol,
      bgColor: _symbolBg(symbol),
      borderColor: _symbolBorder(symbol),
      child: _localIcon(symbol),
    );
  }

  Widget _avatarShell({
    required String symbol,
    required Color bgColor,
    required Color borderColor,
    required Widget child,
  }) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: child,
    );
  }

  Widget _localIcon(String symbol) {
    switch (symbol) {
      case 'BTC':
        return const Icon(
          Icons.currency_bitcoin_rounded,
          color: AppColors.btcIcon,
          size: 24,
        );
      case 'ETH':
        return const Center(
          child: CustomPaint(
            size: Size(22, 22),
            painter: _EthPainter(),
          ),
        );
      case 'USDT':
        return const Center(
          child: CustomPaint(
            size: Size(22, 22),
            painter: _TetherPainter(),
          ),
        );
      case 'SOL':
        return const Icon(Icons.bolt_rounded, color: AppColors.solIcon, size: 24);
      case 'BNB':
        return const Icon(Icons.diamond_outlined, color: AppColors.bnbIcon, size: 22);
      default:
        return Center(
          child: Text(
            symbol.length > 3 ? symbol.substring(0, 3) : symbol,
            style: AppFonts.badgeSymbol,
          ),
        );
    }
  }

  Color _symbolBg(String symbol) {
    switch (symbol) {
      case 'BTC': return AppColors.btcIconBg;
      case 'ETH': return AppColors.ethIconBg;
      case 'USDT': return AppColors.usdtIconBg;
      case 'SOL': return AppColors.solIconBg;
      case 'BNB': return AppColors.bnbIconBg;
      default: return AppColors.defaultCoinBg;
    }
  }

  Color _symbolBorder(String symbol) {
    switch (symbol) {
      case 'BTC': return AppColors.btcIconBorder;
      case 'ETH': return AppColors.ethIconBorder;
      case 'USDT': return AppColors.usdtIconBorder;
      case 'SOL': return AppColors.solIconBorder;
      case 'BNB': return AppColors.bnbIconBorder;
      default: return AppColors.defaultCoinBorder;
    }
  }
}

// ─── Custom Painters ─────────────────────────────────────────────────────────

class _EthPainter extends CustomPainter {
  const _EthPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ethIcon
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final w = size.width;
    final h = size.height;

    canvas.drawPath(
      Path()
        ..moveTo(cx, 0)
        ..lineTo(w * 0.14, h * 0.54)
        ..lineTo(cx, h * 0.43)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx, 0)
        ..lineTo(w * 0.86, h * 0.54)
        ..lineTo(cx, h * 0.43)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx, h * 0.50)
        ..lineTo(w * 0.14, h * 0.60)
        ..lineTo(cx, h)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx, h * 0.50)
        ..lineTo(w * 0.86, h * 0.60)
        ..lineTo(cx, h)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _TetherPainter extends CustomPainter {
  const _TetherPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppColors.usdtIcon
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final fill = Paint()
      ..color = AppColors.usdtIcon
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final w = size.width;
    final h = size.height;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, h * 0.48),
        width: w * 0.86,
        height: h * 0.44,
      ),
      stroke,
    );

    // T horizontal bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, h * 0.30), width: w * 0.6, height: 2.5),
        const Radius.circular(1),
      ),
      fill,
    );

    // T stem
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, h * 0.54), width: 2.5, height: h * 0.5),
        const Radius.circular(1),
      ),
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ═══════════════════════════════════════════════════════════════════════════
//  SEARCH BAR
// ═══════════════════════════════════════════════════════════════════════════

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.searchBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.searchBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowPrimary,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search_rounded,
              color: AppColors.searchIcon, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppFonts.searchInput,
              cursorColor: AppColors.refreshSpinner,
              decoration: const InputDecoration(
                hintText: 'Search coin or symbol…',
                hintStyle: AppFonts.searchHint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              child: const Icon(Icons.close_rounded,
                  color: AppColors.searchIcon, size: 20),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  FILTER CHIPS
// ═══════════════════════════════════════════════════════════════════════════

class _FilterChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final current = context
        .select<CoinListBloc, FilterBy>((b) => b.state.filter);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _Chip(
            label: 'All Coins',
            selected: current == FilterBy.all,
            onTap: () => context
                .read<CoinListBloc>()
                .add(FilterChanged(FilterBy.all)),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: '▲ Gainers',
            selected: current == FilterBy.gainers,
            onTap: () => context
                .read<CoinListBloc>()
                .add(FilterChanged(FilterBy.gainers)),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: '▼ Losers',
            selected: current == FilterBy.losers,
            onTap: () => context
                .read<CoinListBloc>()
                .add(FilterChanged(FilterBy.losers)),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.activeChipBg : AppColors.inactiveChipBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppColors.activeChipBg : AppColors.chipBorder,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: AppColors.cardShadowPrimary,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style:
              selected ? AppFonts.activeChipLabel : AppFonts.chipLabel,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  STATUS CARDS
// ═══════════════════════════════════════════════════════════════════════════

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 14),
          height: 148,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.refreshSpinner,
              strokeWidth: 2.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 52, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                color: AppColors.textMuted, size: 48),
            SizedBox(height: 12),
            Text(
              'No coins match your search.',
              style: AppFonts.statusMessage,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.lossAccent, size: 44),
            const SizedBox(height: 12),
            Text(
              message.isNotEmpty ? message : 'Failed to load coin data.',
              style: AppFonts.statusMessage,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              child: const Text('Try Again', style: AppFonts.actionButton),
            ),
          ],
        ),
      ),
    );
  }
}
