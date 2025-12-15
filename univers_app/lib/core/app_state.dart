import 'package:flutter/material.dart';
import 'package:univers_app/core/themes.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univers_app/models/univers_model.dart';
import 'package:univers_app/models/univers_asset_model.dart';

class AppState extends ChangeNotifier {
  AppState();

  factory AppState.of(BuildContext context, {bool listen = true}) {
    return Provider.of<AppState>(context, listen: listen);
  }

  ThemeData _theme = lightTheme;

  ThemeData get theme {
    return _theme;
  }

  void changeTheme(ThemeData theme) {
    _theme = theme;
    notifyListeners();
  }

  String _selectedLanguage = 'en';

  String get selectedLanguage {
    return _selectedLanguage;
  }

  void setLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  bool _backgroundMusicEnabled = true;

  bool get backgroundMusicEnabled {
    return _backgroundMusicEnabled;
  }

  void setBackgroundMusicEnabled(bool enabled) {
    _backgroundMusicEnabled = enabled;
    notifyListeners();
  }

  bool _textToSpeechEnabled = true;

  bool get textToSpeechEnabled {
    return _textToSpeechEnabled;
  }

  void setTextToSpeechEnabled(bool enabled) {
    _textToSpeechEnabled = enabled;
    notifyListeners();
  }

  List<String> _supportedLanguages = [
    'fr',
    'en',
    'de',
    'es'
  ]; // Default, will be updated dynamically

  List<String> get supportedLanguages {
    return _supportedLanguages;
  }

  final Map<String, String> languageNames = {
    'fr': 'Français',
    'en': 'English',
    'de': 'Deutsch',
    'es': 'Español',
    'it': 'Italiano',
  };

  void updateSupportedLanguages(List<String> languages) {
    _supportedLanguages = languages;
    notifyListeners();
  }

  void collectSupportedLanguages(
      List<UniversModel> universes, List<UniversAssetModel> assets) {
    final Set<String> languages = {
      'fr',
      'en',
      'de',
      'es'
    }; // Always include defaults

    for (final universe in universes) {
      languages.addAll(universe.translations.keys);
    }

    for (final asset in assets) {
      languages.addAll(asset.translations.keys);
    }

    updateSupportedLanguages(languages.toList()..sort());
  }

  // Supabase client
  SupabaseClient get supabase => Supabase.instance.client;
}
