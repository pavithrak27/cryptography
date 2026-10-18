import 'package:crypto_mobile/constants/colors.dart';
import 'package:crypto_mobile/constants/font.dart';
import 'package:crypto_mobile/model/coin.dart';
import 'package:crypto_mobile/screens/coin_detail_screen.dart';
import 'package:crypto_mobile/screens/widgets/coin_avatar.dart';
import 'package:crypto_mobile/screens/widgets/percent_badge.dart';
import 'package:crypto_mobile/screens/widgets/rank_badge.dart';
import 'package:crypto_mobile/screens/widgets/stat_row.dart';
import 'package:flutter/material.dart';

class CoinCard extends StatelessWidget {
  final Coin coin;
  final List<Coin> allCoins;

  const CoinCard({super.key, required this.coin, required this.allCoins});

  bool get _isGain => coin.priceChangePercentage24h > 0;
  bool get _isNeutral => coin.priceChangePercentage24h == 0;

  Color get _accentColor => _isNeutral
      ? AppColors.neutralAccent
      : (_isGain ? AppColors.gainAccent : AppColors.lossAccent);

  Color get _accentLight => _isNeutral
      ? AppColors.neutralLight
      : (_isGain ? AppColors.gainLight : AppColors.lossLight);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                CoinDetailScreen(
                  coins: allCoins.isNotEmpty ? allCoins : [coin],
                  selectedCoin: coin,
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  );
                },
          ),
        );
      },
      child: Container(
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

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CoinAvatar(coin: coin),
                            const SizedBox(width: 12),

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
                                  Text(coin.symbol, style: AppFonts.coinSymbol),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                           
                            RankBadge(rank: coin.marketCapRank),
                          ],
                        ),

                        const SizedBox(height: 12),

                       
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
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

                            PercentBadge(
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

                       
                        Container(height: 1, color: AppColors.cardBorder),

                        const SizedBox(height: 10),

                        StatRow(coin: coin),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ), // end ClipRRect
      ), // end Container
    ); // end GestureDetector
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
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


