# 📱 Guide complet – Publication d'application sur App Store & Google Play

**Projet Univers – Documentation de déploiement**  
*Version 1.0 – Décembre 2024*

---

## 📋 Table des matières

1. [Vue d'ensemble du processus](#1-vue-densemble-du-processus)
2. [Configuration Git (GitFlow)](#2-configuration-git-gitflow)
3. [Préparation des assets](#3-préparation-des-assets)
4. [Inscription App Store Connect (iOS)](#4-inscription-app-store-connect-ios)
5. [Inscription Google Play Console (Android)](#5-inscription-google-play-console-android)
6. [Configuration des certificats](#6-configuration-des-certificats)
7. [Pipeline GitHub Actions (CI/CD)](#7-pipeline-github-actions-cicd)
8. [Processus de soumission](#8-processus-de-soumission)
9. [Mises à jour et versions](#9-mises-à-jour-et-versions)
10. [Checklist finale](#10-checklist-finale)

---

## 1. Vue d'ensemble du processus

### 🎯 Objectifs

- Publier l'app **Univers** sur l'App Store (iOS) et Google Play (Android)
- Automatiser le déploiement via **GitHub Actions**
- Suivre un workflow **GitFlow** professionnel
- Comprendre chaque étape du processus (pour un débutant)

### 🗺️ Schéma global

```
┌─────────────────────────────────────────────────────────────┐
│  PHASE 1 : PRÉPARATION                                      │
│  ───────────────────────────────────────────────────────    │
│  → Configurer Git (GitFlow)                                 │
│  → Créer les assets (icônes, screenshots, descriptions)     │
│  → S'inscrire aux portails développeurs                     │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  PHASE 2 : CONFIGURATION DES STORES                         │
│  ───────────────────────────────────────────────────────    │
│  → App Store Connect (Apple) : créer l'app, IAP, etc.       │
│  → Google Play Console : créer l'app, produits, etc.        │
│  → Générer certificats de signature (iOS + Android)         │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  PHASE 3 : CI/CD (GITHUB ACTIONS)                           │
│  ───────────────────────────────────────────────────────    │
│  → Workflow pour build automatique                          │
│  → Deployment sur TestFlight (iOS)                          │
│  → Deployment sur Internal Testing (Android)                │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  PHASE 4 : SOUMISSION & REVIEW                              │
│  ───────────────────────────────────────────────────────    │
│  → Soumettre pour review Apple (3-5 jours)                  │
│  → Soumettre pour review Google (1-3 jours)                 │
│  → Corriger les éventuels rejets                            │
│  → Publication en production ! 🎉                            │
└─────────────────────────────────────────────────────────────┘
```

### ⏱️ Timeline estimée (première publication)

| Étape | Durée |
|-------|-------|
| Configuration Git + Assets | 1-2 jours |
| Inscription portails développeurs | 1 jour |
| Configuration stores + certificats | 2-3 jours |
| CI/CD GitHub Actions | 1-2 jours |
| Review Apple | 3-5 jours |
| Review Google | 1-3 jours |
| **TOTAL** | **~2 semaines** |

---

## 2. Configuration Git (GitFlow)

### 🌳 Principe du GitFlow

GitFlow est une méthodologie de gestion des branches Git qui sépare clairement :
- **Développement** (branche `develop`)
- **Production** (branche `main`)
- **Features** (branches temporaires `feature/...`)
- **Releases** (branches temporaires `release/...`)

### 📊 Schéma du workflow

```
main (production)
  │
  ├─────────── release/1.0.0 ────────► merge après validation
  │                 │
  │                 └────── Tests finaux, corrections
  │                            │
develop (dev)                  │
  │                            │
  ├── feature/auth ────────────┘
  │     └── Travail sur authentification
  │
  ├── feature/ranking ──────────┘
  │     └── Travail sur système de notation
  │
  └── hotfix/critical-bug ──────► merge direct dans main + develop
```

### 🛠️ Configuration initiale

#### Étape 1 : Initialiser le dépôt Git

```bash
# Dans le dossier de ton projet Flutter
cd ~/Documents/Univers_app

# Initialiser Git si pas déjà fait
git init

# Créer le .gitignore
curl -o .gitignore https://raw.githubusercontent.com/flutter/flutter/master/.gitignore

# Ajouter des exclusions spécifiques
cat >> .gitignore << EOF

# Secrets
*.env
*.pem
*.p8
*.p12
*.mobileprovision
google-services.json
GoogleService-Info.plist

# Build artifacts
build/
ios/Pods/
.dart_tool/
EOF
```

#### Étape 2 : Créer les branches principales

```bash
# Créer la branche main (production)
git checkout -b main
git add .
git commit -m "chore: initial commit"

# Créer la branche develop (développement)
git checkout -b develop
git push -u origin main
git push -u origin develop
```

#### Étape 3 : Créer un repo GitHub

```bash
# Sur GitHub.com, créer un nouveau repo "univers-app"

# Lier le repo local au distant
git remote add origin https://github.com/TON_USERNAME/univers-app.git

# Push des branches
git push -u origin main
git push -u origin develop
```

### 📝 Workflow quotidien

#### Créer une nouvelle feature

```bash
# Partir de develop
git checkout develop
git pull origin develop

# Créer une branche feature
git checkout -b feature/nom-de-la-feature

# Travailler sur la feature...
git add .
git commit -m "feat: ajout de la fonctionnalité X"

# Pusher la branche
git push -u origin feature/nom-de-la-feature

# Créer une Pull Request sur GitHub (develop ← feature/nom-de-la-feature)
```

#### Créer une release (préparation de publication)

```bash
# Partir de develop
git checkout develop
git pull origin develop

# Créer une branche release
git checkout -b release/1.0.0

# Mettre à jour la version dans pubspec.yaml
# version: 1.0.0+1

# Commit des changements
git add pubspec.yaml
git commit -m "chore: bump version to 1.0.0"

# Pusher la branche
git push -u origin release/1.0.0

# Déclencher les tests automatiques (GitHub Actions)
# Si tout est OK → merger dans main + develop
```

#### Merger une release en production

```bash
# Merger dans main
git checkout main
git merge --no-ff release/1.0.0
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin main
git push origin v1.0.0

# Merger aussi dans develop (pour sync)
git checkout develop
git merge --no-ff release/1.0.0
git push origin develop

# Supprimer la branche release (optionnel)
git branch -d release/1.0.0
git push origin --delete release/1.0.0
```

### 🔐 Configuration des branches protégées (GitHub)

Sur GitHub.com :

```
1. Repo → Settings → Branches → Add rule

Branch name pattern : main
☑️ Require pull request before merging
☑️ Require status checks to pass before merging
    → Sélectionner : build-ios, build-android (configurés plus tard)
☑️ Require branches to be up to date before merging

Branch name pattern : develop
☑️ Require pull request before merging
☑️ Require status checks to pass before merging
```

---

## 3. Préparation des assets

### 🎨 Assets nécessaires

| Asset | Description | Dimensions | Format |
|-------|-------------|------------|--------|
| **Icône app** | Logo principal | 1024×1024 px | PNG (sans transparence) |
| **Screenshots iOS** | Captures d'écran | Voir tableau ci-dessous | PNG ou JPG |
| **Screenshots Android** | Captures d'écran | Voir tableau ci-dessous | PNG ou JPG |
| **Feature Graphic** (Android) | Bannière Play Store | 1024×500 px | PNG ou JPG |
| **Video Preview** (optionnel) | Démo de l'app | Max 30 sec | MP4 |

### 📱 Dimensions des screenshots

#### iOS (App Store)

| Device | Dimension requise | Nombre |
|--------|------------------|--------|
| iPhone 6.7" (15 Pro Max) | 1290×2796 px | 3-10 |
| iPhone 6.5" (14 Plus) | 1284×2778 px | 3-10 |
| iPad Pro 12.9" (optionnel) | 2048×2732 px | 3-10 |

#### Android (Google Play)

| Type | Dimension | Nombre |
|------|-----------|--------|
| Phone | Min 320 px côté court | 2-8 |
| 7" Tablet | Min 1024 px côté court | 2-8 |
| 10" Tablet | Min 1024 px côté court | 2-8 |

### 🖼️ Créer les screenshots

#### Méthode 1 : Simulateurs (rapide)

```bash
# iOS - Lancer l'app dans le simulateur
flutter run -d 'iPhone 15 Pro Max'

# Faire des captures (Cmd + S)
# Les screenshots sont sauvegardés sur le Bureau

# Android - Lancer l'app dans l'émulateur
flutter run -d emulator-5554

# Faire des captures (bouton caméra dans Android Studio)
```

#### Méthode 2 : Devices physiques (recommandé)

```bash
# iOS - Connecter un iPhone physique
flutter run -d 'iPhone de Thibault'

# Faire des captures (boutons Volume + Power simultanément)
# Récupérer via AirDrop ou iCloud Photos

# Android - Connecter un téléphone physique
flutter run -d RQ8M123ABCD

# Faire des captures (boutons Volume - + Power)
# Récupérer via USB
```

### ✍️ Rédiger les descriptions

#### Structure recommandée

````markdown
# Titre de l'app (30 caractères max)
Univers : Découvertes Magiques

# Sous-titre (30 caractères max - iOS uniquement)
Exploration pour enfants 3-8 ans

# Description courte (80 caractères max - Android)
Explore +20 univers interactifs avec images et animations IA !

# Description complète (4000 caractères max)

## 🌟 Découvre des univers magiques !

**Univers** est une application éducative pour enfants de 3 à 8 ans.
Explore des mondes fascinants à travers des images et animations générées par intelligence artificielle.

### ✨ Fonctionnalités

• **+20 univers thématiques** : Espace, Océan, Dinosaures, Fées, et plus !
• **Animations interactives** : Tapote sur une image pour voir son animation
• **Interface intuitive** : Navigation simple par swipe horizontal
• **Contenu sécurisé** : Pas de publicités, pas d'achats cachés
• **Hors-ligne** : Fonctionne sans connexion Internet

### 🎯 Parfait pour les enfants

✓ Développe la curiosité et l'imagination
✓ Apprentissage visuel des concepts (animaux, nature, espace...)
✓ Design adapté aux tout-petits (gros boutons, contraste élevé)
✓ Contenu approuvé par des parents

### 🔒 Confidentialité

Nous respectons la vie privée des enfants :
• Aucune donnée personnelle collectée
• Pas de publicités tierces
• Environnement 100% sécurisé

### 💎 Version Premium

Débloque l'accès illimité à tous les univers :
• Abonnement mensuel : 4,99 €
• Abonnement annuel : 39,99 € (économise 30%)
• Achat unique à vie : 99,99 €

Annulation possible à tout moment dans les réglages.

---

**Support** : contact@univers-app.com
**Site web** : https://univers-app.com
````

### 📂 Organisation des assets

Créer cette structure de dossiers :

```
Univers_app/
├─ assets/
│  ├─ store/
│  │  ├─ icon/
│  │  │  └─ app_icon_1024.png
│  │  ├─ screenshots/
│  │  │  ├─ ios/
│  │  │  │  ├─ iphone_6.7/
│  │  │  │  │  ├─ 01_homepage.png
│  │  │  │  │  ├─ 02_slideshow.png
│  │  │  │  │  └─ 03_subscription.png
│  │  │  │  └─ ipad_12.9/
│  │  │  └─ android/
│  │  │     ├─ phone/
│  │  │     │  ├─ 01_homepage.png
│  │  │     │  └─ ...
│  │  │     └─ tablet/
│  │  ├─ feature_graphic_android.png
│  │  └─ descriptions/
│  │     ├─ fr.md
│  │     └─ en.md
```

---

## 4. Inscription App Store Connect (iOS)

### 🍎 Étape 1 : S'inscrire à l'Apple Developer Program

```
1. Aller sur https://developer.apple.com/programs/
2. Cliquer sur "Enroll" (S'inscrire)
3. Se connecter avec un Apple ID (ou en créer un)
4. Choisir le type de compte :
   → Individual (Particulier) : 99 $/an
   → Organization (Entreprise) : 99 $/an (nécessite documents légaux)
5. Remplir le formulaire avec :
   • Nom complet
   • Adresse
   • Numéro de téléphone
   • Accepter les conditions
6. Payer les 99 $ (carte bancaire ou PayPal)
7. Attendre validation par Apple (1-2 jours)
```

**💡 Astuce** : Utilise ton propre Apple ID personnel (pas un email pro) pour éviter les problèmes de changement de compte plus tard.

### 📱 Étape 2 : Créer l'app dans App Store Connect

```
1. Aller sur https://appstoreconnect.apple.com/
2. Se connecter avec le même Apple ID
3. Cliquer sur "My Apps" → "+" → "New App"

Formulaire :
┌─────────────────────────────────────────────────────────────┐
│ Platform : iOS                                              │
│ Name : Univers                                              │
│ Primary Language : French (France)                          │
│ Bundle ID : (créer un nouveau)                              │
│   → com.univers.app                                         │
│ SKU : univers-ios-2024                                      │
│ User Access : Full Access                                   │
└─────────────────────────────────────────────────────────────┘

4. Cliquer sur "Create"
```

### 📝 Étape 3 : Remplir les informations de l'app

#### 3.1 Section "App Information"

```
Category :
  Primary : Education
  Secondary : Entertainment

Age Rating :
  Questionnaire → Répondre :
  • Unrestricted Web Access : No
  • Gambling : No
  • Violence : No
  → Résultat : 4+

Content Rights :
  ☑️ Contains third-party content (images IA)
```

#### 3.2 Section "Pricing and Availability"

```
Price Schedule :
  → Free (avec In-App Purchases)

Availability :
  ☑️ All countries and regions
  
Pre-orders :
  → Off
```

#### 3.3 Section "Prepare for Submission"

```
App Preview and Screenshots :
  • iPhone 6.7" Display : [Upload 3-10 screenshots]
  • iPhone 6.5" Display : [Upload 3-10 screenshots]
  • iPad Pro 12.9" Display (optionnel) : [Upload 3-10 screenshots]

Description (4000 caractères max) :
  [Copier la description préparée]

Keywords (100 caractères max, séparés par virgules) :
  enfants,éducation,univers,imagination,découverte,exploration,
  interactif,animations,IA,3-8 ans

Support URL :
  https://univers-app.com/support

Privacy Policy URL :
  https://univers-app.com/privacy

App Review Information :
  First Name : Thibault
  Last Name : [Ton nom]
  Phone : +33 X XX XX XX XX
  Email : contact@univers-app.com

Notes for Review :
  "Cette application éducative utilise des animations générées
   par IA (Stable Diffusion). Les univers gratuits sont accessibles
   sans abonnement. Aucune donnée utilisateur n'est collectée
   (authentification anonyme locale)."

Version Release :
  • Manually release this version (recommandé pour la 1ère fois)

Copyright :
  2024 Thibault [Ton nom]
```

---

## 5. Inscription Google Play Console (Android)

### 🤖 Étape 1 : S'inscrire à Google Play Console

```
1. Aller sur https://play.google.com/console/signup
2. Se connecter avec un compte Google (ou en créer un)
3. Remplir le formulaire :
   • Nom du développeur : Thibault [Ton nom]
   • Pays : France
   • Email : contact@univers-app.com
4. Accepter les accords développeur Google Play
5. Payer les 25 $ (frais uniques, à vie)
   → Carte bancaire uniquement
6. Vérifier l'email (code de confirmation)
```

**💡 Astuce** : Contrairement à Apple (99 $/an), Google ne facture qu'**une seule fois** 25 $.

### 📱 Étape 2 : Créer l'app dans Google Play Console

```
1. Dans la console, cliquer sur "Créer une application"

Formulaire :
┌─────────────────────────────────────────────────────────────┐
│ Nom de l'application : Univers                              │
│ Langue par défaut : Français (France)                       │
│ Type d'application : Application                            │
│ Gratuite ou payante : Gratuite                              │
│                                                             │
│ Déclarations :                                              │
│ ☑️ J'ai lu la politique du programme pour les développeurs │
│ ☑️ J'ai lu les lois sur l'exportation des États-Unis       │
└─────────────────────────────────────────────────────────────┘

2. Créer l'application
```

### 📝 Étape 3 : Configurer la fiche Play Store

#### 3.1 Section "Fiche du Play Store"

```
Détails de l'application :
──────────────────────────────────────────────────────────────
Nom de l'application : Univers

Description courte (80 caractères max) :
  Explore des univers interactifs avec images et animations IA !

Description complète (4000 caractères max) :
  [Copier la description préparée]

Assets graphiques :
──────────────────────────────────────────────────────────────
• Icône d'application : 512×512 px PNG (obligatoire)
• Feature Graphic : 1024×500 px PNG (obligatoire)
• Captures d'écran Phone (2-8) : Upload 3-5 screenshots
• Video YouTube (optionnel) : URL d'une vidéo démo

Catégorisation :
──────────────────────────────────────────────────────────────
Application : Éducation
Catégorie : Enfants
Tags : éducation, enfants, découverte, imagination, interactif

Coordonnées :
──────────────────────────────────────────────────────────────
Site Web : https://univers-app.com
Email : contact@univers-app.com
Téléphone : +33 X XX XX XX XX

Règles de confidentialité :
──────────────────────────────────────────────────────────────
URL : https://univers-app.com/privacy
```

#### 3.2 Section "Classification du contenu"

```
Questionnaire :
┌─────────────────────────────────────────────────────────────┐
│ Public cible : Enfants de moins de 13 ans                   │
│ Catégorie d'application : Éducation                         │
│ Contient-elle des publicités ? : Non                        │
│ Permet-elle aux utilisateurs d'interagir ? : Non            │
│ Partage-t-elle la localisation des utilisateurs ? : Non     │
│ Collecte-t-elle des données personnelles ? : Non            │
│ Contient-elle des achats in-app ? : Oui (abonnements)       │
└─────────────────────────────────────────────────────────────┘

Résultat : App classée "PEGI 3" (Europe) / "Everyone" (USA)
```

---

## 6. Configuration des certificats

### 🍎 iOS : Certificats Apple

#### Étape 1 : Générer un certificat de distribution

```
1. developer.apple.com → Certificates, IDs & Profiles
2. Certificates → "+" → Distribution → App Store and Ad Hoc
3. Create Certificate Signing Request (CSR) sur Mac :
   a) Ouvrir "Trousseaux d'accès" (Keychain Access)
   b) Menu → Certificate Assistant → Request a Certificate
   c) Email : contact@univers-app.com
      Common Name : Univers Distribution
      Request is : Saved to disk
   d) Sauvegarder : CertificateSigningRequest.certSigningRequest

4. Upload le CSR sur developer.apple.com
5. Download le certificat : distribution.cer
6. Double-cliquer pour installer dans Keychain
```

#### Étape 2 : Créer un Provisioning Profile

```
1. developer.apple.com → Profiles → "+"
2. Distribution → App Store → Continue
3. App ID : com.univers.app
4. Certificate : Sélectionner ton certificat de distribution
5. Profile Name : Univers App Store Distribution
6. Generate → Download
7. Double-cliquer pour installer dans Xcode
```

### 🤖 Android : Signature Google Play

#### Étape 1 : Générer une clé de signature

```bash
# Dans le terminal
cd ~/Documents/Univers_app/android/app

# Générer un keystore
keytool -genkey -v -keystore univers-upload-key.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias univers

# Répondre aux questions :
Enter keystore password: [Mot de passe sécurisé]
What is your first and last name? Thibault [Ton nom]
What is the name of your organization? Univers App
What is the name of your City? Paris
What is the two-letter country code? FR

# Fichier créé : univers-upload-key.jks
# ⚠️ NE JAMAIS COMMIT CE FICHIER DANS GIT !
```

#### Étape 2 : Configurer la signature dans Android

Créer un fichier `android/key.properties` :

```properties
storePassword=MOT_DE_PASSE_KEYSTORE
keyPassword=MOT_DE_PASSE_KEYSTORE
keyAlias=univers
storeFile=univers-upload-key.jks
```

Modifier `android/app/build.gradle` :

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

Ajouter au `.gitignore` :

```
# Android signing
android/key.properties
android/app/univers-upload-key.jks
```

---

## 7. Pipeline GitHub Actions (CI/CD)

### 🎯 Objectif

Automatiser :
1. **Build** de l'app iOS et Android
2. **Tests** automatiques
3. **Déploiement** sur TestFlight (iOS) et Internal Testing (Android)

### 📂 Structure des workflows

Créer `.github/workflows/` :

```
.github/
├─ workflows/
│  ├─ build-and-test.yml    # Tests sur chaque PR
│  ├─ deploy-ios.yml        # Déploiement iOS
│  └─ deploy-android.yml    # Déploiement Android
```

### 🧪 Workflow 1 : Tests automatiques

`.github/workflows/build-and-test.yml` :

```yaml
name: Build and Test

on:
  pull_request:
    branches: [develop, main]
  push:
    branches: [develop]

jobs:
  test:
    name: Run Flutter tests
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Analyze code
        run: flutter analyze
      
      - name: Run tests
        run: flutter test
      
      - name: Check formatting
        run: dart format --set-exit-if-changed .

  build-ios:
    name: Build iOS (debug)
    runs-on: macos-latest
    needs: test
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build iOS (no codesign)
        run: flutter build ios --debug --no-codesign

  build-android:
    name: Build Android (debug)
    runs-on: ubuntu-latest
    needs: test
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
      
      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build APK (debug)
        run: flutter build apk --debug
```

### 🍎 Workflow 2 : Déploiement iOS

`.github/workflows/deploy-ios.yml` :

```yaml
name: Deploy iOS to TestFlight

on:
  push:
    branches:
      - 'release/**'
  workflow_dispatch:

jobs:
  deploy-ios:
    name: Build and deploy to TestFlight
    runs-on: macos-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build iOS Release
        run: flutter build ios --release --no-codesign
      
      - name: Upload to TestFlight
        env:
          APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}
        run: |
          # Script d'upload (simplifié)
          echo "Upload vers TestFlight..."
```

### 🤖 Workflow 3 : Déploiement Android

`.github/workflows/deploy-android.yml` :

```yaml
name: Deploy Android to Play Store

on:
  push:
    branches:
      - 'release/**'
  workflow_dispatch:

jobs:
  deploy-android:
    name: Build and deploy to Play Store
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
          channel: 'stable'
      
      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Decode keystore
        env:
          KEYSTORE_BASE64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}
        run: |
          echo $KEYSTORE_BASE64 | base64 --decode > android/app/univers-upload-key.jks
      
      - name: Create key.properties
        env:
          KEYSTORE_PASSWORD: ${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
        run: |
          cat > android/key.properties << EOF
          storePassword=$KEYSTORE_PASSWORD
          keyPassword=$KEYSTORE_PASSWORD
          keyAlias=univers
          storeFile=univers-upload-key.jks
          EOF
      
      - name: Build App Bundle (AAB)
        run: flutter build appbundle --release
      
      - name: Upload to Play Store
        run: |
          echo "Upload vers Play Store Internal Testing..."
```

### 🔐 Configuration des secrets GitHub

Repo → Settings → Secrets and variables → Actions

**Secrets iOS :**
- `IOS_P12_BASE64` : Certificat de distribution en base64
- `IOS_P12_PASSWORD` : Mot de passe du certificat
- `APP_STORE_CONNECT_API_KEY_ID` : ID de la clé API

**Secrets Android :**
- `ANDROID_KEYSTORE_BASE64` : Keystore en base64
- `ANDROID_KEYSTORE_PASSWORD` : Mot de passe du keystore
- `ANDROID_KEY_ALIAS` : `univers`

---

## 8. Processus de soumission

### 🍎 Soumission iOS

#### Étape 1 : Vérifier le build TestFlight

```
1. App Store Connect → My Apps → Univers → TestFlight
2. Vérifier que le build apparaît (5-15 minutes)
3. Tester le build avec des testeurs internes
4. Statut : "Ready to Submit"
```

#### Étape 2 : Soumettre pour review

```
1. App Store Connect → My Apps → Univers → (Version 1.0)
2. Vérifier que TOUS les champs sont remplis
3. Cliquer sur "Submit for Review"
4. Répondre au questionnaire Export Compliance :
   • Does your app use encryption? YES (HTTPS)
   • Is it exempt? YES (standard cryptography)
5. Statut passe à "Waiting for Review"
```

#### Étape 3 : Suivre la review

Statuts possibles :
- **Waiting for Review** (1-3 jours)
- **In Review** (quelques heures)
- **Pending Developer Release** (approuvé, en attente de publication)
- **Ready for Sale** (publié)

### 🤖 Soumission Android

#### Étape 1 : Créer une release (Internal Testing)

```
1. Google Play Console → Testing → Internal testing
2. Create new release
3. Upload AAB : `build/app/outputs/bundle/release/app-release.aab`
4. Release name : 1.0.0 (1)
5. Release notes : "Première version de l'application"
6. Review et save
```

#### Étape 2 : Passer en Production

```
1. Après tests internes concluants
2. Promote release → Production
3. Remplir tous les questionnaires (rating, content, etc.)
4. Submit for review
5. Review Google : 1-3 jours
```

---

## 9. Mises à jour et versions

### 📦 Versioning (SemVer)

Format : `MAJOR.MINOR.PATCH+BUILD`

Exemple : `1.2.3+45`
- **MAJOR** (1) : Changements incompatibles
- **MINOR** (2) : Nouvelles fonctionnalités
- **PATCH** (3) : Corrections de bugs
- **BUILD** (+45) : Numéro de build (auto-incrémenté)

### 🔄 Workflow de mise à jour

```bash
# 1. Créer une branche release
git checkout develop
git pull origin develop
git checkout -b release/1.1.0

# 2. Mettre à jour pubspec.yaml
# version: 1.1.0+2

# 3. Générer le CHANGELOG
cat >> CHANGELOG.md << EOF
## [1.1.0] - 2024-12-15

### Ajouté
- Nouveau système de notation par étoiles
- Page d'abonnements premium

### Corrigé
- Bug d'affichage sur petits écrans
EOF

# 4. Commit et push
git add pubspec.yaml CHANGELOG.md
git commit -m "chore: bump version to 1.1.0"
git push -u origin release/1.1.0

# 5. Merger dans main → déclenchera le déploiement automatique
git checkout main
git merge --no-ff release/1.1.0
git tag -a v1.1.0 -m "Version 1.1.0"
git push origin main --tags

# 6. Merger dans develop
git checkout develop
git merge --no-ff release/1.1.0
git push origin develop
```

---

## 10. Checklist finale

### ✅ Avant la première soumission

#### Développement
- [ ] Code finalisé et testé
- [ ] Toutes les fonctionnalités fonctionnent
- [ ] App testée sur plusieurs devices physiques
- [ ] Pas de crashs ni bugs critiques
- [ ] Performance optimisée (< 50 MB, chargement rapide)

#### Assets
- [ ] Icône 1024×1024 créée
- [ ] Screenshots iOS (3-10 par taille)
- [ ] Screenshots Android (2-8)
- [ ] Feature Graphic Android (1024×500)
- [ ] Descriptions FR + EN rédigées
- [ ] Video preview (optionnel)

#### Configuration Stores
- [ ] Apple Developer Program (99 $/an)
- [ ] Google Play Console (25 $ unique)
- [ ] App créée dans App Store Connect
- [ ] App créée dans Google Play Console
- [ ] Certificats iOS générés
- [ ] Keystore Android généré
- [ ] Politique de confidentialité publiée

#### Git & CI/CD
- [ ] Repo GitHub créé
- [ ] Branches `main` et `develop` configurées
- [ ] Branch protections activées
- [ ] GitHub Actions configurés
- [ ] Secrets GitHub ajoutés

#### Tests finaux
- [ ] Build iOS (TestFlight)
- [ ] Build Android (Internal Testing)
- [ ] Tests par 2-3 personnes
- [ ] Pas de crashs reportés
- [ ] IAP testés en sandbox

### 📝 Checklist de soumission

#### iOS
- [ ] Build uploadé sur TestFlight
- [ ] Build testé en interne
- [ ] Tous les champs App Store Connect remplis
- [ ] Screenshots uploadés
- [ ] Description complète
- [ ] Export Compliance répondu
- [ ] Soumis pour review
- [ ] Email de confirmation reçu

#### Android
- [ ] AAB uploadé sur Play Console
- [ ] Release Internal Testing créée
- [ ] Testé par au moins 20 testeurs pendant 14 jours (requis)
- [ ] Tous les questionnaires complétés
- [ ] Classification du contenu validée
- [ ] Politique de confidentialité liée
- [ ] Promote en Production
- [ ] Soumis pour review

---

## 🎉 Félicitations !

Tu as maintenant toutes les connaissances pour publier ton app sur les stores iOS et Android !

**Prochaines étapes :**
1. Suivre ce guide étape par étape
2. Tester minutieusement avant chaque soumission
3. Répondre rapidement aux demandes de review
4. Monitorer les reviews utilisateurs
5. Publier des mises à jour régulières

**Ressources utiles :**
- [Documentation Apple](https://developer.apple.com/app-store/review/guidelines/)
- [Documentation Google Play](https://support.google.com/googleplay/android-developer)
- [Flutter CI/CD](https://docs.flutter.dev/deployment/cd)
- [GitFlow Tutorial](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)

**Support :**
- Email : contact@univers-app.com
- Documentation : https://univers-app.com/docs

Bonne publication ! 🚀
