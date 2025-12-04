import 'package:flutter/material.dart';
import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
final ThemeData lightTheme = ThemeData(
  // Palette de couleurs enfantine et joyeuse
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFFF6B9D), // Rose bonbon
    brightness: Brightness.light,
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    primary: const Color(0xFFFF6B9D), // Rose vif
    secondary: const Color(0xFF4ECDC4), // Turquoise doux
    tertiary: const Color(0xFFFFD93D), // Jaune soleil
     surface: const Color(0xFFFFF8E7), // Crème vanille
    error: const Color(0xFFFF6B6B), // Rouge doux
  ),

  // Typographie adaptée aux enfants (arrondie, grande)
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 56.0,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.5,
      height: 1.2,
    ),
    displayMedium: TextStyle(
      fontSize: 44.0,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
    displaySmall: TextStyle(
      fontSize: 36.0,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
    headlineLarge: TextStyle(
      fontSize: 32.0,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: TextStyle(
      fontSize: 28.0,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
  ),

  // Boutons gros et arrondis
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFF6B9D),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
      elevation: 8.0,
      shadowColor: Colors.black26,
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

  // Cartes arrondies avec ombre douce
  cardTheme: const CardThemeData(
    elevation: 6.0,
    shadowColor: Color(0xFF000000),
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
        color: Color(0xFFFF6B9D),
        width: 2.0,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: const BorderSide(
        color: Color(0xFF4ECDC4),
        width: 2.0,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20.0),
      borderSide: const BorderSide(
        color: Color(0xFFFF6B9D),
        width: 3.0,
      ),
    ),
  ),

  // Icônes grandes
  iconTheme: const IconThemeData(
    size: 32.0,
    color: Color(0xFF2D3748),
  ),
);
