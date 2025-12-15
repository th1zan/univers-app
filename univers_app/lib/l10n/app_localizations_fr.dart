// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get soundSection => 'Son';

  @override
  String get backgroundMusic => 'Musique de fond';

  @override
  String get textToSpeech => 'Lecture vocale';

  @override
  String get languageSection => 'Langue';

  @override
  String get guidedAccessSection => 'Verrouillage guidé';

  @override
  String get loading => 'Chargement...';

  @override
  String get errorOccurred => 'Oups ! Une erreur est survenue';

  @override
  String get noImagesAvailable => 'Aucune image disponible';

  @override
  String get untitled => 'Sans titre';

  @override
  String get iosLockInstructions =>
      '**Verrouiller l\'écran pour les enfants (iPhone)**\n\n1. Réglages → Accessibilité\n2. Accès guidé (en bas, section Apprentissage)\n3. Activer Accès guidé\n4. Définir un code (Réglages du code)\n5. (Conseillé) Raccourci d\'accessibilité → cocher Accès guidé\n\nPour bloquer dans le jeu :\n• Lancer le jeu\n• Appuyer 3 fois rapidement sur le bouton latéral\n• Toucher Démarrer\n\nPour quitter : triple-clic → code → Fin';

  @override
  String get androidLockInstructions =>
      '**Verrouiller l\'écran pour les enfants (Android)**\n\n1. Paramètres → Sécurité et confidentialité → Plus de sécurité → Épinglage d\'application\n   (ou chercher « Épingler »)\n2. Activer et cocher « Demander le code avant de détacher »\n\nPour bloquer dans le jeu :\n• Ouvrir le jeu\n• Appuyer sur le bouton carré (ou glisser pour les apps récentes)\n• Toucher l\'icône du jeu en haut → Épingler\n\nPour quitter : maintenir Aperçu + Power → saisir le code';
}
