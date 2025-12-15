import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Service singleton pour gérer la musique de fond de l'application.
/// Encapsule toute la logique AudioPlayer pour un code plus propre.
class AudioService {
  // Singleton pattern
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  String? _currentUrl;

  /// Indique si la musique est en cours de lecture
  bool get isPlaying => _isPlaying;

  /// URL de la musique actuellement chargée
  String? get currentUrl => _currentUrl;

  /// Démarre la lecture de la musique de fond en boucle.
  ///
  /// [musicUrl] - URL complète du fichier MP3
  ///
  /// Retourne true si la lecture a démarré avec succès.
  Future<bool> playBackgroundMusic(String musicUrl) async {
    try {
      // Arrêter la musique précédente si elle existe
      await stop();

      _audioPlayer = AudioPlayer();
      await _audioPlayer?.play(UrlSource(musicUrl));
      await _audioPlayer?.setReleaseMode(ReleaseMode.loop);

      _isPlaying = true;
      _currentUrl = musicUrl;

      // Écouter les événements de fin pour mettre à jour l'état
      _audioPlayer?.onPlayerComplete.listen((_) {
        // Normalement ne devrait pas arriver en mode loop
        _isPlaying = false;
      });

      return true;
    } catch (e) {
      debugPrint('AudioService: Erreur lecture musique - $e');
      _isPlaying = false;
      return false;
    }
  }

  /// Met en pause la lecture sans libérer les ressources.
  Future<void> pause() async {
    try {
      await _audioPlayer?.pause();
      _isPlaying = false;
    } catch (e) {
      debugPrint('AudioService: Erreur pause - $e');
    }
  }

  /// Reprend la lecture après une pause.
  Future<void> resume() async {
    try {
      await _audioPlayer?.resume();
      _isPlaying = true;
    } catch (e) {
      debugPrint('AudioService: Erreur reprise - $e');
    }
  }

  /// Arrête complètement la lecture et libère les ressources.
  Future<void> stop() async {
    try {
      await _audioPlayer?.stop();
      await _audioPlayer?.dispose();
      _audioPlayer = null;
      _isPlaying = false;
      _currentUrl = null;
    } catch (e) {
      debugPrint('AudioService: Erreur arrêt - $e');
    }
  }

  /// Définit le volume (0.0 à 1.0).
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer?.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      debugPrint('AudioService: Erreur volume - $e');
    }
  }

  /// Active/désactive le mode muet.
  Future<void> setMuted(bool muted) async {
    await setVolume(muted ? 0.0 : 1.0);
  }

  /// Libère toutes les ressources. À appeler dans dispose() du widget parent.
  Future<void> dispose() async {
    await stop();
  }
}
