import 'package:flutter/material.dart';
import 'colors.dart';

/// Centralized typography system for the crypto application.
/// All text styles used in screens/widgets must come from here.
class AppFonts {
  AppFonts._();

  // ─── Screen Header ─────────────────────────────────────────────────────────
  static const TextStyle screenTitle = TextStyle(
    fontSize: 26.0,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.6,
    height: 1.2,
  );

  static const TextStyle screenSubtitle = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    letterSpacing: 0.1,
  );

  // ─── Coin Card ─────────────────────────────────────────────────────────────

  /// Coin full name: "Bitcoin"
  static const TextStyle coinName = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.2,
  );

  /// Coin symbol: "BTC"
  static const TextStyle coinSymbol = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.4,
  );

  /// Current price: "$67,250.50"
  static const TextStyle coinPrice = TextStyle(
    fontSize: 19.0,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// Price change amount: "+$850.50"
  static const TextStyle priceChangeGain = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    color: AppColors.gainText,
    letterSpacing: 0.1,
  );

  static const TextStyle priceChangeLoss = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    color: AppColors.lossText,
    letterSpacing: 0.1,
  );

  static const TextStyle priceChangeNeutral = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    color: AppColors.neutralText,
    letterSpacing: 0.1,
  );

  /// Percentage badge: "+1.28%"
  static const TextStyle percentGain = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w700,
    color: AppColors.gainText,
    letterSpacing: -0.1,
  );

  static const TextStyle percentLoss = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w700,
    color: AppColors.lossText,
    letterSpacing: -0.1,
  );

  static const TextStyle percentNeutral = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w700,
    color: AppColors.neutralText,
    letterSpacing: -0.1,
  );

  // ─── Stat Label Row ────────────────────────────────────────────────────────

  /// Label: "24H HIGH"
  static const TextStyle statLabel = TextStyle(
    fontSize: 9.5,
    fontWeight: FontWeight.w700,
    color: AppColors.statLabelText,
    letterSpacing: 0.8,
  );

  /// Value: "$68,100"
  static const TextStyle statValue = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    letterSpacing: -0.2,
  );

  // ─── Rank Badge ────────────────────────────────────────────────────────────
  static const TextStyle rankBadge = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w800,
    color: AppColors.rankBadgeText,
    letterSpacing: 0.2,
  );

  // ─── Coin Avatar Fallback ──────────────────────────────────────────────────
  static const TextStyle badgeSymbol = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  // ─── Search & Chips ────────────────────────────────────────────────────────
  static const TextStyle searchInput = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle searchHint = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const TextStyle chipLabel = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const TextStyle activeChipLabel = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
  );

  // ─── Status Messages ───────────────────────────────────────────────────────
  static const TextStyle statusMessage = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle actionButton = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w700,
    color: AppColors.textLight,
  );
}
