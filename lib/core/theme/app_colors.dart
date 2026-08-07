import 'package:flutter/material.dart';

abstract class AppColors {
  // Cinema Dark Palette (Default)
  static const Color darkBackground = Color(0xFF0B0E14);
  static const Color darkSurface = Color(0xFF151C28);
  static const Color darkSurfaceVariant = Color(0xFF1F2937);
  static const Color darkCard = Color(0xFF1E2634);

  // Cinema Light Palette
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Accents & Brand Colors
  static const Color primaryRed = Color(0xFFE50914);
  static const Color primaryRedHover = Color(0xFFB81D24);
  static const Color accentGold = Color(0xFFFFC107);
  static const Color accentGoldLight = Color(0xFFFFD54F);

  // Neutral Text & Icons - Dark Mode
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Neutral Text & Icons - Light Mode
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Functional Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Cinematic Noir Tokens (Stitch MCP Design System)
  static const Color neonCoral = Color(0xFFFF5070);
  static const Color neonCoralGlow = Color(0xFFFF2A5F);
  static const Color glassSurface = Color(0x0DFFFFFF); // rgba(255,255,255,0.05)
  static const Color glassInputSurface = Color(0x1AFFFFFF); // rgba(255,255,255,0.1)
  static const Color glassBorder = Color(0x1AFFFFFF); // rgba(255,255,255,0.1)
}

