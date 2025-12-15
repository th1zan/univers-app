// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get soundSection => 'Sound';

  @override
  String get backgroundMusic => 'Background Music';

  @override
  String get textToSpeech => 'Text to Speech';

  @override
  String get languageSection => 'Language';

  @override
  String get guidedAccessSection => 'Guided Access';

  @override
  String get loading => 'Loading...';

  @override
  String get errorOccurred => 'Oops! An error occurred';

  @override
  String get noImagesAvailable => 'No images available';

  @override
  String get untitled => 'Untitled';

  @override
  String get iosLockInstructions =>
      '**Lock screen for kids (iPhone)**\n\n1. Settings → Accessibility\n2. Guided Access (Learning section)\n3. Turn on Guided Access\n4. Set a passcode (Passcode Settings)\n5. (Recommended) Accessibility Shortcut → check Guided Access\n\nTo lock in the game:\n• Open the game\n• Triple-click the side button\n• Tap Start\n\nTo exit: triple-click → enter code → End';

  @override
  String get androidLockInstructions =>
      '**Lock screen for kids (Android)**\n\n1. Settings → Security & privacy → More security → App pinning\n   (or search \"Pin\")\n2. Turn on and enable \"Ask for PIN before unpinning\"\n\nTo lock in the game:\n• Open the game\n• Tap recent apps button (square or swipe)\n• Tap game icon at top → Pin\n\nTo exit: hold Overview + Power → enter PIN';
}
