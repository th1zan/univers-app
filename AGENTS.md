# AGENTS.md – Projet "Univers" (Flutter + Supabase)

## Contexte général du projet (à ne jamais oublier)
- Application mobile Flutter pour enfants (3–8 ans)
- Projet Flutter classique (sans framework tiers)
- Nom temporaire : **Univers**
- Design ultra-minimaliste, couleurs douces, gros boutons, zéro texte complexe
- Données (liste des univers + slides) stockées dans **Supabase**
- Chaque univers → collection d'images + animations MP4 générées par IA

## Structure de l'app
```
lib/
├── core/           # Constantes, thèmes, état global
├── models/         # Modèles de données immutables
├── screens/        # Pages de l'application
├── services/       # Services (Supabase, Audio, TTS)
├── widgets/        # Widgets réutilisables
└── l10n/           # Fichiers de localisation (ARB)
```

1. **LandingPage** → GridView des univers (récupérés depuis Supabase)
2. **SlideshowPage** (par univers sélectionné) avec :
   - Swipe horizontal pour changer d'image
   - Tap sur l'image → lecture de l'animation MP4 correspondante (avec son)
   - Bouton retour (flèche haut gauche)
   - Bouton mute/unmute (haut droit)
   - Texte en bas : nom de l'image actuelle (police très lisible)

## Règles à toujours respecter (strictes)
- Code Dart : null-safety stricte, modèles immutables avec @immutable
- Clean architecture légère, commentaires en français
- Supabase : utiliser le package `supabase_flutter`
- Vidéo : utiliser `video_player` + `chewie`
- Audio : `audioplayers` via `AudioService` singleton
- TTS : `flutter_tts` via `TtsService` singleton  
- Toujours privilégier les gestes simples (swipe, tap) – pas de drag compliqué
- Accessibilité enfants : hitbox ≥ 80×80 dp, contraste élevé
- Localisation : utiliser `flutter_localizations` avec fichiers ARB

## Agents actifs dans ce projet

### GitHub Copilot
- Rôle : Lead dev Flutter + architecte + générateur de code
- Répond toujours en français
- Génère du code Dart/Flutter complet et prêt à utiliser
- Commande : "Custom" → widget Flutter réutilisable

### FlutterEdu
- Rôle : Agent pédagogique spécialisé en Dart et Flutter
- Approche : Explications simples avec analogies C/C++
- Accès limité : Lecture seule des fichiers
- Commandes : @flutteredu explain <concept>

## Commandes rapides
- `@grok custom <nom>` → génère un Custom Widget Flutter
- `@grok supabase <table>` → génère le modèle + service Supabase
- `@grok fix` → corrige le bug décrit
- `@grok idée` → propositions créatives pour nouveaux univers

## Modèles de données Supabase
```sql
table: univers
- id (uuid)
- name (text)
- cover_image_url (text)
- order (int)

table: univers_assets
- id (uuid)
- universe_id (uuid → univers)
- title (text)          -- nom affiché en bas
- image_url (text)       -- image statique
- animation_url (text)   -- MP4 généré par IA
- order (int)

table: univers_translations / univers_assets_translations
- Traductions multilingues (fr, en, de, es, it)
```
