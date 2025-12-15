import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Service singleton pour la synthèse vocale (Text-to-Speech).
/// Optimisé pour les enfants avec des voix naturelles et un débit lent.
class TtsService {
  // Singleton pattern
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  FlutterTts? _tts;
  bool _isInitialized = false;
  String _currentLanguage = 'fr';

  /// Voix préférées par langue pour un son plus naturel
  static const Map<String, String> preferredVoices = {
    'fr': 'Amélie',
    'en': 'Samantha',
    'es': 'Paulina',
    'de': 'Anna',
    'it': 'Alice',
  };

  /// Configuration par défaut pour les enfants
  static const double defaultSpeechRate = 0.4; // Lent pour les enfants
  static const double defaultPitch = 1.0; // Hauteur normale
  static const double defaultVolume = 1.0; // Volume maximum

  /// Indique si le service est initialisé
  bool get isInitialized => _isInitialized;

  /// Langue actuellement configurée
  String get currentLanguage => _currentLanguage;

  /// Initialise le service TTS avec la langue spécifiée.
  ///
  /// [language] - Code de langue (fr, en, es, de, it)
  Future<bool> initialize({String language = 'fr'}) async {
    try {
      _tts = FlutterTts();

      await _tts?.setLanguage(language);
      await _tts?.setSpeechRate(defaultSpeechRate);
      await _tts?.setPitch(defaultPitch);
      await _tts?.setVolume(defaultVolume);

      // Essayer de définir une voix naturelle
      await _setPreferredVoice(language);

      _currentLanguage = language;
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('TtsService: Erreur initialisation - $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Change la langue du TTS.
  Future<void> setLanguage(String language) async {
    if (!_isInitialized) {
      await initialize(language: language);
      return;
    }

    try {
      await _tts?.setLanguage(language);
      await _setPreferredVoice(language);
      _currentLanguage = language;
    } catch (e) {
      debugPrint('TtsService: Erreur changement langue - $e');
    }
  }

  /// Configure la voix préférée pour la langue donnée.
  Future<void> _setPreferredVoice(String language) async {
    final voiceName = preferredVoices[language];
    if (voiceName != null) {
      try {
        await _tts?.setVoice({'name': voiceName, 'locale': language});
      } catch (e) {
        // Voix non disponible, utiliser la voix par défaut
        debugPrint('TtsService: Voix $voiceName non disponible');
      }
    }
  }

  /// Prononce le texte spécifié.
  ///
  /// [text] - Texte à prononcer
  /// [language] - Langue optionnelle (utilise la langue courante si non spécifié)
  Future<void> speak(String text, {String? language}) async {
    if (!_isInitialized) {
      await initialize(language: language ?? 'fr');
    }

    if (text.isEmpty) return;

    try {
      // Changer de langue si nécessaire
      if (language != null && language != _currentLanguage) {
        await setLanguage(language);
      }

      await _tts?.speak(text);
    } catch (e) {
      debugPrint('TtsService: Erreur lecture - $e');
    }
  }

  /// Arrête la lecture en cours.
  Future<void> stop() async {
    try {
      await _tts?.stop();
    } catch (e) {
      debugPrint('TtsService: Erreur arrêt - $e');
    }
  }

  /// Définit le débit de parole (0.0 à 1.0).
  Future<void> setSpeechRate(double rate) async {
    try {
      await _tts?.setSpeechRate(rate.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('TtsService: Erreur débit - $e');
    }
  }

  /// Définit le volume (0.0 à 1.0).
  Future<void> setVolume(double volume) async {
    try {
      await _tts?.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('TtsService: Erreur volume - $e');
    }
  }

  /// Libère les ressources. À appeler dans dispose() du widget parent.
  Future<void> dispose() async {
    await stop();
    _isInitialized = false;
  }
}
