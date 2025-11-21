import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  // Déterminer le type d'appareil
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  // Obtenir la taille de l'écran
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Padding responsive
  static EdgeInsets getPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  static EdgeInsets getHorizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32.0);
    } else {
      return const EdgeInsets.symmetric(horizontal: 48.0);
    }
  }

  static EdgeInsets getVerticalPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(vertical: 16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(vertical: 24.0);
    } else {
      return const EdgeInsets.symmetric(vertical: 32.0);
    }
  }

  // Tailles de police responsive
  static double getTitleFontSize(BuildContext context) {
    if (isMobile(context)) {
      return 24.0;
    } else if (isTablet(context)) {
      return 28.0;
    } else {
      return 32.0;
    }
  }

  static double getBodyFontSize(BuildContext context) {
    if (isMobile(context)) {
      return 14.0;
    } else if (isTablet(context)) {
      return 16.0;
    } else {
      return 18.0;
    }
  }

  static double getSmallFontSize(BuildContext context) {
    if (isMobile(context)) {
      return 12.0;
    } else if (isTablet(context)) {
      return 14.0;
    } else {
      return 16.0;
    }
  }

  // Tailles d'icônes responsive
  static double getIconSize(BuildContext context) {
    if (isMobile(context)) {
      return 24.0;
    } else if (isTablet(context)) {
      return 28.0;
    } else {
      return 32.0;
    }
  }

  // Tailles de boutons responsive
  static double getButtonHeight(BuildContext context) {
    if (isMobile(context)) {
      return 48.0;
    } else if (isTablet(context)) {
      return 52.0;
    } else {
      return 56.0;
    }
  }

  // Espacement responsive
  static double getSpacing(BuildContext context) {
    if (isMobile(context)) {
      return 8.0;
    } else if (isTablet(context)) {
      return 12.0;
    } else {
      return 16.0;
    }
  }

  // Largeur maximale pour le contenu centré (desktop)
  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 1200.0;
    }
    return double.infinity;
  }
}


