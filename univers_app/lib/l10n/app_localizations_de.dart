// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get soundSection => 'Ton';

  @override
  String get backgroundMusic => 'Hintergrundmusik';

  @override
  String get textToSpeech => 'Sprachausgabe';

  @override
  String get languageSection => 'Sprache';

  @override
  String get guidedAccessSection => 'Geführter Zugriff';

  @override
  String get loading => 'Laden...';

  @override
  String get errorOccurred => 'Hoppla! Ein Fehler ist aufgetreten';

  @override
  String get noImagesAvailable => 'Keine Bilder verfügbar';

  @override
  String get untitled => 'Ohne Titel';

  @override
  String get iosLockInstructions =>
      '**Bildschirm für Kinder sperren (iPhone)**\n\n1. Einstellungen → Bedienungshilfen\n2. Geführter Zugriff (Lernen)\n3. Aktivieren\n4. Code festlegen\n5. (Empfohlen) Kurzbefehl → Geführter Zugriff auswählen\n\nSpiel sperren:\n• Spiel öffnen\n• 3x schnell Seitentaste drücken\n• Start tippen\n\nBeenden: 3x Seitentaste → Code → Ende';

  @override
  String get androidLockInstructions =>
      '**Bildschirm für Kinder sperren (Android)**\n\n1. Einstellungen → Sicherheit & Datenschutz → Weitere Sicherheit → App-Pinning\n   (oder Pinnen suchen)\n2. Aktivieren + PIN vor Entpinnen verlangen anhaken\n\nSpiel sperren:\n• Spiel öffnen\n• Taste Zuletzt genutzte Apps (Quadrat)\n• Symbol oben antippen → Pinnen\n\nBeenden: Übersicht + Power gedrückt halten → PIN eingeben';
}
