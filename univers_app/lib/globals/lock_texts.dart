/// Textes localisés pour le menu et les paramètres.
/// Contient toutes les traductions de l'interface utilisateur.
library;

// Titres des sections du menu
const Map<String, String> menuTitleTexts = {
  'fr': 'Paramètres',
  'en': 'Settings',
  'es': 'Configuración',
  'de': 'Einstellungen',
  'it': 'Impostazioni',
  'pt': 'Configurações',
  'nl': 'Instellingen',
  'pl': 'Ustawienia',
  'ru': 'Настройки',
  'zh': '设置',
  'ja': '設定',
  'ar': 'الإعدادات',
};

const Map<String, String> soundSectionTexts = {
  'fr': 'Son',
  'en': 'Sound',
  'es': 'Sonido',
  'de': 'Ton',
  'it': 'Suono',
  'pt': 'Som',
  'nl': 'Geluid',
  'pl': 'Dźwięk',
  'ru': 'Звук',
  'zh': '声音',
  'ja': 'サウンド',
  'ar': 'الصوت',
};

const Map<String, String> backgroundMusicTexts = {
  'fr': 'Musique de fond',
  'en': 'Background Music',
  'es': 'Música de fondo',
  'de': 'Hintergrundmusik',
  'it': 'Musica di sottofondo',
  'pt': 'Música de fundo',
  'nl': 'Achtergrondmuziek',
  'pl': 'Muzyka w tle',
  'ru': 'Фоновая музыка',
  'zh': '背景音乐',
  'ja': 'バックグラウンドミュージック',
  'ar': 'موسيقى الخلفية',
};

const Map<String, String> textToSpeechTexts = {
  'fr': 'Lecture vocale',
  'en': 'Text to Speech',
  'es': 'Lectura de voz',
  'de': 'Sprachausgabe',
  'it': 'Lettura vocale',
  'pt': 'Leitura de voz',
  'nl': 'Spraak',
  'pl': 'Czytanie głosowe',
  'ru': 'Озвучивание текста',
  'zh': '语音朗读',
  'ja': '音声読み上げ',
  'ar': 'القراءة الصوتية',
};

const Map<String, String> languageSectionTexts = {
  'fr': 'Langue',
  'en': 'Language',
  'es': 'Idioma',
  'de': 'Sprache',
  'it': 'Lingua',
  'pt': 'Idioma',
  'nl': 'Taal',
  'pl': 'Język',
  'ru': 'Язык',
  'zh': '语言',
  'ja': '言語',
  'ar': 'اللغة',
};

const Map<String, String> lockSectionTexts = {
  'fr': 'Verrouillage guidé',
  'en': 'Guided Access',
  'es': 'Acceso guiado',
  'de': 'Geführter Zugriff',
  'it': 'Accesso guidato',
  'pt': 'Acesso guiado',
  'nl': 'Toegang met begeleiding',
  'pl': 'Dostęp z przewodnikiem',
  'ru': 'Гид-доступ',
  'zh': '引导式访问',
  'ja': 'アクセスガイド',
  'ar': 'الوصول الموجه',
};

