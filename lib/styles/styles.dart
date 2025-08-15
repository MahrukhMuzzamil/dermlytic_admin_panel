import 'package:flutter/material.dart';

const double defaultPadding = 24.0;
const double defaultDrawerWidth = 300.0;

// Modern Color Palette - Professional & Contemporary
const Color primaryColor = Color(0xFF6366F1); // Modern indigo
const Color primaryLight = Color(0xFF818CF8); // Light indigo
const Color primaryDark = Color(0xFF4F46E5); // Dark indigo

const Color secondaryColor = Color(0xFF06B6D4); // Modern cyan
const Color secondaryLight = Color(0xFF67E8F9); // Light cyan
const Color secondaryDark = Color(0xFF0891B2); // Dark cyan

const Color accentColor = Color(0xFF8B5CF6); // Purple accent
const Color accentLight = Color(0xFFA78BFA); // Light purple
const Color accentDark = Color(0xFF7C3AED); // Dark purple

const Color successColor = Color(0xFF10B981); // Modern green
const Color warningColor = Color(0xFFF59E0B); // Modern amber
const Color errorColor = Color(0xFFEF4444); // Modern red
const Color infoColor = Color(0xFF3B82F6); // Modern blue

// Neutral colors
const Color neutralWhite = Color(0xFFFFFFFF);
const Color neutralLight = Color(0xFFF8FAFC); // Very light gray
const Color neutralMedium = Color(0xFFE2E8F0); // Medium gray
const Color neutralDark = Color(0xFF64748B); // Dark gray
const Color neutralBlack = Color(0xFF0F172A); // Almost black

// Background colors
const Color backgroundPrimary = Color(0xFFFFFFFF);
const Color backgroundSecondary = Color(0xFFF1F5F9);
const Color backgroundTertiary = Color(0xFFF8FAFC);

// Legacy colors for backward compatibility
const Color tertiaryColor = Color(0xFFF8FAFC);
const Color lightGrey = Color(0xFF9CADC1);
const Color disabledColor = Color(0xFF94A3B8);

// Gradients
const LinearGradient primaryGradient = LinearGradient(
  colors: [primaryColor, primaryLight],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient secondaryGradient = LinearGradient(
  colors: [secondaryColor, secondaryLight],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient accentGradient = LinearGradient(
  colors: [accentColor, accentLight],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Modern Typography Scale
const headerFontStyle = TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.w700,
  color: neutralBlack,
  letterSpacing: -0.5,
);

const headingFontStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w600,
  color: neutralBlack,
  letterSpacing: -0.3,
);

const subHeadingFontStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: neutralBlack,
  letterSpacing: -0.2,
  overflow: TextOverflow.ellipsis
);

const bodyFontStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: neutralDark,
  letterSpacing: 0.1,
);

const bodyFontStyle2 = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w400,
  color: neutralWhite,
  letterSpacing: 0.1,
);

const bodyFontStyleBold = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w600,
  color: neutralBlack,
  letterSpacing: 0.1,
);

const captionFontStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  color: neutralDark,
  letterSpacing: 0.2,
);

const smallFontStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: neutralDark,
  letterSpacing: 0.3,
);

// Shadows
const BoxShadow cardShadow = BoxShadow(
  color: Color(0x0F000000),
  offset: Offset(0, 4),
  blurRadius: 16,
  spreadRadius: 0,
);

const BoxShadow elevatedShadow = BoxShadow(
  color: Color(0x1A000000),
  offset: Offset(0, 8),
  blurRadius: 24,
  spreadRadius: 0,
);

const BoxShadow subtleShadow = BoxShadow(
  color: Color(0x08000000),
  offset: Offset(0, 2),
  blurRadius: 8,
  spreadRadius: 0,
);

// Border Radius
const BorderRadius cardRadius = BorderRadius.all(Radius.circular(16));
const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(12));
const BorderRadius inputRadius = BorderRadius.all(Radius.circular(10));

// Spacing
const double spacingXS = 4.0;
const double spacingS = 8.0;
const double spacingM = 16.0;
const double spacingL = 24.0;
const double spacingXL = 32.0;
const double spacingXXL = 48.0;

extension ColorShade on Color {
  Color darken([double amount = .2]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color lighten([double amount = .2]) {
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  Color withOpacity(double opacity) {
    return Color.fromRGBO(red, green, blue, opacity);
  }
}