import 'package:crypto_mobile/bloc/coin_bloc.dart';
import 'package:crypto_mobile/bloc/coin_event.dart';
import 'package:crypto_mobile/bloc/coin_state.dart';
import 'package:crypto_mobile/constants/colors.dart';
import 'package:crypto_mobile/constants/font.dart';
import 'package:crypto_mobile/core/enum.dart';
import 'package:crypto_mobile/screens/widgets/coin_card.dart';
import 'package:crypto_mobile/screens/widgets/empty_card.dart';
import 'package:crypto_mobile/screens/widgets/error_card.dart';
import 'package:crypto_mobile/screens/widgets/search_bar.dart';
import 'package:crypto_mobile/widgets/skeleton_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 640;
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
                      parent: ClampingScrollPhysics(),
                    ),
                    slivers: [
                      // ── Header ───────────────────────────────────────────
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title + action buttons row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Crypto Market',
                                            style: AppFonts.screenTitle),
                                        SizedBox(height: 3),
                                        Text(
                                            'Live prices & real-time performance',
                                            style: AppFonts.screenSubtitle),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Filter button
                                  _FilterButton(),
                                  const SizedBox(width: 8),
                                  // Sort button
                                  const _SortButton(),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Search bar
                              CoinSearchBar(
                                controller: _searchController,
                                onChanged: (q) => context
                                    .read<CoinListBloc>()
                                    .add(SearchChanged(q)),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),

                      // ── Coin list ────────────────────────────────────────
                      BlocBuilder<CoinListBloc, CoinListState>(
                        builder: (context, state) {
                          // Initial load — no coins yet
                          if (state.status == Status.loading &&
                              state.coins.isEmpty) {
                            return SliverPadding(
                              padding:
                                  EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
                              sliver: const SliverToBoxAdapter(
                                child: SkeletonCoinCardList(cardCount: 6),
                              ),
                            );
                          }

                          if (state.status == Status.error &&
                              state.coins.isEmpty) {
                            return SliverPadding(
                              padding:
                                  EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
                              sliver: SliverToBoxAdapter(
                                child: ErrorCard(
                                  message: state.error,
                                  onRetry: () => context
                                      .read<CoinListBloc>()
                                      .add(CoinsRequested()),
                                ),
                              ),
                            );
                          }

                          // Loading with existing coins (filter/sort/search)
                          if (state.status == Status.loading &&
                              state.coins.isNotEmpty) {
                            return SliverPadding(
                              padding:
                                  EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
                              sliver: const SliverToBoxAdapter(
                                child: SkeletonCoinCardList(cardCount: 6),
                              ),
                            );
                          }

                          final coins = state.visible;
                          if (coins.isEmpty) {
                            return SliverPadding(
                              padding:
                                  EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
                              sliver: const SliverToBoxAdapter(
                                child: EmptyCard(),
                              ),
                            );
                          }

                          return SliverPadding(
                            padding:
                                EdgeInsets.fromLTRB(hPad, 12, hPad, 32),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 14),
                                  child: CoinCard(
                                    coin: coins[index],
                                    allCoins: state.coins,
                                  ),
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
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  FILTER BUTTON  (header)
// ══════════════════════════════════════════════════════════════════════════════

class _FilterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoinListBloc, CoinListState>(
      buildWhen: (p, c) =>
          p.minPrice != c.minPrice ||
          p.maxPrice != c.maxPrice,
      builder: (context, state) {
        final active = state.hasActiveFilter;
        return GestureDetector(
          onTap: () => _showFilterSheet(context, state),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFFEEF1FF)
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active
                    ? AppColors.rankBadgeBorder
                    : AppColors.cardBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 16,
                  color: active
                      ? AppColors.rankBadgeText
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 5),
                Text(
                  'Filter',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? AppColors.rankBadgeText
                        : AppColors.textSecondary,
                  ),
                ),
                if (active) ...[
                  const SizedBox(width: 5),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.rankBadgeText,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context, CoinListState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<CoinListBloc>(),
        child: _FilterBottomSheet(state: state),
      ),
    );
  }
}



