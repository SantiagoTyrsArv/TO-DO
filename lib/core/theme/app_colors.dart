import 'package:flutter/material.dart';

/// Central color palette for the To-Do app.
class AppColors {
  AppColors._();

  // ── Primary ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF35C082);
  static const Color primaryLight = Color(0xFFEAFAF2);
  static const Color primaryMid = Color(0xFFB3EDD4);

  // ── Background / Surface ─────────────────────────────────────────────────
  static const Color background = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color scaffold = Color(0xFFF8F9FB);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textMedium = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFB0B7C3);

  // ── Status ───────────────────────────────────────────────────────────────
  static const Color danger = Color(0xFFFF5252);
  static const Color dangerLight = Color(0xFFFFEBEB);

  // ── Badge pastel palette (for time badges) ───────────────────────────────
  static const Color badgeOrange = Color(0xFFFFF3E0);
  static const Color badgeOrangeText = Color(0xFFFF9800);
  static const Color badgeGreen = Color(0xFFEAFAF2);
  static const Color badgeGreenText = Color(0xFF35C082);
  static const Color badgePurple = Color(0xFFF3E8FF);
  static const Color badgePurpleText = Color(0xFF9C27B0);
  static const Color badgeBlue = Color(0xFFE3F2FD);
  static const Color badgeBlueText = Color(0xFF2196F3);

  // ── Shadow ───────────────────────────────────────────────────────────────
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];
}
