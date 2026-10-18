import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryColor   = Color(0xFF1BC5BD);
  static const Color primaryLight   = Color(0xFFE3FAF8);   // teal tint background
  static const Color primaryDark    = Color(0xFF13958F);   // pressed/darker teal
  static const Color primaryBorder  = Color(0xFFB2EBE8);   // teal border
  static const Color primaryOnColor = Color(0xFFFFFFFF);   // text/icons on teal bg

  // ─── Scaffold & Surface ────────────────────────────────────────────────────
  static const Color scaffoldBackground = Color(0xFFF0F4FF);
  static const Color surfaceBackground  = Color(0xFFFAFCFF);

  // ─── Card ─────────────────────────────────────────────────────────────────
  static const Color cardBackground    = Color(0xFFFFFFFF);
  static const Color cardBorder        = Color(0xFFE8EEFF);
  static const Color cardShadowPrimary = Color(0x166B84D6);
  static const Color cardShadowSecond  = Color(0x0A000000);

  // ─── Gain / Loss ──────────────────────────────────────────────────────────
  static const Color gainAccent = Color(0xFF00C9A7);
  static const Color gainLight  = Color(0xFFE6FAF7);
  static const Color gainText   = Color(0xFF00A085);

  static const Color lossAccent = Color(0xFFFF6B8A);
  static const Color lossLight  = Color(0xFFFFEEF3);
  static const Color lossText   = Color(0xFFD94068);

  static const Color neutralAccent = Color(0xFFB0BEC5);
  static const Color neutralLight  = Color(0xFFF0F4F8);
  static const Color neutralText   = Color(0xFF718096);

  // ─── Typography ────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textMuted     = Color(0xFF90A0B7);
  static const Color textLight     = Color(0xFFFFFFFF);

  // ─── Rank Badge ────────────────────────────────────────────────────────────
  static const Color rankBadgeBg     = Color(0xFFEEF1FF);
  static const Color rankBadgeText   = Color(0xFF5A72CB);
  static const Color rankBadgeBorder = Color(0xFFD0D8F8);

  // ─── Coin-Specific Icon Colors ─────────────────────────────────────────────
  static const Color btcIcon        = Color(0xFFF7931A);
  static const Color btcIconBg      = Color(0xFFFFF5E6);
  static const Color btcIconBorder  = Color(0xFFFFDFA5);

  static const Color ethIcon        = Color(0xFF627EEA);
  static const Color ethIconBg      = Color(0xFFEFF2FE);
  static const Color ethIconBorder  = Color(0xFFCDD5FA);

  static const Color usdtIcon       = Color(0xFF26A17B);
  static const Color usdtIconBg     = Color(0xFFE8F8F3);
  static const Color usdtIconBorder = Color(0xFFB2E8D6);

  static const Color solIcon        = Color(0xFF9945FF);
  static const Color solIconBg      = Color(0xFFF5EEFF);
  static const Color solIconBorder  = Color(0xFFDBC6FF);

  static const Color bnbIcon        = Color(0xFFF0B90B);
  static const Color bnbIconBg      = Color(0xFFFEF8E1);
  static const Color bnbIconBorder  = Color(0xFFFAE099);

  static const Color defaultCoinIcon   = Color(0xFF718096);
  static const Color defaultCoinBg     = Color(0xFFEDF2F7);
  static const Color defaultCoinBorder = Color(0xFFCBD5E0);

  // ─── Search & Chips ────────────────────────────────────────────────────────
  static const Color searchBackground = Color(0xFFFFFFFF);
  static const Color searchBorder     = Color(0xFFDDE4F5);
  static const Color searchIcon       = Color(0xFF90A0B7);

  static const Color activeChipBg  = Color(0xFF1A202C);
  static const Color inactiveChipBg = Color(0xFFFFFFFF);
  static const Color chipBorder    = Color(0xFFDDE4F5);

  // ─── Stat Label Chips ──────────────────────────────────────────────────────
  static const Color statLabelBg     = Color(0xFFF5F7FF);
  static const Color statLabelBorder = Color(0xFFE8EEFF);
  static const Color statLabelText   = Color(0xFF90A0B7);

  // ─── Detail Screen Specific ────────────────────────────────────────────────
  /// Used for the detail stat section background panels
  static const Color detailStatBg        = Color(0xFFF5F7FF);
  static const Color detailStatBorder    = Color(0xFFE8EEFF);
  /// Used for the chart gradient fill (same as primary but computed in code with opacity)
  static const Color chartGradientTop    = Color(0x4D1BC5BD);  // primaryColor @ 30%
  static const Color chartGradientBottom = Color(0x001BC5BD);  // transparent teal
  /// Chart dot/indicator
  static const Color chartDotCenter  = Color(0xFF1BC5BD);
  static const Color chartDotBorder  = Color(0xFFFFFFFF);
  /// Price tooltip bubble
  static const Color tooltipBg       = Color(0xFF1BC5BD);
  static const Color tooltipText     = Color(0xFFFFFFFF);
  /// Selector item highlighted shadow
  static const Color selectorShadow  = Color(0x401BC5BD);
  /// Divider in detail stat section
  static const Color detailDivider   = Color(0xFFF0F4FF);

  // ─── Misc ──────────────────────────────────────────────────────────────────
  static const Color divider        = Color(0xFFF0F4FF);
  static const Color refreshSpinner = Color(0xFF1BC5BD);  // now uses primaryColor
  static const Color primaryButton  = Color(0xFF1BC5BD);  // now uses primaryColor

  // ─── Splash Screen (Light Mode) ────────────────────────────────────────────
  static const Color splashBg        = Color(0xFFF0F4FF);  // same as scaffold
  static const Color splashLogoBg    = Color(0xFFFFFFFF);  // white card
  static const Color splashGlowOuter = Color(0x401BC5BD);  // teal glow ring
  static const Color splashRingColor = Color(0xFF1BC5BD);  // ring stroke

  static const Color skeletonBase      = Color(0xFFE4E9F7);
  static const Color skeletonHighlight = Color(0xFFF5F7FF);
}