class _FilterBottomSheet extends StatefulWidget {
  final CoinListState state;
  const _FilterBottomSheet({required this.state});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  final TextEditingController _minCtrl = TextEditingController();
  final TextEditingController _maxCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.state.minPrice != null) {
      _minCtrl.text = widget.state.minPrice!
          .toStringAsFixed(widget.state.minPrice! < 1 ? 4 : 0);
    }
    if (widget.state.maxPrice != null) {
      _maxCtrl.text = widget.state.maxPrice!
          .toStringAsFixed(widget.state.maxPrice! < 1 ? 4 : 0);
    }
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  double? _parsePrice(String text) {
    final v = double.tryParse(text.trim());
    if (v == null || v < 0) return null;
    return v;
  }

  void _apply() {
    final bloc = context.read<CoinListBloc>();
    bloc.add(FilterApplied(
      minPrice: _parsePrice(_minCtrl.text),
      maxPrice: _parsePrice(_maxCtrl.text),
    ));
    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _minCtrl.clear();
      _maxCtrl.clear();
    });
    context.read<CoinListBloc>().add(FilterReset());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Handle ──────────────────────────────────────────────────
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Title row ────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF1FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.tune_rounded,
                      color: AppColors.rankBadgeText, size: 18),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter Coins',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Filter by price range',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 22),

           

            Row(
              children: [
                Expanded(
                  child: _PriceInput(
                    controller: _minCtrl,
                    hint: 'Min price',
                    label: 'Minimum',
                    icon: Icons.arrow_downward_rounded,
                    iconColor: AppColors.gainText,
                    iconBg: AppColors.gainLight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PriceInput(
                    controller: _maxCtrl,
                    hint: 'Max price',
                    label: 'Maximum',
                    icon: Icons.arrow_upward_rounded,
                    iconColor: AppColors.lossText,
                    iconBg: AppColors.lossLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            Row(
              children: [
                // Reset
                Expanded(
                  child: GestureDetector(
                    onTap: _reset,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh_rounded,
                              size: 16, color: AppColors.textSecondary),
                          SizedBox(width: 6),
                          Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Apply
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _apply,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.rankBadgeText,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.rankBadgeText.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded,
                              size: 16, color: AppColors.textLight),
                          SizedBox(width: 6),
                          Text(
                            'Apply Filter',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _PriceInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _PriceInput({
    required this.controller,
    required this.hint,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(5)),
              child: Icon(icon, size: 11, color: iconColor),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w400,
              ),
              prefixText: '\$  ',
              prefixStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}


class _SortButton extends StatelessWidget {
  const _SortButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoinListBloc, CoinListState>(
      buildWhen: (p, c) =>
          p.sortBy != c.sortBy || p.ascending != c.ascending,
      builder: (context, state) {
        final active = state.hasActiveSort;
        return GestureDetector(
          onTap: () => _showSortSheet(context, state),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primaryLight
                  : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active
                    ? AppColors.primaryBorder
                    : AppColors.cardBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sort_rounded,
                    size: 16,
                    color: active
                        ? AppColors.primaryColor
                        : AppColors.textSecondary),
                const SizedBox(width: 5),
                Text(
                  active ? state.sortBy.label : 'Sort',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? AppColors.primaryColor
                        : AppColors.textSecondary,
                  ),
                ),
                if (active) ...[
                  const SizedBox(width: 3),
                  Icon(
                    state.ascending
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 12,
                    color: AppColors.primaryColor,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSortSheet(BuildContext context, CoinListState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<CoinListBloc>(),
        child: const _SortBottomSheet(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  SORT BOTTOM SHEET
// ══════════════════════════════════════════════════════════════════════════════

class _SortBottomSheet extends StatelessWidget {
  const _SortBottomSheet();

  static const _options = [
    (SortBy.marketCap, 'Market Cap', Icons.pie_chart_rounded),
    (SortBy.price, 'Price', Icons.attach_money_rounded),
    (SortBy.volume, 'Volume 24H', Icons.bar_chart_rounded),
    (SortBy.change, 'Change 24H', Icons.show_chart_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoinListBloc, CoinListState>(
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title row
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.sort_rounded,
                        color: AppColors.primaryColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sort By',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            )),
                        Text('Tap again to toggle direction',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  // Reset button (always visible)
                  GestureDetector(
                    onTap: state.hasActiveSort
                        ? () {
                            context.read<CoinListBloc>().add(SortReset());
                            Navigator.pop(context);
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: state.hasActiveSort
                            ? AppColors.lossLight
                            : AppColors.scaffoldBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: state.hasActiveSort
                              ? AppColors.lossAccent.withValues(alpha: 0.3)
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.refresh_rounded,
                              size: 13,
                              color: state.hasActiveSort
                                  ? AppColors.lossText
                                  : AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text('Reset',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: state.hasActiveSort
                                    ? AppColors.lossText
                                    : AppColors.textMuted,
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Sort options
              ..._options.map((entry) {
                final (sortBy, label, icon) = entry;
                final isSelected = state.sortBy == sortBy;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SortOptionTile(
                    icon: icon,
                    label: label,
                    isSelected: isSelected,
                    ascending: state.ascending,
                    onTap: () {
                      context
                          .read<CoinListBloc>()
                          .add(SortChanged(sortBy));
                      Navigator.pop(context);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// ── Sort option tile ──────────────────────────────────────────────────────────

class _SortOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool ascending;
  final VoidCallback onTap;

  const _SortOptionTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.ascending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight
              : AppColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBorder
                : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor.withValues(alpha: 0.12)
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  size: 18,
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.textMuted),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.textSecondary,
                ),
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      ascending
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 12,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      ascending ? 'Asc' : 'Desc',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              )
            else
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

