
import 'package:crypto_mobile/constants/colors.dart';
import 'package:crypto_mobile/constants/font.dart';
import 'package:crypto_mobile/model/coin.dart';
import 'package:crypto_mobile/screens/widgets/eth_painter.dart';
import 'package:crypto_mobile/screens/widgets/tether_painter.dart';
import 'package:flutter/material.dart';

class CoinAvatar extends StatelessWidget {
  final Coin coin;

  const CoinAvatar({super.key, required this.coin});

  static const double _size = 46.0;

  @override
  Widget build(BuildContext context) {
    final symbol = coin.symbol.toUpperCase();

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
            errorBuilder: (context, error, stackTrace) => _localIcon(symbol),
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
          child: CustomPaint(size: Size(22, 22), painter: EthPainter()),
        );
      case 'USDT':
        return const Center(
          child: CustomPaint(size: Size(22, 22), painter: TetherPainter()),
        );
      case 'SOL':
        return const Icon(
          Icons.bolt_rounded,
          color: AppColors.solIcon,
          size: 24,
        );
      case 'BNB':
        return const Icon(
          Icons.diamond_outlined,
          color: AppColors.bnbIcon,
          size: 22,
        );
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
      case 'BTC':
        return AppColors.btcIconBg;
      case 'ETH':
        return AppColors.ethIconBg;
      case 'USDT':
        return AppColors.usdtIconBg;
      case 'SOL':
        return AppColors.solIconBg;
      case 'BNB':
        return AppColors.bnbIconBg;
      default:
        return AppColors.defaultCoinBg;
    }
  }

  Color _symbolBorder(String symbol) {
    switch (symbol) {
      case 'BTC':
        return AppColors.btcIconBorder;
      case 'ETH':
        return AppColors.ethIconBorder;
      case 'USDT':
        return AppColors.usdtIconBorder;
      case 'SOL':
        return AppColors.solIconBorder;
      case 'BNB':
        return AppColors.bnbIconBorder;
      default:
        return AppColors.defaultCoinBorder;
    }
  }
}

