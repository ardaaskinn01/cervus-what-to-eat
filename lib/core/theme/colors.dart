import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - More sophisticated palette
  static const Color primary = Color(0xFFFF6B35);
  static const Color secondary = Color(0xFF2EC4B6);
  static const Color accent = Color(0xFF4361EE);
  static const Color error = Color(0xFFE63946);

  // Surfaces & Backgrounds - Using soft grey/blue undertones
  static const Color surfaceLight = Color(0xFFF9FBFF); // Very light blue-ish white
  static const Color surfaceDark = Color(0xFF0F141E); // Deep navy dark
  
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1B2431); // Soft navy blue for cards

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1E293B); // Slate 800
  static const Color textPrimaryDark = Color(0xFFF1F5F9); // Slate 100
  
  static const Color textSecondary = Color(0xFF64748B); // Slate 500

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
