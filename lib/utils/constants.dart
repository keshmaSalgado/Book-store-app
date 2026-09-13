import 'package:flutter/material.dart';

class AppConstants {
  // Application Information
  static const String appName = 'BookVerse';
  static const String appTagline = 'Your Books, Anywhere';

  // Theme Colors - Elegant Indigo & Warm Amber Palette
  static const Color primaryColor = Color(0xFF1E293B);      // Deep Slate Navy
  static const Color primaryLight = Color(0xFF334155);
  static const Color accentColor = Color(0xFFF59E0B);       // Warm Amber / Book Gold
  static const Color accentLight = Color(0xFFFEF3C7);
  static const Color backgroundColor = Color(0xFFF8FAFC);   // Crisp Off-White
  static const Color cardColor = Colors.white;
  static const Color surfaceColor = Color(0xFFF1F5F9);

  // Status Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color dangerColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Border & Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Placeholder Book Image (Fallback)
  static const String fallbackBookCover = 
      'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&w=600&q=80';
}
