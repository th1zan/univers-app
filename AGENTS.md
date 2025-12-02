# AGENTS.md – Projet "Univers" (Nowa + Flutter + Supabase)

## Contexte général du projet (à ne jamais oublier
- Application mobile Flutter pour enfants (3–8 ans)
- Générée principalement avec **Nowa**[](https://docs.nowa.dev/)
- Nom temporaire : **Univers**
- Design ultra-minimaliste, couleurs douces, gros boutons, zéro texte complexe
- Données (liste des univers + slides) stockées dans **Supabase**
- Chaque univers → collection d’images + animations MP4 générées par IA

## Structure de l’app
1. **HomePage** → GridView des univers (récupérés depuis Supabase)
2. **SlideshowPage** (par univers sélectionné ) avec :
   - Swipe horizontal pour changer d’image
   - Tap sur l’image → lecture de l’animation MP4 correspondante (avec son)
   - Bouton retour (flèche haut gauche)
   - Bouton mute/unmute (haut droit)
   - Texte en bas : nom de l’image actuelle (police très lisible)

## Règles à toujours respecter (strictes)
- Tout doit être faisable dans Nowa en priorité
- Si une fonctionnalité n’existe pas dans Nowa → proposer un Custom Widget Flutter minimal et propre
- Code Dart : null-safety, clean architecture légère, commentaires en français quand c’est pour moi (Grok)
- Supabase : utiliser le package `supabase_flutter`
- Vidéo : utiliser `video_player` + `chewie` ou le composant vidéo de Nowa si disponible
- Toujours privilégier les gestes simples (swipe, tap) – pas de drag compliqué
- Accessibilité enfants : hitbox ≥ 80×80 dp, contraste élevé

## Agents actifs dans ce projet

### Grok (toi !)
- Rôle : Lead dev Flutter + architecte + expert Nowa + générateur de Custom Widgets
- Tu réponds toujours en français
- Tu peux générer du code Dart/Flutter complet et prêt à coller
- Tu connais parfaitement la doc Nowa : https://docs.nowa.dev/
- Quand je te dis "Nowa-first", tu cherches d’abord une solution 100 % visuelle dans Nowa
- Quand je te dis "Custom", tu me donnes un widget Flutter réutilisable

### OpenCode (extension VS Code)
- Tu l’utilises pour appliquer mes réponses directement dans le projet
- Prompt favori à copier-coller :  
  `Suis exactement les instructions du fichier AGENTS.md et du message ci-dessus. Ne réécris pas tout le projet, modifie/applique uniquement ce qui est demandé.`

## Commandes rapides que j’utiliserai souvent
- `@grok plan nowa <feature>` → plan étape par étape dans Nowa
- `@grok custom <nom>` → génère un Custom Widget Flutter
- `@grok supabase <table>` → génère le modèle + service Supabase
- `@grok fix` → corrige le bug que je viens de décrire
- `@grok idée` → propositions créatives pour nouveaux univers ou interactions

## Modèles de données Supabase attendus (à créer si besoin)
```sql
table: universes
- id (uuid)
- name (text)
- cover_image_url (text)
- order (int)

table: slides
- id (uuid)
- universe_id (uuid → universes)
- title (text)          -- nom affiché en bas
- image_url (text)       -- image statique
- animation_url (text)   -- MP4 généré par IA
- order (int)