import 'package:flutter/material.dart';
import 'package:univers_app/core/constants.dart';

/// Couleurs de l'application Univers.
/// Palette adaptée aux enfants de 3-8 ans : couleurs vives mais douces.
abstract class AppColors {
  AppColors._();

  // Couleurs primaires
  static const Color primary = Color(0xFFFF6B9D); // Rose bonbon
  static const Color secondary = Color(0xFF4ECDC4); // Turquoise doux
  static const Color tertiary = Color(0xFFFFD93D); // Jaune soleil

  // Fonds
  static const Color background = Color(0xFFF5E6D3); // Crème chaude (slideshow)
  static const Color surface = Color(0xFFFFF8E7); // Crème vanille
  static const Color surfaceLight = Color(0xFFFFFFF8); // Blanc cassé

  // Dégradés pour les boutons
  static const List<Color> primaryGradient = [
    Color(0xFFFF6B9D),
    Color(0xFFFF8CAB),
  ];
  static const List<Color> secondaryGradient = [
    Color(0xFF4ECDC4),
    Color(0xFF6EE7DF),
  ];
  static const List<Color> neutralGradient = [
    Colors.white,
    Color(0xFFF5F5F5),
  ];

  // Couleurs de texte
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textOnDark = Colors.white;
  static const Color textOnPrimary = Colors.white;

  // États
  static const Color error = Color(0xFFFF6B6B); // Rouge doux
  static const Color success = Color(0xFF48BB78); // Vert doux
  static const Color warning = Color(0xFFECC94B); // Jaune doux

  // Ombres
  static const Color shadowColor = Colors.black26;
}

/// Thèmes de l'application Univers.
/// Optimisés pour les enfants : gros boutons, hitbox ≥ 80dp, coins arrondis.
abstract class AppThemes {
  AppThemes._();

  /// Thème clair (principal)
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Palette de couleurs
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.surface,
        error: AppColors.error,
      ),

      // Typographie adaptée aux enfants (arrondie, grande)
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 56.0,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          height: 1.2,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 44.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 36.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: AppColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: AppColors.textPrimary,
        ),
      ),

      // Boutons gros et arrondis - hitbox ≥ 80dp pour les enfants
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          minimumSize: Size(
            AppConstants.minHitboxSize,
            AppConstants.minHitboxSize,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
          elevation: 8.0,
          shadowColor: AppColors.shadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          textStyle: const TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // IconButton avec hitbox ≥ 80dp
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: Size(
            AppConstants.minHitboxSize,
            AppConstants.minHitboxSize,
          ),
          padding: const EdgeInsets.all(16.0),
        ),
      ),

      // Cartes arrondies avec ombre douce
      cardTheme: const CardThemeData(
        elevation: 6.0,
        shadowColor: AppColors.shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28.0)),
        ),
      ),

      // Inputs (si utilisés)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(
            color: AppColors.secondary,
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 3.0,
          ),
        ),
      ),

      // Icônes grandes
      iconTheme: const IconThemeData(
        size: 32.0,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// Thème sombre
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
      ),

      // Boutons avec hitbox ≥ 80dp
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(
            AppConstants.minHitboxSize,
            AppConstants.minHitboxSize,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: Size(
            AppConstants.minHitboxSize,
            AppConstants.minHitboxSize,
          ),
        ),
      ),
    );
  }
}

/// Ancien export pour compatibilité (à supprimer progressivement)
@Deprecated('Utiliser AppThemes.light à la place')
final ThemeData lightTheme = AppThemes.light;