final Map<String, String> iosLockTexts = {
  'fr': '''
**Verrouiller l’écran pour les enfants (iPhone)**

1. Réglages → Accessibilité
2. Accès guidé (en bas, section Apprentissage)
3. Activer Accès guidé
4. Définir un code (Réglages du code)
5. (Conseillé) Raccourci d’accessibilité → cocher Accès guidé

Pour bloquer dans le jeu :
• Lancer le jeu
• Appuyer 3 fois rapidement sur le bouton latéral
• Toucher Démarrer

Pour quitter : triple-clic → code → Fin
''',
  'en': '''
**Lock screen for kids (iPhone)**

1. Settings → Accessibility
2. Guided Access (Learning section)
3. Turn on Guided Access
4. Set a passcode (Passcode Settings)
5. (Recommended) Accessibility Shortcut → check Guided Access

To lock in the game:
• Open the game
• Triple-click the side button
• Tap Start

To exit: triple-click → enter code → End
''',
  'de': '''
**Bildschirm für Kinder sperren (iPhone)**

1. Einstellungen → Bedienungshilfen
2. Geführter Zugriff (Lernen)
3. Aktivieren
4. Code festlegen
5. (Empfohlen) Kurzbefehl → Geführter Zugriff auswählen

Spiel sperren:
• Spiel öffnen
• 3× schnell Seitentaste drücken
• Start tippen

Beenden: 3× Seitentaste → Code → Ende
''',
  'es': '''
**Bloquear pantalla para niños (iPhone)**

1. Ajustes → Accesibilidad
2. Acceso guiado (Aprendizaje)
3. Activar Acceso guiado
4. Establecer código
5. (Recomendado) Funciones rápidas → marcar Acceso guiado

Bloquear en el juego:
• Abrir el juego
• Pulsar 3 veces rápido el botón lateral
• Tocar Empezar

Salir: triple pulsación → código → Finalizar
''',
  'it': '''
**Bloccare schermo per bambini (iPhone)**

1. Impostazioni → Accessibilità
2. Accesso guidato (Apprendimento)
3. Attivare Accesso guidato
4. Impostare codice
5. (Consigliato) Scorciatoia → selezionare Accesso guidato

Bloccare nel gioco:
• Apri il gioco
• Premi 3 volte rapido il tasto laterale
• Tocca Inizia

Uscire: triplo clic → codice → Fine
''',
};

final Map<String, String> androidLockTexts = {
  'fr': '''
**Verrouiller l’écran pour les enfants (Android)**

1. Paramètres → Sécurité et confidentialité → Plus de sécurité → Épinglage d’application
   (ou chercher « Épingler »)
2. Activer et cocher « Demander le code avant de détacher »

Pour bloquer dans le jeu :
• Ouvrir le jeu
• Appuyer sur le bouton carré (ou glisser pour les apps récentes)
• Toucher l’icône du jeu en haut → Épingler

Pour quitter : maintenir Aperçu + Power → saisir le code
''',
  'en': '''
**Lock screen for kids (Android)**

1. Settings → Security & privacy → More security → App pinning
   (or search “Pin”)
2. Turn on and enable “Ask for PIN before unpinning”

To lock in the game:
• Open the game
• Tap recent apps button (square or swipe)
• Tap game icon at top → Pin

To exit: hold Overview + Power → enter PIN
''',
  'de': '''
**Bildschirm für Kinder sperren (Android)**

1. Einstellungen → Sicherheit & Datenschutz → Weitere Sicherheit → App-Pinning
   (oder „Pinnen“ suchen)
2. Aktivieren + „PIN vor Entpinnen verlangen“ anhaken

Spiel sperren:
• Spiel öffnen
• Taste „Zuletzt genutzte Apps“ (Quadrat)
• Symbol oben antippen → Pinnen

Beenden: Übersicht + Power gedrückt halten → PIN eingeben
''',
  'es': '''
**Bloquear pantalla para niños (Android)**

1. Ajustes → Seguridad y privacidad → Más seguridad → Fijar app
   (o buscar «Fijar»)
2. Activar y marcar «Pedir PIN antes de desanclar»

Bloquear en el juego:
• Abrir el juego
• Botón apps recientes (cuadrado)
• Tocar icono arriba → Fijar

Salir: mantener Vista general + Encendido → introducir PIN
''',
  'it': '''
**Bloccare schermo per bambini (Android)**

1. Impostazioni → Sicurezza e privacy → Altre impostazioni → Fissaggio app
   (o cercare «Fissa»)
2. Attivare + spuntare «Chiedi PIN prima di sganciare»

Bloccare nel gioco:
• Apri il gioco
• Tasto app recenti (quadrato)
• Tocca icona in alto → Fissa

Uscire: tenere premuto Panoramica + Accensione → inserire PIN
''',
};
