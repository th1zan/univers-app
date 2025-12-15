/// Constantes globales de l'application Univers.
/// Centralise les URLs, clés et configurations.
library;

/// Constantes de l'API Supabase.
abstract class ApiConstants {
  ApiConstants._();

  /// URL de base Supabase (via variable d'environnement ou défaut).
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://nazvebulhqxnieyeqnxe.supabase.co',
  );

  /// Clé anonyme Supabase (via variable d'environnement ou défaut).
  /// ⚠️ En production, utiliser --dart-define pour injecter la vraie clé.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5henZlYnVsaHF4bmlleWVxbnhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQwNzY5NTQsImV4cCI6MjA3OTY1Mjk1NH0.DlpNXu9VTCwd2D1mCQlI4k08BIiI9Rf2OGzaL6L1evA',
  );

  /// URL de base du stockage Supabase.
  static const String storageBaseUrl =
      '$supabaseUrl/storage/v1/object/public/univers';

  /// Construit l'URL complète d'un fichier dans le storage.
  static String getStorageUrl(String slug, String filename) {
    final encodedSlug = Uri.encodeComponent(slug);
    final encodedFilename = Uri.encodeComponent(filename);
    return '$storageBaseUrl/$encodedSlug/$encodedFilename';
  }
}

/// Constantes de l'application.
abstract class AppConstants {
  AppConstants._();

  /// Langues supportées par l'application.
  static const List<String> supportedLanguages = [
    'fr',
    'en',
    'de',
    'es',
    'it',
    'pt',
    'nl',
    'pl',
    'ru',
    'zh',
    'ja',
    'ar',
  ];

  /// Langue par défaut.
  static const String defaultLanguage = 'fr';

  /// Taille minimale des hitbox pour les enfants (en dp).
  static const double minHitboxSize = 80.0;

  /// Durée d'animation par défaut.
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
}
