/// Design tokens for MBDIM mobile app
/// Colors, typography, spacing, radii, elevation, shadows
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFF0B1115); // very dark charcoal
  static const surface = Color(0xFF0F1720); // slightly lighter
  static const cardElevated = Color(0xFF12171C);
  static const accentGreen = Color(0xFF0F9D58);
  // Accent green light (kpi highlight) as per design tokens
  static const accentGreenLight = Color(0xFF66FFA6);
  static const kpiHighlight = Color(0xFF66FFA6);
  static const accentOrange = Color(0xFFF59E0B);
  static const mutedText = Color(0xFF9AA5AD);
  static const primaryText = Color(0xFFE6EEF3);
  static const secondaryText = Color(0xFFB7C2C8);
  static const warning = Color(0xFFF59E0B);
  static const success = Color(0xFF16A34A);
  static const shadow = Color.fromRGBO(0, 0, 0, 0.5);

  // New cyan/teal accent colors inspired by reference design
  static const primaryCyan = Color(0xFF00D4FF); // Bright cyan
  static const primaryTeal = Color(0xFF14B8A6); // Teal accent
  static const secondaryCyan = Color(0xFF06B6D4); // Secondary cyan
  static const darkSurface = Color(0xFF071014); // Dark surface for consistency
  static const inputBackground = Color(0xFF0F1A1C); // Input field background
}

class AppTypography {
  // Hero/heading styles inspired by reference design
  static TextStyle get heroTitle => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryText,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static TextStyle get heroTitleAccent => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryCyan,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static TextStyle get title => GoogleFonts.inter(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
    height: 1.2,
  );

  static TextStyle get subtitle => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.secondaryText,
    height: 1.3,
  );

  static TextStyle get kpiNumber => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.kpiHighlight,
    height: 1.1,
  );

  static TextStyle get kpiNumberGreen => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.accentGreen,
    height: 1.1,
  );

  static TextStyle get sectionHeading => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    height: 1.3,
  );

  static TextStyle get cardTitle => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    height: 1.3,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
    height: 1.4,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
    height: 1.4,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedText,
    height: 1.3,
  );

  static TextStyle get badge => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.cardElevated,
    height: 1.2,
  );

  static TextStyle get button => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    height: 1.2,
  );

  static TextStyle get buttonLarge => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    height: 1.2,
  );
}

class AppSpacing {
  static const double base = 8;
  static const double cardPadding = 16;
  static const double edge = 16;
}

class AppRadii {
  static const double card = 14;
  static const double small = 8;
  static const double button = 12;
}

class AppElevation {
  static const double blur = 16;
  static const double offsetY = 6;
  static const Color color = AppColors.shadow;
}
