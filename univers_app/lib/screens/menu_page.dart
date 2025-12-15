import 'package:flutter/material.dart';
import 'package:univers_app/core/app_state.dart';
import 'package:univers_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Récupère les traductions via AppLocalizations
    final l10n = AppLocalizations.of(context)!;

    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFFFF8E7),
          appBar: AppBar(
            title: Text(
              l10n.settingsTitle,
              style: const TextStyle(
                color: Color(0xFF2D3748),
                fontWeight: FontWeight.w700,
                fontSize: 20.0,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF2D3748),
                size: 28.0,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF8E7), // Crème vanille
                  Color(0xFFFFE5EC), // Rose pâle
                  Color(0xFFE0F7FA), // Bleu ciel très pâle
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSoundSection(context, l10n),
                    const SizedBox(height: 20.0),
                    _buildLanguageSection(context, l10n),
                    const SizedBox(height: 20.0),
                    _buildLockSection(context, l10n),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSoundSection(BuildContext context, AppLocalizations l10n) {
    return _buildCard(
      icon: Icons.volume_up_rounded,
      iconColor: const Color(0xFF4ECDC4),
      title: l10n.soundSection,
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return Column(
            children: [
              _buildSwitchTile(
                icon: Icons.music_note_rounded,
                label: l10n.backgroundMusic,
                value: appState.backgroundMusicEnabled,
                onChanged: (value) => appState.setBackgroundMusicEnabled(value),
              ),
              const Divider(height: 1.0),
              _buildSwitchTile(
                icon: Icons.record_voice_over_rounded,
                label: l10n.textToSpeech,
                value: appState.textToSpeechEnabled,
                onChanged: (value) => appState.setTextToSpeechEnabled(value),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context, AppLocalizations l10n) {
    return _buildCard(
      icon: Icons.language_rounded,
      iconColor: const Color(0xFFFFD93D),
      title: l10n.languageSection,
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                width: 1.0,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: appState.selectedLanguage,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF4ECDC4),
                  size: 28.0,
                ),
                style: const TextStyle(
                  color: Color(0xFF2D3748),
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
                items: appState.supportedLanguages.map((langCode) {
                  return DropdownMenuItem(
                    value: langCode,
                    child: Row(
                      children: [
                        Text(
                          _getFlagEmoji(langCode),
                          style: const TextStyle(fontSize: 24.0),
                        ),
                        const SizedBox(width: 12.0),
                        Text(
                          appState.languageNames[langCode] ??
                              langCode.toUpperCase(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    appState.setLanguage(value);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLockSection(BuildContext context, AppLocalizations l10n) {
    return _buildCard(
      icon: Icons.lock_rounded,
      iconColor: const Color(0xFFFF6B9D),
      title: l10n.guidedAccessSection,
      child: Column(
        children: [
          _buildLockInstruction(
            platform: 'iOS',
            icon: Icons.apple,
            text: l10n.iosLockInstructions,
          ),
          const SizedBox(height: 16.0),
          _buildLockInstruction(
            platform: 'Android',
            icon: Icons.android_rounded,
            text: l10n.androidLockInstructions,
          ),
        ],
      ),
    );
  }

  // Widget réutilisable pour les cartes
  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 28.0,
                  ),
                ),
                const SizedBox(width: 16.0),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            child,
          ],
        ),
      ),
    );
  }

  // Widget pour les switch tiles
  Widget _buildSwitchTile({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(
              icon,
              size: 24.0,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF4ECDC4),
            activeTrackColor: const Color(0xFF4ECDC4).withOpacity(0.4),
          ),
        ],
      ),
    );
  }

  // Widget pour les instructions de verrouillage
  Widget _buildLockInstruction({
    required String platform,
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Icon(
              icon,
              size: 24.0,
              color: const Color(0xFF2D3748),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  platform,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13.0,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper pour obtenir les drapeaux emoji
  String _getFlagEmoji(String languageCode) {
    final flags = {
      'fr': '🇫🇷',
      'en': '🇬🇧',
      'es': '🇪🇸',
      'de': '🇩🇪',
      'it': '🇮🇹',
      'pt': '🇵🇹',
      'nl': '🇳🇱',
      'pl': '🇵🇱',
      'ru': '🇷🇺',
      'zh': '🇨🇳',
      'ja': '🇯🇵',
      'ar': '🇸🇦',
    };
    return flags[languageCode] ?? '🌍';
  }
}
