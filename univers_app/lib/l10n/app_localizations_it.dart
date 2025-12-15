// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get soundSection => 'Suono';

  @override
  String get backgroundMusic => 'Musica di sottofondo';

  @override
  String get textToSpeech => 'Lettura vocale';

  @override
  String get languageSection => 'Lingua';

  @override
  String get guidedAccessSection => 'Accesso guidato';

  @override
  String get loading => 'Caricamento...';

  @override
  String get errorOccurred => 'Ops! Si è verificato un errore';

  @override
  String get noImagesAvailable => 'Nessuna immagine disponibile';

  @override
  String get untitled => 'Senza titolo';

  @override
  String get iosLockInstructions =>
      '**Bloccare schermo per bambini (iPhone)**\n\n1. Impostazioni → Accessibilità\n2. Accesso guidato (Apprendimento)\n3. Attivare Accesso guidato\n4. Impostare codice\n5. (Consigliato) Scorciatoia → selezionare Accesso guidato\n\nBloccare nel gioco:\n• Apri il gioco\n• Premi 3 volte rapido il tasto laterale\n• Tocca Inizia\n\nUscire: triplo clic → codice → Fine';

  @override
  String get androidLockInstructions =>
      '**Bloccare schermo per bambini (Android)**\n\n1. Impostazioni → Sicurezza e privacy → Altre impostazioni → Fissaggio app\n   (o cercare «Fissa»)\n2. Attivare + spuntare «Chiedi PIN prima di sganciare»\n\nBloccare nel gioco:\n• Apri il gioco\n• Tasto app recenti (quadrato)\n• Tocca icona in alto → Fissa\n\nUscire: tenere premuto Panoramica + Accensione → inserire PIN';
}
