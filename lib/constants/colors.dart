import 'package:flutter/material.dart';

/// Centralized color palette for the crypto application (Light Mode).
/// All colors used across screens and widgets are defined here.
/// No color should be used directly in screens/widgets — always call from here.
class AppColors {
  AppColors._();

  // ─── Scaffold & Background ─────────────────────────────────────────────────
  static const Color scaffoldBackground = Color(0xFFF0F4FF);
  static const Color surfaceBackground  = Color(0xFFFAFCFF);

  // ─── Card Colors ──────────────────────────────────────────────────────────
  static const Color cardBackground     = Color(0xFFFFFFFF);
  static const Color cardBorder         = Color(0xFFE8EEFF);
  static const Color cardShadowPrimary  = Color(0x1A6B84D6);
  static const Color cardShadowSecond   = Color(0x0A000000);

  // ─── Gain / Loss Accent ────────────────────────────────────────────────────
  static const Color gainAccent         = Color(0xFF00C9A7);  // teal-green
  static const Color gainLight          = Color(0xFFE6FAF7);
  static const Color gainText           = Color(0xFF00A085);

  static const Color lossAccent         = Color(0xFFFF6B8A);  // rose-pink
  static const Color lossLight          = Color(0xFFFFEEF3);
  static const Color lossText           = Color(0xFFD94068);

  static const Color neutralAccent      = Color(0xFFB0BEC5);
  static const Color neutralLight       = Color(0xFFF0F4F8);
  static const Color neutralText        = Color(0xFF718096);

  // ─── Typography ────────────────────────────────────────────────────────────
  static const Color textPrimary        = Color(0xFF1A202C);
  static const Color textSecondary      = Color(0xFF4A5568);
  static const Color textMuted          = Color(0xFF90A0B7);
  static const Color textLight          = Color(0xFFFFFFFF);

  // ─── Rank Badge ────────────────────────────────────────────────────────────
  static const Color rankBadgeBg        = Color(0xFFEEF1FF);
  static const Color rankBadgeText      = Color(0xFF5A72CB);
  static const Color rankBadgeBorder    = Color(0xFFD0D8F8);

  // ─── Coin-Specific Icon Colors ─────────────────────────────────────────────
  // Bitcoin
  static const Color btcIcon            = Color(0xFFF7931A);
  static const Color btcIconBg          = Color(0xFFFFF5E6);
  static const Color btcIconBorder      = Color(0xFFFFDFA5);

  // Ethereum
  static const Color ethIcon            = Color(0xFF627EEA);
  static const Color ethIconBg          = Color(0xFFEFF2FE);
  static const Color ethIconBorder      = Color(0xFFCDD5FA);

  // Tether
  static const Color usdtIcon           = Color(0xFF26A17B);
  static const Color usdtIconBg         = Color(0xFFE8F8F3);
  static const Color usdtIconBorder     = Color(0xFFB2E8D6);

  // Solana
  static const Color solIcon            = Color(0xFF9945FF);
  static const Color solIconBg          = Color(0xFFF5EEFF);
  static const Color solIconBorder      = Color(0xFFDBC6FF);

  // BNB
  static const Color bnbIcon            = Color(0xFFF0B90B);
  static const Color bnbIconBg          = Color(0xFFFEF8E1);
  static const Color bnbIconBorder      = Color(0xFFFAE099);

  // Default / fallback
  static const Color defaultCoinIcon    = Color(0xFF718096);
  static const Color defaultCoinBg      = Color(0xFFEDF2F7);
  static const Color defaultCoinBorder  = Color(0xFFCBD5E0);

  // ─── Search & Chips ────────────────────────────────────────────────────────
  static const Color searchBackground   = Color(0xFFFFFFFF);
  static const Color searchBorder       = Color(0xFFDDE4F5);
  static const Color searchIcon         = Color(0xFF90A0B7);

  static const Color activeChipBg       = Color(0xFF1A202C);
  static const Color inactiveChipBg     = Color(0xFFFFFFFF);
  static const Color chipBorder         = Color(0xFFDDE4F5);

  // ─── Stat Label Row ────────────────────────────────────────────────────────
  static const Color statLabelBg        = Color(0xFFF5F7FF);
  static const Color statLabelBorder    = Color(0xFFE8EEFF);
  static const Color statLabelText      = Color(0xFF90A0B7);

  // ─── Misc ──────────────────────────────────────────────────────────────────
  static const Color divider            = Color(0xFFF0F4FF);
  static const Color refreshSpinner     = Color(0xFF5A72CB);
  static const Color primaryButton      = Color(0xFF5A72CB);
}
