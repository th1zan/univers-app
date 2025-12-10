 # Principe général – Authentification + Ranking + Abonnements

## 1️⃣ **Authentification anonyme (Supabase)**

### Concept
- **Supabase Auth** permet de créer un utilisateur anonyme sans email/mot de passe
- L'utilisateur reçoit un **UUID unique** stocké dans `auth.users`
- Cet UUID permet de lier :
  - Ses **notes** d'univers (table `ratings`)
  - Son **statut d'abonnement** (table `subscriptions`)
- Si l'utilisateur supprime l'app → il perd son compte (anonyme = non-récupérable)
- **Optionnel** : tu peux proposer de convertir le compte anonyme en compte email plus tard

### Flow
```
1. Au premier lancement → `supabase.auth.signInAnonymously()`
2. Supabase crée un user dans `auth.users` (colonne `is_anonymous = true`)
3. Stocker `user.id` localement (SharedPreferences) pour éviter de recréer un compte
4. Utiliser `user.id` pour toutes les features suivantes
```

---

## 2️⃣ **Ranking des univers**

### Concept
- Chaque utilisateur peut noter un univers **une seule fois** (note de 1 à 5 étoiles par exemple)
- On stocke ça dans une table `ratings` avec une contrainte **unique** sur `(user_id, universe_id)`
- Pour afficher le classement :
  - **Moyenne des notes** par univers (SQL `AVG`)
  - **Nombre de notes** (pour pondérer)
  - Tri par note moyenne décroissante

### Table Supabase à créer

```sql
CREATE TABLE ratings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  universe_id uuid REFERENCES universes(id) ON DELETE CASCADE,
  rating int CHECK (rating >= 1 AND rating <= 5),
  created_at timestamptz DEFAULT now(),
  
  -- Empêche un user de noter 2 fois le même univers
  UNIQUE(user_id, universe_id)
);

-- Index pour optimiser les requêtes de classement
CREATE INDEX idx_ratings_universe ON ratings(universe_id);
```

### Affichage du classement
```sql
SELECT 
  u.id,
  u.name,
  u.cover_image_url,
  AVG(r.rating) as avg_rating,
  COUNT(r.id) as rating_count
FROM universes u
LEFT JOIN ratings r ON r.universe_id = u.id
GROUP BY u.id
ORDER BY avg_rating DESC NULLS LAST, rating_count DESC;
```

---

## 3️⃣ **Système d'abonnements**

### Concept
- Chaque univers est **gratuit OU premium**
- Table `universes` → ajouter colonne `is_free` (boolean)
- Table `subscriptions` → suit le statut d'abonnement de chaque utilisateur
- **Types d'abonnement** :
  - `free` → accès univers gratuits uniquement
  - `monthly` → accès total pendant 1 mois
  - `yearly` → accès total pendant 1 an
  - `lifetime` → accès total permanent

### Tables Supabase à créer

#### 1. Modifier `universes`
```sql
ALTER TABLE universes 
ADD COLUMN is_free boolean DEFAULT false;
```

#### 2. Créer `subscriptions`
```sql
CREATE TABLE subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Type d'abonnement
  subscription_type text CHECK (subscription_type IN ('free', 'monthly', 'yearly', 'lifetime')),
  
  -- Statut de paiement
  is_paid boolean DEFAULT false,
  
  -- Dates de validité
  starts_at timestamptz,
  expires_at timestamptz,  -- NULL pour lifetime
  
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Index pour vérifier rapidement si un user a accès premium
CREATE INDEX idx_subscriptions_user ON subscriptions(user_id, is_paid);
```

### Logique d'accès (à implémenter dans Flutter)
```dart
bool canAccessUniverse(Universe universe, Subscription userSub) {
  // Si l'univers est gratuit → toujours accessible
  if (universe.isFree) return true;
  
  // Sinon, vérifier l'abonnement
  if (!userSub.isPaid) return false;
  
  // Lifetime → accès permanent
  if (userSub.subscriptionType == 'lifetime') return true;
  
  // Sinon, vérifier la date d'expiration
  return userSub.expiresAt != null && 
         DateTime.now().isBefore(userSub.expiresAt!);
}
```

---

## 4️⃣ **Récapitulatif des tables à créer**

| Table | Description |
|-------|-------------|
| `ratings` | Notes des utilisateurs (1-5) par univers |
| `subscriptions` | Statut d'abonnement de chaque user |
| `universes` (modifier) | Ajouter `is_free` pour distinguer gratuit/premium |

---

## 5️⃣ **Flow utilisateur complet**

```
1. Lancement app
   ├─ Si pas de user → signInAnonymously()
   └─ Stocker user.id localement

2. Page d'accueil (HomePage)
   ├─ Fetch universes + subscription de l'utilisateur
   └─ Afficher badge 🔒 sur univers premium si pas d'abonnement valide

3. Tap sur univers
   ├─ Si is_free OU abonnement valide → SlideshowPage
   └─ Sinon → Popup "Abonne-toi pour débloquer"

4. Swipe dans SlideshowPage
   └─ Afficher widget de notation (étoiles) en bas
       ├─ Insert/Update dans table ratings
       └─ Refresh classement en HomePage

5. Page Abonnements (nouvelle)
   ├─ Afficher les 3 formules (monthly/yearly/lifetime)
   └─ Intégrer paiement (Stripe/RevenueCat/In-App Purchase)
       └─ Update subscription.is_paid + expires_at
```

---

## ✅ Prochaines étapes (dis-moi ce que tu veux que je génère)

1. **Custom Widget** `UniverseRatingWidget` (étoiles + sauvegarde)
2. **Supabase Service** pour `ratings` et `subscriptions`
3. **Logique de vérification** `canAccessUniverse()`
4. **Page d'abonnements** (UI Nowa + Custom Widget si besoin)
5. **Intégration paiement** (Stripe/RevenueCat – hors scope Nowa)

**Dis-moi par quoi tu veux commencer !** 🚀

th1zan: Comment est géré le paiement de manière général et de facon "simple" pour le developpeur si l'app est déployé sur ios et android ?

GitHub Copilot: # Gestion des paiements In-App (iOS + Android) – Approche simple

## 🎯 Principe général

Les stores (Apple App Store & Google Play Store) **imposent** leur système de paiement pour les achats numériques (abonnements, contenus débloquables, etc.).

### Pourquoi tu ne peux PAS utiliser Stripe/PayPal directement ?
- **Apple** : refuse tout paiement externe dans l'app (risque de ban + commission 30%)
- **Google** : idem depuis 2022 (nouvelle politique stricte)

### La solution officielle : **In-App Purchases (IAP)**
- **iOS** : StoreKit (Apple)
- **Android** : Google Play Billing

---

## 📦 Solution Flutter recommandée : `in_app_purchase`

### Package officiel Google/Flutter
```yaml
dependencies:
  in_app_purchase: ^3.1.13  # Package officiel
```

### Avantages
✅ Un seul code Dart pour iOS **et** Android  
✅ Géré par Google (équipe Flutter)  
✅ Gratuit (pas d'intermédiaire)  
✅ Supporte abonnements + achats uniques  

### Inconvénients
⚠️ Configuration manuelle dans App Store Connect + Google Play Console  
⚠️ Gestion des webhooks serveur pour sécuriser (optionnel mais recommandé)  
⚠️ Commissions : **30% Apple/Google** (15% si < 1M$/an)

---

## 🔥 Alternative ultra-simple : **RevenueCat**

### Concept
Service tiers qui **wrappe** les IAP et simplifie tout.

### Avantages
✅ **1 SDK** pour iOS + Android + Web  
✅ Dashboard centralisé (suivi abonnements, analytics, churn)  
✅ Gestion automatique des **webhooks serveur** → mise à jour Supabase  
✅ Support gratuit jusqu'à **10 000 $/mois** de revenu  
✅ Intégration Supabase documentée officiellement  

### Package Flutter
```yaml
dependencies:
  purchases_flutter: ^6.29.0  # SDK RevenueCat
```

### Workflow complet (avec Supabase)
```
1. User clique "S'abonner" dans l'app
   └─ RevenueCat.purchasePackage('monthly')

2. RevenueCat gère le paiement (StoreKit ou Google Billing)
   └─ Retourne status (success/cancelled/error)

3. RevenueCat envoie un webhook à ton backend Supabase
   └─ Update automatique de la table subscriptions

4. App vérifie subscription.is_paid via Supabase
   └─ Unlock contenu premium
```

---

## 🛠️ Configuration minimale (RevenueCat + Supabase)

### 1️⃣ Créer un compte RevenueCat
- https://www.revenuecat.com/
- Gratuit jusqu'à 10k$/mois
- Récupère ta **Public API Key**

### 2️⃣ Configurer les produits dans les stores

#### App Store Connect (iOS)
```
1. Créer l'app dans App Store Connect
2. Aller dans Features → In-App Purchases
3. Créer 3 produits :
   - univers_monthly (Auto-Renewable Subscription, 1 mois)
   - univers_yearly  (Auto-Renewable Subscription, 1 an)
   - univers_lifetime (Non-Consumable Purchase)
4. Copier les Product IDs
```

#### Google Play Console (Android)
```
1. Créer l'app dans Google Play Console
2. Aller dans Produits → Abonnements
3. Créer les mêmes 3 produits avec MÊMES IDs
4. Activer la facturation (lier compte bancaire)
```

### 3️⃣ Lier les stores à RevenueCat
```
1. Dashboard RevenueCat → Apps → Add App
2. Upload le fichier de credentials :
   - iOS : Service Account Key (JSON) depuis App Store Connect
   - Android : Service Account Key (JSON) depuis Google Cloud Console
3. RevenueCat synchronise automatiquement les produits
```

### 4️⃣ Code Flutter (ultra-simple)

#### Initialisation (main.dart)
```dart
import 'package:purchases_flutter/purchases_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Init Supabase
  await Supabase.initialize(url: '...', anonKey: '...');
  
  // Init RevenueCat
  await Purchases.configure(
    PurchasesConfiguration('YOUR_REVENUECAT_PUBLIC_KEY')
      ..appUserID = Supabase.instance.client.auth.currentUser?.id, // Link au user Supabase
  );
  
  runApp(MyApp());
}
```

#### Page d'abonnements (Custom Widget)
```dart
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionPage extends StatefulWidget {
  @override
  _SubscriptionPageState createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  List<Package> _packages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    try {
      // Récupère les offres depuis RevenueCat
      Offerings offerings = await Purchases.getOfferings();
      setState(() {
        _packages = offerings.current?.availablePackages ?? [];
        _loading = false;
      });
    } catch (e) {
      print('Erreur chargement offres : $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _purchase(Package package) async {
    try {
      // Lance le paiement
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      
      // Vérifie si l'abonnement est actif
      if (customerInfo.entitlements.active.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Abonnement activé !')),
        );
        
        // RevenueCat mettra à jour Supabase via webhook
        Navigator.pop(context);
      }
    } on PlatformException catch (e) {
      // User a annulé ou erreur paiement
      print('Erreur achat : ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Abonnements')),
      body: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: _packages.length,
        itemBuilder: (context, index) {
          final package = _packages[index];
          return Card(
            child: ListTile(
              title: Text(package.storeProduct.title),
              subtitle: Text(package.storeProduct.description),
              trailing: Text(
                package.storeProduct.priceString,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onTap: () => _purchase(package),
            ),
          );
        },
      ),
    );
  }
}
```

### 5️⃣ Webhook Supabase (automatique avec RevenueCat)

#### Créer une Edge Function Supabase
```typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  const event = await req.json()
  
  // RevenueCat envoie l'event à chaque changement d'abonnement
  if (event.type === 'INITIAL_PURCHASE' || event.type === 'RENEWAL') {
    const { app_user_id, product_id, expiration_at_ms } = event.event
    
    // Détermine le type d'abonnement
    let subscriptionType = 'monthly'
    if (product_id.includes('yearly')) subscriptionType = 'yearly'
    if (product_id.includes('lifetime')) subscriptionType = 'lifetime'
    
    // Update Supabase
    await supabase.from('subscriptions').upsert({
      user_id: app_user_id,
      subscription_type: subscriptionType,
      is_paid: true,
      expires_at: subscriptionType === 'lifetime' ? null : new Date(expiration_at_ms)
    })
  }
  
  return new Response('OK', { status: 200 })
})
```

#### Configurer l'URL dans RevenueCat
```
Dashboard RevenueCat → Integrations → Webhooks
URL : https://VOTRE_PROJET.supabase.co/functions/v1/revenuecat-webhook
Authorization : Bearer VOTRE_SUPABASE_ANON_KEY
```

---

## 🎁 Récapitulatif : Quelle solution choisir ?

| Critère | `in_app_purchase` (officiel) | RevenueCat |
|---------|------------------------------|------------|
| **Complexité** | Moyenne (config stores manuelle) | Faible (dashboard tout-en-un) |
| **Coût** | Gratuit (commission store uniquement) | Gratuit < 10k$/mois |
| **Webhooks serveur** | À coder toi-même | Automatique |
| **Analytics** | Non | Dashboard complet |
| **Support cross-platform** | iOS + Android seulement | iOS + Android + Web |

### Ma recommandation pour ton projet
➡️ **RevenueCat** car :
- Tu as déjà Supabase (webhook natif)
- Tu débutes (dashboard + doc excellente)
- App enfants = potentiel lifetime purchases (RevenueCat gère parfaitement)

---

## ✅ Prochaine étape concrète

**Veux-tu que je génère :**
1. Le Custom Widget `SubscriptionPage` complet (avec Nowa-ready structure) ?
2. La Edge Function Supabase pour le webhook RevenueCat ?
3. Le plan étape par étape de configuration RevenueCat + stores ?

**Dis-moi ce que tu préfères !** 🚀

th1zan: Produit moi un markdown qui reprend et explique l'implémentation pas à pas de la gestion utilisateur pour le ranking et le paiement avec RevenueCat. Structure le pour bien expliquer la gestion general des user , les tables a créer dans supabase , les etapes dans revenueCat. Bref la total de notre conversation de manipre structuré que je puisse lire, comprendre, implémenter et faiore implémenter plus tard.

GitHub Copilot: # 🚀 Guide complet : Authentification + Ranking + Abonnements (RevenueCat + Supabase)

> **Contexte** : Application Flutter "Univers" pour enfants (3-8 ans)  
> **Stack** : Nowa + Flutter + Supabase + RevenueCat  
> **Objectif** : Permettre notation des univers + gestion abonnements iOS/Android

---

## 📋 Table des matières

1. Vue d'ensemble du système
2. Gestion des utilisateurs (authentification)
3. Configuration Supabase (tables)
4. Système de ranking des univers
5. Système d'abonnements (RevenueCat)
6. Implémentation Flutter étape par étape
7. Webhooks et synchronisation
8. Testing et déploiement

---

## 1. Vue d'ensemble du système

### Architecture globale

```
┌─────────────────────────────────────────────────────────────┐
│                      APP FLUTTER (Nowa)                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │  HomePage    │→ │ SlideshowPage│→ │ SubscriptionPage │  │
│  │ (GridView)   │  │  (Swipe+Tap) │  │  (RevenueCat)    │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
│         ↓                  ↓                    ↓            │
└─────────┼──────────────────┼────────────────────┼───────────┘
          │                  │                    │
          ↓                  ↓                    ↓
┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐
│  Supabase Auth  │  │  Supabase DB    │  │  RevenueCat  │
│  (Anonymous)    │  │  (ratings,      │  │  (IAP iOS/   │
│                 │  │   subscriptions)│  │   Android)   │
└─────────────────┘  └─────────────────┘  └──────────────┘
          ↑                  ↑                    ↓
          └──────────────────┴────────────────────┘
                    Webhook (Edge Function)
```

### Flow utilisateur complet

```
1. Lancement app
   ├─ Vérifie session Supabase
   │  ├─ Si existe → utilise user.id
   │  └─ Sinon → signInAnonymously() + stocke user.id
   └─ Fetch universes + subscription status

2. HomePage (liste univers)
   ├─ Affiche tous les univers avec badge 🔒 si premium
   └─ Tap → vérifie accès avant d'ouvrir SlideshowPage

3. SlideshowPage (par univers)
   ├─ Swipe horizontal entre slides
   ├─ Tap → lecture animation MP4
   └─ Widget notation en bas (étoiles 1-5)
       └─ Sauvegarde dans table ratings

4. Tap sur univers verrouillé
   └─ Popup → "S'abonner pour débloquer"
       └─ Redirige vers SubscriptionPage

5. SubscriptionPage
   ├─ Affiche 3 formules (monthly/yearly/lifetime)
   ├─ Tap → RevenueCat.purchasePackage()
   └─ Success → webhook met à jour Supabase
       └─ App refresh → unlock univers premium
```

---

## 2. Gestion des utilisateurs (authentification)

### 2.1 Principe de l'authentification anonyme

#### Pourquoi anonyme ?
- **App enfants** : pas d'email/mot de passe à gérer par les parents
- **Simplicité** : expérience fluide dès le premier lancement
- **Privacy-first** : aucune donnée personnelle stockée
- **UUID unique** : Supabase génère un identifiant permanent

#### Lifecycle du compte anonyme

```
┌─────────────────────────────────────────────────────┐
│  Premier lancement                                   │
│  ────────────────────────────────────────────────   │
│  1. App vérifie SharedPreferences                    │
│  2. Aucun user_id trouvé                             │
│  3. supabase.auth.signInAnonymously()               │
│  4. Supabase crée user dans auth.users              │
│     └─ is_anonymous = true                          │
│  5. App stocke user.id en local                     │
│  6. Créer ligne par défaut dans subscriptions       │
│     └─ subscription_type = 'free'                   │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  Lancements suivants                                 │
│  ────────────────────────────────────────────────   │
│  1. App récupère user_id depuis SharedPreferences    │
│  2. Vérifie session Supabase                         │
│     ├─ Si expirée → refreshSession()                │
│     └─ Sinon → continue avec user existant          │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  Désinstallation app                                 │
│  ────────────────────────────────────────────────   │
│  ⚠️  Compte perdu définitivement                     │
│  → Réinstallation = nouveau compte anonyme          │
│  → Notes et abonnements perdus                       │
│                                                       │
│  💡 Solution future : proposer upgrade vers compte  │
│     email pour sauvegarder les données              │
└─────────────────────────────────────────────────────┘
```

### 2.2 Configuration Supabase Auth

#### Activer l'authentification anonyme

1. **Dashboard Supabase** → Authentication → Settings
2. Cocher **"Enable anonymous sign-ins"**
3. Configurer JWT expiry : **90 jours** (pour limiter re-connexions)

#### Politique RLS (Row Level Security)

```sql
-- Autoriser utilisateurs anonymes à lire/écrire leurs propres données

-- Table ratings
CREATE POLICY "Users can insert their own ratings"
  ON ratings FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can read all ratings"
  ON ratings FOR SELECT
  USING (true);

CREATE POLICY "Users can update their own ratings"
  ON ratings FOR UPDATE
  USING (auth.uid() = user_id);

-- Table subscriptions
CREATE POLICY "Users can read their own subscription"
  ON subscriptions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Service role can update subscriptions"
  ON subscriptions FOR UPDATE
  USING (auth.role() = 'service_role');  -- Uniquement webhooks
```

---

## 3. Configuration Supabase (tables)

### 3.1 Table `ratings` (système de notation)

#### Schéma SQL

````sql
CREATE TABLE ratings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  universe_id uuid NOT NULL REFERENCES universes(id) ON DELETE CASCADE,
  rating int NOT NULL CHECK (rating >= 1 AND rating <= 5),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  
  -- Contrainte : un user ne peut noter qu'une fois par univers
  CONSTRAINT unique_user_universe UNIQUE(user_id, universe_id)
);

-- Index pour optimiser les requêtes de classement
CREATE INDEX idx_ratings_universe ON ratings(universe_id);
CREATE INDEX idx_ratings_user ON ratings(user_id);

-- Trigger pour mettre à jour updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ratings_updated_at
  BEFORE UPDATE ON ratings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
````

#### Modèle Dart correspondant

````dart
class Rating {
  final String id;
  final String userId;
  final String universeId;
  final int rating;  // 1 à 5
  final DateTime createdAt;
  final DateTime updatedAt;

  Rating({
    required this.id,
    required this.userId,
    required this.universeId,
    required this.rating,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      userId: json['user_id'],
      universeId: json['universe_id'],
      rating: json['rating'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'universe_id': universeId,
      'rating': rating,
    };
  }
}
````

---

### 3.2 Table `subscriptions` (gestion abonnements)

#### Schéma SQL

````sql
CREATE TABLE subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Type d'abonnement
  subscription_type text NOT NULL DEFAULT 'free' 
    CHECK (subscription_type IN ('free', 'monthly', 'yearly', 'lifetime')),
  
  -- Statut de paiement
  is_paid boolean DEFAULT false,
  
  -- Identifiant RevenueCat (pour debug/support)
  revenuecat_customer_id text,
  
  -- Dates de validité
  starts_at timestamptz,
  expires_at timestamptz,  -- NULL si lifetime
  
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Index pour vérifier rapidement l'accès premium
CREATE INDEX idx_subscriptions_user_paid ON subscriptions(user_id, is_paid);

-- Trigger updated_at
CREATE TRIGGER subscriptions_updated_at
  BEFORE UPDATE ON subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
````

#### Modèle Dart correspondant

````dart
class Subscription {
  final String id;
  final String userId;
  final String subscriptionType;  // 'free', 'monthly', 'yearly', 'lifetime'
  final bool isPaid;
  final String? revenuecatCustomerId;
  final DateTime? startsAt;
  final DateTime? expiresAt;  // null si lifetime
  final DateTime createdAt;
  final DateTime updatedAt;

  Subscription({
    required this.id,
    required this.userId,
    required this.subscriptionType,
    required this.isPaid,
    this.revenuecatCustomerId,
    this.startsAt,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      userId: json['user_id'],
      subscriptionType: json['subscription_type'],
      isPaid: json['is_paid'] ?? false,
      revenuecatCustomerId: json['revenuecat_customer_id'],
      startsAt: json['starts_at'] != null 
          ? DateTime.parse(json['starts_at']) 
          : null,
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Vérifie si l'abonnement est actuellement actif
  bool get isActive {
    if (!isPaid) return false;
    if (subscriptionType == 'lifetime') return true;
    if (expiresAt == null) return false;
    return DateTime.now().isBefore(expiresAt!);
  }
}
````

---

### 3.3 Modification table `universes` (marquer univers gratuits)

#### Migration SQL

````sql
-- Ajouter colonne is_free
ALTER TABLE universes 
ADD COLUMN is_free boolean DEFAULT false;

-- Exemple : marquer 3 premiers univers comme gratuits
UPDATE universes 
SET is_free = true 
WHERE order <= 3;

-- Index pour filtrer rapidement
CREATE INDEX idx_universes_free ON universes(is_free);
````

#### Modèle Dart mis à jour

````dart
class Universe {
  final String id;
  final String name;
  final String coverImageUrl;
  final int order;
  final bool isFree;  // NOUVEAU

  Universe({
    required this.id,
    required this.name,
    required this.coverImageUrl,
    required this.order,
    this.isFree = false,  // Par défaut premium
  });

  factory Universe.fromJson(Map<String, dynamic> json) {
    return Universe(
      id: json['id'],
      name: json['name'],
      coverImageUrl: json['cover_image_url'],
      order: json['order'],
      isFree: json['is_free'] ?? false,
    );
  }
}
````

---

## 4. Système de ranking des univers

### 4.1 Calcul du classement (requête Supabase)

#### SQL pour récupérer le classement

````sql
-- Vue matérialisée pour performance (optionnel si bcp de données)
CREATE MATERIALIZED VIEW universe_rankings AS
SELECT 
  u.id,
  u.name,
  u.cover_image_url,
  u.order,
  u.is_free,
  COALESCE(AVG(r.rating), 0) as avg_rating,
  COUNT(r.id) as rating_count
FROM universes u
LEFT JOIN ratings r ON r.universe_id = u.id
GROUP BY u.id;

-- Refresh automatique toutes les heures
CREATE OR REPLACE FUNCTION refresh_rankings()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW universe_rankings;
END;
$$ LANGUAGE plpgsql;

-- Fonction Dart alternative (si pas de vue matérialisée)
````

#### Service Dart pour le ranking

````dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/universe.dart';

class RankingService {
  final _supabase = Supabase.instance.client;

  /// Récupère les univers triés par note moyenne
  Future<List<UniverseWithRating>> getRankedUniverses() async {
    final response = await _supabase
        .from('universes')
        .select('''
          *,
          ratings:ratings(rating)
        ''')
        .order('order', ascending: true);

    final List<dynamic> data = response as List;
    
    // Calcul des moyennes côté client
    final universes = data.map((json) {
      final universe = Universe.fromJson(json);
      final ratings = (json['ratings'] as List?)
          ?.map((r) => r['rating'] as int)
          .toList() ?? [];
      
      final avgRating = ratings.isEmpty 
          ? 0.0 
          : ratings.reduce((a, b) => a + b) / ratings.length;
      
      return UniverseWithRating(
        universe: universe,
        avgRating: avgRating,
        ratingCount: ratings.length,
      );
    }).toList();

    // Tri par note décroissante
    universes.sort((a, b) => b.avgRating.compareTo(a.avgRating));
    return universes;
  }

  /// Récupère la note donnée par l'utilisateur pour un univers
  Future<int?> getUserRating(String universeId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('ratings')
        .select('rating')
        .eq('user_id', userId)
        .eq('universe_id', universeId)
        .maybeSingle();

    return response?['rating'] as int?;
  }

  /// Enregistre ou met à jour la note
  Future<void> saveRating(String universeId, int rating) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User non authentifié');

    await _supabase.from('ratings').upsert({
      'user_id': userId,
      'universe_id': universeId,
      'rating': rating,
    }, onConflict: 'user_id,universe_id');
  }
}

// Modèle pour univers + note
class UniverseWithRating {
  final Universe universe;
  final double avgRating;
  final int ratingCount;

  UniverseWithRating({
    required this.universe,
    required this.avgRating,
    required this.ratingCount,
  });
}
````

---

### 4.2 Custom Widget : Notation par étoiles

#### Widget réutilisable (Nowa-compatible)

````dart
import 'package:flutter/material.dart';
import '../services/ranking_service.dart';

/// Widget de notation par étoiles (1 à 5)
/// Affiche les étoiles pleines/vides selon la note actuelle
/// Permet de changer la note en tapant sur une étoile
class RatingStarsWidget extends StatefulWidget {
  final String universeId;
  final double initialRating;  // Note moyenne affichée par défaut
  final Function(int)? onRatingChanged;  // Callback optionnel

  const RatingStarsWidget({
    Key? key,
    required this.universeId,
    this.initialRating = 0,
    this.onRatingChanged,
  }) : super(key: key);

  @override
  State<RatingStarsWidget> createState() => _RatingStarsWidgetState();
}

class _RatingStarsWidgetState extends State<RatingStarsWidget> {
  final _rankingService = RankingService();
  int? _userRating;  // Note donnée par l'utilisateur (null si pas encore noté)
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRating();
  }

  Future<void> _loadUserRating() async {
    final rating = await _rankingService.getUserRating(widget.universeId);
    setState(() {
      _userRating = rating;
      _loading = false;
    });
  }

  Future<void> _setRating(int rating) async {
    setState(() => _loading = true);
    
    try {
      await _rankingService.saveRating(widget.universeId, rating);
      setState(() => _userRating = rating);
      widget.onRatingChanged?.call(rating);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✨ Note enregistrée : $rating/5'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur : $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Texte indicatif
          Text(
            _userRating == null 
                ? 'Tapote pour noter cet univers' 
                : 'Ta note : $_userRating/5',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          
          // Rangée d'étoiles
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final isFilled = _userRating != null && starValue <= _userRating!;
              
              return GestureDetector(
                onTap: () => _setRating(starValue),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    isFilled ? Icons.star : Icons.star_border,
                    size: 48,  // Gros pour enfants
                    color: isFilled ? Colors.amber : Colors.grey[400],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
````

#### Intégration dans SlideshowPage (Nowa)

````dart
// ...existing code...

class _SlideshowPageState extends State<SlideshowPage> {
  // ...existing code...
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...existing code...
      body: Stack(
        children: [
          // ...existing code (PageView avec slides)...
          
          // NOUVEAU : Widget de notation en bas
          Positioned(
            bottom: 100,  // Au-dessus du texte du slide
            left: 20,
            right: 20,
            child: RatingStarsWidget(
              universeId: widget.universe.id,
              initialRating: 0,  // Sera remplacé par la note moyenne si disponible
              onRatingChanged: (rating) {
                // Optionnel : refresh du classement en HomePage
                print('Nouvelle note : $rating');
              },
            ),
          ),
        ],
      ),
    );
  }
}
````

---

## 5. Système d'abonnements (RevenueCat)

### 5.1 Principe général des In-App Purchases

#### Contraintes des stores

| Store | Politique | Commission |
|-------|-----------|------------|
| **Apple App Store** | IAP obligatoire pour contenu numérique | 30% (15% si < $1M/an) |
| **Google Play Store** | IAP obligatoire depuis 2022 | 30% (15% si < $1M/an) |

#### Pourquoi RevenueCat ?

✅ **Un seul SDK** pour iOS + Android  
✅ **Dashboard unifié** (analytics, churn, MRR)  
✅ **Webhooks automatiques** vers Supabase  
✅ **Gratuit** jusqu'à $10k/mois de revenu  
✅ **Support sandbox** pour tests sans paiements réels  

---

### 5.2 Configuration RevenueCat (étape par étape)

#### Étape 1 : Créer un compte RevenueCat

1. Va sur https://www.revenuecat.com/
2. Crée un compte gratuit
3. Crée un nouveau projet : **"Univers App"**
4. Note ta **Public API Key** (Dashboard → API Keys)

#### Étape 2 : Configurer les produits dans App Store Connect (iOS)

````
1. Ouvre App Store Connect (https://appstoreconnect.apple.com/)
2. Va dans "My Apps" → Sélectionne ton app
3. Features → In-App Purchases → "+" (Créer)

Pour chaque produit :

┌─────────────────────────────────────────────────────┐
│ Produit 1 : Abonnement mensuel                       │
├─────────────────────────────────────────────────────┤
│ Type : Auto-Renewable Subscription                   │
│ Reference Name : Monthly Premium                     │
│ Product ID : univers_monthly                         │
│ Subscription Group : Univers Subscriptions           │
│ Subscription Duration : 1 month                      │
│ Price : 4,99 €                                       │
│ Localisations :                                      │
│   - FR : Accès illimité mensuel                     │
│   - EN : Monthly Unlimited Access                    │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Produit 2 : Abonnement annuel                        │
├─────────────────────────────────────────────────────┤
│ Type : Auto-Renewable Subscription                   │
│ Reference Name : Yearly Premium                      │
│ Product ID : univers_yearly                          │
│ Subscription Group : Univers Subscriptions           │
│ Subscription Duration : 1 year                       │
│ Price : 39,99 € (= 2 mois gratuits)                 │
│ Localisations : idem mensuel                         │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Produit 3 : Achat unique (lifetime)                  │
├─────────────────────────────────────────────────────┤
│ Type : Non-Consumable                                │
│ Reference Name : Lifetime Premium                    │
│ Product ID : univers_lifetime                        │
│ Price : 99,99 €                                      │
│ Localisations :                                      │
│   - FR : Accès à vie                                │
│   - EN : Lifetime Access                             │
└─────────────────────────────────────────────────────┘

4. Créer un Sandbox Tester (Users and Access → Sandbox Testers)
   → Email : test@example.com
   → Permet de tester les achats sans payer
````

#### Étape 3 : Configurer les produits dans Google Play Console (Android)

````
1. Ouvre Google Play Console (https://play.google.com/console/)
2. Sélectionne ton app → Monetize → Products → Subscriptions

⚠️ IMPORTANT : Utilise les MÊMES Product IDs que iOS !

┌─────────────────────────────────────────────────────┐
│ Produit 1 : univers_monthly                          │
├─────────────────────────────────────────────────────┤
│ Name : Monthly Premium                               │
│ ID : univers_monthly (identique iOS)                │
│ Billing period : 1 month                             │
│ Price : 4,99 €                                       │
│ Free trial : 7 days (optionnel)                     │
│ Grace period : 3 days (renouvellement échoué)       │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Produit 2 : univers_yearly                           │
├─────────────────────────────────────────────────────┤
│ Idem mais Billing period = 1 year                   │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Produit 3 : univers_lifetime                         │
├─────────────────────────────────────────────────────┤
│ Type : Non-consumable (In-app product)              │
│ ID : univers_lifetime                                │
│ Price : 99,99 €                                      │
└─────────────────────────────────────────────────────┘

3. Lier un compte bancaire (Setup → Merchant account)
4. Créer une License Tester List pour tests sandbox
````

#### Étape 4 : Lier les stores à RevenueCat

##### iOS (App Store Connect)

````
1. Dashboard RevenueCat → Apps → "+ New" → iOS
2. Bundle ID : com.example.univers (celui dans Info.plist)
3. Service Credentials :
   
   a) Générer une API Key dans App Store Connect :
      - Users and Access → Keys → App Store Connect API
      - "+" → Name : RevenueCat → Access : App Manager
      - Télécharger le fichier .p8
   
   b) Dans RevenueCat :
      - Coller Issuer ID (en haut de la page Keys)
      - Coller Key ID (colonne KEY ID)
      - Upload fichier .p8

4. Shared Secret (pour anciennes validations) :
   - App Store Connect → My Apps → App → App Information
   - Copier le Shared Secret
   - Coller dans RevenueCat → Shared Secret

5. Save → RevenueCat synchronise automatiquement les produits
````

##### Android (Google Play Console)

````
1. Dashboard RevenueCat → Apps → "+ New" → Android
2. Package Name : com.example.univers (celui dans AndroidManifest.xml)
3. Service Credentials (JSON) :

   a) Créer un Service Account dans Google Cloud :
      - Va sur https://console.cloud.google.com/
      - Sélectionne le projet lié à Play Console
      - IAM & Admin → Service Accounts → "Create Service Account"
      - Name : revenuecat-service
      - Role : Pub/Sub Admin (pour les webhooks)
      - "Create Key" → JSON → Download
   
   b) Lier le Service Account à Play Console :
      - Google Play Console → Users and permissions → Invite user
      - Email : celui du Service Account
      - Permissions : Admin (Financial data + App information)
   
   c) Dans RevenueCat :
      - Upload le fichier JSON téléchargé

4. Save → RevenueCat synchronise automatiquement les produits
````

#### Étape 5 : Créer les Offerings dans RevenueCat

````
Les Offerings = groupes de produits affichés ensemble dans l'app

Dashboard RevenueCat → Offerings → "+ New Offering"

┌─────────────────────────────────────────────────────┐
│ Offering ID : default                                │
│ Description : Offre principale                       │
│                                                      │
│ Packages (ordre d'affichage) :                      │
│ ┌─────────────────────────────────────────────────┐│
│ │ 1. Package : yearly                              ││
│ │    → Produit : univers_yearly                    ││
│ │    → Badge : "MEILLEURE OFFRE" 🏆               ││
│ └─────────────────────────────────────────────────┘│
│ ┌─────────────────────────────────────────────────┐│
│ │ 2. Package : monthly                             ││
│ │    → Produit : univers_monthly                   ││
│ └─────────────────────────────────────────────────┘│
│ ┌─────────────────────────────────────────────────┐│
│ │ 3. Package : lifetime                            ││
│ │    → Produit : univers_lifetime                  ││
│ │    → Badge : "ACCÈS À VIE" ♾️                   ││
│ └─────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────┘

Save → L'app Flutter récupérera ces packages automatiquement
````

---

### 5.3 Intégration Flutter (SDK RevenueCat)

#### Installation du package

````yaml
dependencies:
  purchases_flutter: ^6.29.0  # SDK RevenueCat officiel
  supabase_flutter: ^2.0.0
````

#### Initialisation dans main.dart

````dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Init Supabase
  await Supabase.initialize(
    url: 'https://VOTRE_PROJET.supabase.co',
    anonKey: 'VOTRE_ANON_KEY',
  );
  
  // 2. Auth anonyme si pas de session
  final supabase = Supabase.instance.client;
  if (supabase.auth.currentUser == null) {
    await supabase.auth.signInAnonymously();
    
    // Créer abonnement par défaut (free)
    await supabase.from('subscriptions').insert({
      'user_id': supabase.auth.currentUser!.id,
      'subscription_type': 'free',
      'is_paid': false,
    });
  }
  
  // 3. Init RevenueCat avec user_id Supabase
  await Purchases.configure(
    PurchasesConfiguration('VOTRE_REVENUECAT_PUBLIC_KEY')
      ..appUserID = supabase.auth.currentUser!.id  // ⚠️ Critique pour webhook
      ..observerMode = false,  // RevenueCat gère les achats
  );
  
  runApp(MyApp());
}
````

#### Service d'abonnement

````dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../models/subscription.dart';
import '../models/universe.dart';

class SubscriptionService {
  final _supabase = Supabase.instance.client;

  /// Récupère l'abonnement actuel de l'utilisateur
  Future<Subscription?> getCurrentSubscription() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _supabase
        .from('subscriptions')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return Subscription.fromJson(response);
  }

  /// Vérifie si l'utilisateur peut accéder à un univers
  Future<bool> canAccessUniverse(Universe universe) async {
    // Si univers gratuit → accès direct
    if (universe.isFree) return true;

    // Sinon, vérifier l'abonnement
    final sub = await getCurrentSubscription();
    if (sub == null || !sub.isPaid) return false;

    // Lifetime → toujours actif
    if (sub.subscriptionType == 'lifetime') return true;

    // Vérifier date d'expiration
    if (sub.expiresAt == null) return false;
    return DateTime.now().isBefore(sub.expiresAt!);
  }

  /// Récupère les offres disponibles depuis RevenueCat
  Future<List<Package>> getAvailablePackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current?.availablePackages ?? [];
    } catch (e) {
      print('Erreur récupération offres : $e');
      return [];
    }
  }

  /// Achète un package (monthly/yearly/lifetime)
  Future<bool> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      
      // Vérifie si l'achat a donné des droits actifs
      final hasActiveEntitlement = customerInfo.entitlements.active.isNotEmpty;
      
      if (hasActiveEntitlement) {
        // Le webhook RevenueCat mettra à jour Supabase automatiquement
        // Mais on peut refresh local immédiatement
        await _refreshLocalSubscription();
      }
      
      return hasActiveEntitlement;
    } on PlatformException catch (e) {
      // Codes d'erreur RevenueCat :
      // - 1 : User cancelled
      // - 2 : Store problem
      // - 3 : Purchase not allowed
      print('Erreur achat : ${e.code} - ${e.message}');
      return false;
    }
  }

  /// Restaure les achats précédents (si réinstallation)
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      await _refreshLocalSubscription();
      return customerInfo.entitlements.active.isNotEmpty;
    } catch (e) {
      print('Erreur restauration : $e');
      return false;
    }
  }

  /// Synchronise l'état local depuis RevenueCat (backup du webhook)
  Future<void> _refreshLocalSubscription() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlements = customerInfo.entitlements.active;

      if (entitlements.isEmpty) {
        // Aucun abonnement actif → reset à free
        await _supabase.from('subscriptions').update({
          'subscription_type': 'free',
          'is_paid': false,
        }).eq('user_id', userId);
        return;
      }

      // Récupère le premier entitlement actif
      final entitlement = entitlements.values.first;
      final productId = entitlement.productIdentifier;
      
      String subType = 'monthly';
      if (productId.contains('yearly')) subType = 'yearly';
      if (productId.contains('lifetime')) subType = 'lifetime';

      await _supabase.from('subscriptions').update({
        'subscription_type': subType,
        'is_paid': true,
        'expires_at': entitlement.expirationDate,
        'revenuecat_customer_id': customerInfo.originalAppUserId,
      }).eq('user_id', userId);
    } catch (e) {
      print('Erreur refresh subscription : $e');
    }
  }
}
````

---

### 5.4 Custom Widget : Page d'abonnements

````dart
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/subscription_service.dart';

/// Page d'abonnements (affiche les 3 formules)
/// Design enfants : gros boutons colorés, badges visuels
class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final _subscriptionService = SubscriptionService();
  List<Package> _packages = [];
  bool _loading = true;
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    final packages = await _subscriptionService.getAvailablePackages();
    setState(() {
      _packages = packages;
      _loading = false;
    });
  }

  Future<void> _handlePurchase(Package package) async {
    setState(() => _purchasing = true);
    
    final success = await _subscriptionService.purchasePackage(package);
    
    setState(() => _purchasing = false);

    if (!mounted) return;

    if (success) {
      // Afficher message de succès + fermer la page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('✨ Abonnement activé !', 
                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pop(context, true);  // true = abonnement activé
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Achat annulé ou erreur'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _purchasing = true);
    final success = await _subscriptionService.restorePurchases();
    setState(() => _purchasing = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success 
            ? '✅ Achats restaurés !' 
            : 'ℹ️ Aucun achat précédent trouvé'),
        backgroundColor: success ? Colors.green : Colors.grey,
      ),
    );

    if (success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('Abonnements', 
                    style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          // Bouton "Restaurer les achats"
          TextButton(
            onPressed: _purchasing ? null : _handleRestore,
            child: Text('Restaurer', 
                        style: TextStyle(color: Colors.blue, fontSize: 14)),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _purchasing
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text('Traitement de l\'achat...',
                           style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // En-tête explicatif
                      _buildHeader(),
                      SizedBox(height: 30),
                      
                      // Liste des packages
                      ..._packages.map((package) => Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: _buildPackageCard(package),
                      )),
                      
                      SizedBox(height: 20),
                      
                      // Mentions légales
                      _buildLegalText(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.deepPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.stars, size: 60, color: Colors.amber),
          SizedBox(height: 12),
          Text(
            'Débloque tous les univers !',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Accède à + de 50 univers magiques',
            style: TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(Package package) {
    final product = package.storeProduct;
    final isYearly = product.identifier.contains('yearly');
    final isLifetime = product.identifier.contains('lifetime');

    // Badge personnalisé
    String badge = '';
    Color badgeColor = Colors.blue;
    if (isYearly) {
      badge = '🏆 MEILLEURE OFFRE';
      badgeColor = Colors.orange;
    } else if (isLifetime) {
      badge = '♾️ ACCÈS À VIE';
      badgeColor = Colors.purple;
    }

    return GestureDetector(
      onTap: () => _handlePurchase(package),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isYearly ? Colors.orange : Colors.grey.shade300,
            width: isYearly ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge si applicable
            if (badge.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            
            SizedBox(height: 12),
            
            // Titre du produit
            Text(
              product.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            SizedBox(height: 8),
            
            // Description
            Text(
              product.description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            
            SizedBox(height: 16),
            
            // Prix + bouton
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.priceString,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                
                ElevatedButton(
                  onPressed: () => _handlePurchase(package),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isYearly ? Colors.orange : Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Choisir',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalText() {
    return Text(
      'Les abonnements se renouvellent automatiquement. '
      'Annule à tout moment depuis les paramètres de ton store. '
      'Voir nos Conditions Générales pour plus d\'infos.',
      style: TextStyle(fontSize: 12, color: Colors.grey),
      textAlign: TextAlign.center,
    );
  }
}
````

---

## 6. Implémentation Flutter étape par étape

### 6.1 Checklist d'implémentation (ordre recommandé)

````
✅ 1. Configuration Supabase
   ├─ Créer tables : ratings, subscriptions
   ├─ Modifier table universes (ajouter is_free)
   ├─ Configurer RLS policies
   └─ Marquer 3 premiers univers comme gratuits

✅ 2. Configuration RevenueCat
   ├─ Créer compte RevenueCat
   ├─ Configurer produits iOS (App Store Connect)
   ├─ Configurer produits Android (Google Play Console)
   ├─ Lier les stores à RevenueCat
   └─ Créer Offering "default"

✅ 3. Code Flutter (services)
   ├─ Installer packages (pubspec.yaml)
   ├─ Init Supabase + RevenueCat (main.dart)
   ├─ Créer RankingService (ranking_service.dart)
   ├─ Créer SubscriptionService (subscription_service.dart)
   └─ Créer modèles Dart (rating.dart, subscription.dart)

✅ 4. Custom Widgets
   ├─ RatingStarsWidget (notation par étoiles)
   └─ SubscriptionPage (page d'abonnements)

✅ 5. Intégration dans pages existantes
   ├─ HomePage : afficher badge 🔒 si univers premium
   ├─ HomePage : vérifie accès avant d'ouvrir SlideshowPage
   ├─ SlideshowPage : ajouter RatingStarsWidget en bas
   └─ Popup d'upgrade si univers verrouillé

✅ 6. Webhook Supabase (optionnel mais recommandé)
   ├─ Créer Edge Function revenuecat-webhook
   ├─ Configurer URL dans RevenueCat
   └─ Tester avec sandbox purchases

✅ 7. Tests
   ├─ Test sandbox iOS (Sandbox Tester)
   ├─ Test sandbox Android (License Tester)
   ├─ Test restauration achats
   └─ Test expiration abonnement

✅ 8. Déploiement
   ├─ Soumettre app à App Store Connect (review)
   ├─ Soumettre app à Google Play Console (beta)
   └─ Passer RevenueCat en mode production
````

---

### 6.2 Modification HomePage (vérification accès)

````dart
import '../services/subscription_service.dart';
import '../widgets/subscription_page.dart';

class _HomePageState extends State<HomePage> {
  final _subscriptionService = SubscriptionService();
  
  // ...existing code...

  Future<void> _handleUniverseTap(Universe universe) async {
    // Vérifie l'accès
    final canAccess = await _subscriptionService.canAccessUniverse(universe);
    
    if (!mounted) return;

    if (canAccess) {
      // Ouvre SlideshowPage normalement
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SlideshowPage(universe: universe),
        ),
      );
    } else {
      // Affiche popup d'upgrade
      _showUpgradeDialog(universe);
    }
  }

  void _showUpgradeDialog(Universe universe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.lock, color: Colors.orange, size: 30),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Univers verrouillé',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cet univers est réservé aux abonnés.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              '✨ Débloquer + de 50 univers magiques !',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Plus tard', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Ouvre la page d'abonnements
              final subscribed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => SubscriptionPage()),
              );
              
              // Si abonnement activé, refresh la page
              if (subscribed == true) {
                setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'S\'abonner',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...existing code...
      body: GridView.builder(
        // ...existing code...
        itemBuilder: (context, index) {
          final universe = _universes[index];
          
          return GestureDetector(
            onTap: () => _handleUniverseTap(universe),
            child: Stack(
              children: [
                // ...existing code (image de fond)...
                
                // Badge 🔒 si univers premium
                if (!universe.isFree)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock,
                        color: Colors.amber,
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
````

---

## 7. Webhooks et synchronisation

### 7.1 Edge Function Supabase (automatisation)

#### Créer la fonction

````bash
# Dans le terminal (à la racine du projet)
npx supabase functions new revenuecat-webhook
````

#### Code de la fonction

````typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    // Init Supabase avec service_role (bypass RLS)
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // Parse l'event RevenueCat
    const event = await req.json()
    console.log('Event RevenueCat reçu :', event.type)

    const eventType = event.type
    const eventData = event.event

    // Événements à traiter
    const purchaseEvents = [
      'INITIAL_PURCHASE',      // Premier achat
      'RENEWAL',               // Renouvellement
      'NON_RENEWING_PURCHASE', // Achat unique (lifetime)
    ]

    const cancellationEvents = [
      'CANCELLATION',          // Annulation
      'EXPIRATION',            // Expiration
      'BILLING_ISSUE',         // Problème paiement
    ]

    if (purchaseEvents.includes(eventType)) {
      // ✅ Activer l'abonnement
      const { app_user_id, product_id, expiration_at_ms } = eventData

      // Détermine le type d'abonnement depuis product_id
      let subscriptionType = 'monthly'
      if (product_id.includes('yearly')) subscriptionType = 'yearly'
      if (product_id.includes('lifetime')) subscriptionType = 'lifetime'

      // Update ou insert dans subscriptions
      const { error } = await supabase
        .from('subscriptions')
        .upsert({
          user_id: app_user_id,
          subscription_type: subscriptionType,
          is_paid: true,
          starts_at: new Date().toISOString(),
          expires_at: subscriptionType === 'lifetime' 
            ? null 
            : new Date(expiration_at_ms).toISOString(),
          revenuecat_customer_id: eventData.original_app_user_id,
        }, { onConflict: 'user_id' })

      if (error) throw error

      console.log(`✅ Abonnement activé pour user ${app_user_id}`)
      
    } else if (cancellationEvents.includes(eventType)) {
      // ❌ Désactiver l'abonnement
      const { app_user_id } = eventData

      const { error } = await supabase
        .from('subscriptions')
        .update({
          subscription_type: 'free',
          is_paid: false,
          expires_at: null,
        })
        .eq('user_id', app_user_id)

      if (error) throw error

      console.log(`❌ Abonnement désactivé pour user ${app_user_id}`)
    }

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    })
    
  } catch (error) {
    console.error('Erreur webhook :', error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    })
  }
})
````

#### Déployer la fonction

````bash
# Deploy sur Supabase
npx supabase functions deploy revenuecat-webhook

# Note l'URL générée (exemple) :
# https://VOTRE_PROJET.supabase.co/functions/v1/revenuecat-webhook
````

---

### 7.2 Configuration webhook dans RevenueCat

````
1. Dashboard RevenueCat → Settings → Integrations → Webhooks
2. "+ Add Webhook"
   ┌─────────────────────────────────────────────────────┐
   │ URL : https://VOTRE_PROJET.supabase.co/functions/   │
   │       v1/revenuecat-webhook                          │
   │                                                      │
   │ Authorization Header (optionnel pour sécurité) :    │
   │   Bearer VOTRE_SUPABASE_ANON_KEY                    │
   │                                                      │
   │ Events to send :                                    │
   │   ☑️ INITIAL_PURCHASE                               │
   │   1. Dashboard RevenueCat → Settings → Integrations → Webhooks
2. "+ Add Webhook"
   ┌─────────────────────────────────────────────────────┐
   │ URL : https://VOTRE_PROJET.supabase.co/functions/   │
   │       v1/revenuecat-webhook                          │
   │                                                      │
   │ Authorization Header (optionnel pour sécurité) :    │
   │   Bearer VOTRE_SUPABASE_ANON_KEY                    │
   │                                                      │
   │ Events to send :                                    │
   │   ☑️ INITIAL_PURCHASE                               │
   │   

th1zan: continue

GitHub Copilot: # 📘 Guide complet – Gestion utilisateurs + Ranking + Paiements RevenueCat

**Projet Univers – Documentation d'implémentation complète**  
*Version 1.0 – Décembre 2024*

---

## 📋 Table des matières

1. Vue d'ensemble du système
2. Architecture de la solution
3. Configuration Supabase
4. Configuration RevenueCat
5. Implémentation Flutter
6. Webhooks et synchronisation
7. Tests et validation
8. Checklist de déploiement

---

## 1. Vue d'ensemble du système

### 🎯 Objectifs fonctionnels

L'application nécessite 3 fonctionnalités interconnectées :

1. **Authentification anonyme** : Chaque utilisateur reçoit un UUID unique sans email/mot de passe
2. **Système de notation** : Les utilisateurs peuvent noter les univers (1-5 étoiles) et voir un classement
3. **Abonnements premium** : Certains univers sont gratuits, d'autres nécessitent un abonnement payant

### 🔄 Flow utilisateur complet

```
┌─────────────────────────────────────────────────────────────┐
│  Premier lancement de l'app                                 │
└───────────────┬─────────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────┐
│  Création automatique d'un compte anonyme                   │
│  → Supabase génère un UUID stocké localement                │
└───────────────┬─────────────────────────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────────────────────────┐
│  HomePage : Liste des univers                               │
│  → Fetch universes + subscription de l'utilisateur          │
│  → Badge 🔒 sur univers premium si pas d'abonnement         │
└───────────────┬─────────────────────────────────────────────┘
                │
                ├──────────────┬───────────────────────┐
                │              │                       │
                ▼              ▼                       ▼
    ┌──────────────┐  ┌──────────────┐    ┌──────────────────┐
    │ Univers      │  │ Univers      │    │ Univers premium  │
    │ gratuit      │  │ gratuit      │    │ (bloqué)         │
    │ → Accès OK   │  │ → Accès OK   │    │ → Popup upgrade  │
    └──────┬───────┘  └──────┬───────┘    └────────┬─────────┘
           │                 │                      │
           ▼                 ▼                      ▼
    ┌──────────────────────────────┐    ┌──────────────────────┐
    │ SlideshowPage                │    │ SubscriptionPage     │
    │ → Swipe entre images         │    │ → Choix formule      │
    │ → Widget de notation ⭐⭐⭐⭐⭐│    │ → Paiement RevenueCat│
    │ → Save dans table ratings    │    └──────────┬───────────┘
    └──────────────────────────────┘               │
                                                   ▼
                                        ┌──────────────────────┐
                                        │ Webhook RevenueCat   │
                                        │ → Update Supabase    │
                                        │ → Unlock premium     │
                                        └──────────────────────┘
```

### 🏗️ Stack technique

| Composant | Technologie | Rôle |
|-----------|-------------|------|
| **Frontend** | Flutter (Nowa) | Interface utilisateur |
| **Backend** | Supabase | Base de données + Auth + Edge Functions |
| **Paiements** | RevenueCat | Gestion IAP iOS/Android + Webhooks |
| **Stores** | App Store Connect + Google Play Console | Distribution + produits IAP |

---

## 2. Architecture de la solution

### 🗂️ Schéma de base de données

```
┌─────────────────────────────────────────────────────────────┐
│  auth.users (table Supabase native)                         │
│  ───────────────────────────────────────────────────────    │
│  id (uuid, PK)                                              │
│  is_anonymous (boolean)  ← true pour nos users              │
│  created_at (timestamptz)                                   │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  │ (Relations vers nos tables custom)
                  │
    ┌─────────────┴─────────────┬─────────────────────────┐
    │                           │                         │
    ▼                           ▼                         ▼
┌────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│  subscriptions │    │     ratings      │    │    universes     │
│  ────────────  │    │  ──────────────  │    │  ──────────────  │
│  id (uuid)     │    │  id (uuid)       │    │  id (uuid)       │
│  user_id ───────────│  user_id ────────┼────│  name (text)     │
│  type (text)   │    │  universe_id ─────────│  cover_image_url │
│  is_paid (bool)│    │  rating (int 1-5)│    │  is_free (bool)  │
│  expires_at    │    │  created_at      │    │  order (int)     │
└────────────────┘    └──────────────────┘    └──────────────────┘
                               │
                               │ (Contrainte unique)
                               └─► UNIQUE(user_id, universe_id)
```

### 🔐 Flux d'authentification

```dart
// Pseudo-code du flow
1. App démarre
   ├─ SharedPreferences.getString('user_id')
   │  ├─ Si null → supabase.auth.signInAnonymously()
   │  │           └─ Stocker user.id localement
   │  └─ Si existe → supabase.auth.recoverSession()
   └─ user.id est maintenant disponible pour toute l'app
```

### 💰 Flux de paiement

```
1. User clique "S'abonner"
   ├─ App → RevenueCat.purchasePackage('monthly')
   │
2. RevenueCat gère le dialogue natif iOS/Android
   ├─ StoreKit (iOS) ou Google Play Billing (Android)
   │
3. Paiement validé par le store
   ├─ RevenueCat reçoit confirmation
   │
4. RevenueCat envoie webhook à Supabase Edge Function
   ├─ Payload : { user_id, product_id, expiration_date }
   │
5. Edge Function update table subscriptions
   ├─ SET is_paid = true, expires_at = ...
   │
6. App refresh subscription status
   └─ Unlock univers premium ✅
```

---

## 3. Configuration Supabase

### 📊 Étape 1 : Créer les tables

#### 3.1 Modifier la table `universes` existante

```sql
-- Ajouter la colonne is_free pour distinguer gratuit/premium
ALTER TABLE universes 
ADD COLUMN is_free boolean DEFAULT false;

-- Mettre à jour les univers existants (exemple)
UPDATE universes SET is_free = true WHERE name IN ('Espace', 'Océan');
```

#### 3.2 Créer la table `ratings`

```sql
-- Table pour stocker les notes des utilisateurs
CREATE TABLE ratings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Lien vers l'utilisateur (auth.users)
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Lien vers l'univers noté
  universe_id uuid NOT NULL REFERENCES universes(id) ON DELETE CASCADE,
  
  -- Note de 1 à 5 étoiles
  rating int NOT NULL CHECK (rating >= 1 AND rating <= 5),
  
  -- Date de création
  created_at timestamptz DEFAULT now(),
  
  -- Contrainte : un user ne peut noter qu'une fois le même univers
  CONSTRAINT unique_user_universe UNIQUE(user_id, universe_id)
);

-- Index pour optimiser les requêtes de classement
CREATE INDEX idx_ratings_universe ON ratings(universe_id);
CREATE INDEX idx_ratings_user ON ratings(user_id);

-- Row Level Security (RLS)
ALTER TABLE ratings ENABLE ROW LEVEL SECURITY;

-- Politique : un user peut voir toutes les notes (pour le classement)
CREATE POLICY "Ratings are viewable by everyone"
  ON ratings FOR SELECT
  USING (true);

-- Politique : un user peut créer/modifier uniquement SES notes
CREATE POLICY "Users can insert their own ratings"
  ON ratings FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own ratings"
  ON ratings FOR UPDATE
  USING (auth.uid() = user_id);
```

#### 3.3 Créer la table `subscriptions`

```sql
-- Table pour gérer les abonnements utilisateurs
CREATE TABLE subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Lien vers l'utilisateur (un user = un abonnement max)
  user_id uuid UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Type d'abonnement
  subscription_type text NOT NULL 
    CHECK (subscription_type IN ('free', 'monthly', 'yearly', 'lifetime')),
  
  -- Statut de paiement
  is_paid boolean DEFAULT false,
  
  -- Date de début
  starts_at timestamptz,
  
  -- Date d'expiration (NULL pour lifetime)
  expires_at timestamptz,
  
  -- Métadonnées
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Index pour vérifier rapidement l'accès premium
CREATE INDEX idx_subscriptions_user_paid ON subscriptions(user_id, is_paid);

-- Row Level Security (RLS)
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- Politique : un user voit uniquement SON abonnement
CREATE POLICY "Users can view their own subscription"
  ON subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- Politique : seuls les webhooks/service_role peuvent écrire
CREATE POLICY "Only service role can insert/update subscriptions"
  ON subscriptions FOR ALL
  USING (auth.role() = 'service_role');
```

#### 3.4 Créer une vue pour le classement des univers

```sql
-- Vue matérialisée pour optimiser les performances du classement
CREATE MATERIALIZED VIEW universe_rankings AS
SELECT 
  u.id,
  u.name,
  u.cover_image_url,
  u.is_free,
  COALESCE(AVG(r.rating), 0) as avg_rating,
  COUNT(r.id) as rating_count
FROM universes u
LEFT JOIN ratings r ON r.universe_id = u.id
GROUP BY u.id, u.name, u.cover_image_url, u.is_free
ORDER BY avg_rating DESC NULLS LAST, rating_count DESC;

-- Index sur la vue
CREATE UNIQUE INDEX idx_universe_rankings_id ON universe_rankings(id);

-- Fonction pour rafraîchir la vue (à appeler après chaque nouvelle note)
CREATE OR REPLACE FUNCTION refresh_universe_rankings()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY universe_rankings;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 🔧 Étape 2 : Configurer l'authentification anonyme

Dans le dashboard Supabase :

1. **Authentication** → **Settings**
2. **Enable Anonymous Sign-ins** → ✅ Activer
3. **Site URL** → Ajouter ton URL (ex: `com.univers.app://`)
4. **Redirect URLs** → Idem

---

## 4. Configuration RevenueCat

### 🚀 Étape 1 : Créer un compte RevenueCat

1. Aller sur https://www.revenuecat.com/
2. S'inscrire (gratuit jusqu'à 10 000 $/mois de revenus)
3. Créer un nouveau projet : **"Univers"**
4. Récupérer la **Public API Key** :
   - Dashboard → **API Keys** → Copier `public_key_ios` et `public_key_android`

### 📱 Étape 2 : Créer les produits dans les stores

#### 2.1 App Store Connect (iOS)

```
1. Se connecter à https://appstoreconnect.apple.com/
2. My Apps → [Créer une nouvelle app si nécessaire]
3. Features → In-App Purchases → Manage
4. Créer 3 produits :

┌────────────────────────────────────────────────────────────┐
│  Produit 1 : Abonnement mensuel                            │
│  ──────────────────────────────────────────────────────    │
│  Type : Auto-Renewable Subscription                        │
│  Reference Name : Univers Monthly                          │
│  Product ID : com.univers.monthly                          │
│  Subscription Group : univers_premium                      │
│  Duration : 1 Month                                        │
│  Price : 4,99 € (ou ton prix)                             │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│  Produit 2 : Abonnement annuel                             │
│  ──────────────────────────────────────────────────────    │
│  Type : Auto-Renewable Subscription                        │
│  Reference Name : Univers Yearly                           │
│  Product ID : com.univers.yearly                           │
│  Subscription Group : univers_premium                      │
│  Duration : 1 Year                                         │
│  Price : 39,99 € (économie de ~30%)                       │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│  Produit 3 : Achat permanent                               │
│  ──────────────────────────────────────────────────────    │
│  Type : Non-Consumable                                     │
│  Reference Name : Univers Lifetime                         │
│  Product ID : com.univers.lifetime                         │
│  Price : 99,99 € (achat unique)                           │
└────────────────────────────────────────────────────────────┘

5. Pour chaque produit, ajouter :
   - Localisations (FR, EN minimum)
   - Screenshots de review (si demandé)
   - Status → Ready to Submit
```

#### 2.2 Google Play Console (Android)

```
1. Se connecter à https://play.google.com/console/
2. Sélectionner l'app (ou créer une nouvelle app)
3. Monetize → Products → Subscriptions → Create subscription
4. Créer les MÊMES produits avec les MÊMES IDs :

┌────────────────────────────────────────────────────────────┐
│  Produit 1 : Abonnement mensuel                            │
│  ──────────────────────────────────────────────────────    │
│  Product ID : com.univers.monthly                          │
│  Name : Univers Premium - Mensuel                          │
│  Billing period : Monthly                                  │
│  Base price : 4,99 €                                       │
│  Free trial : 7 days (optionnel)                           │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│  Produit 2 : Abonnement annuel                             │
│  ──────────────────────────────────────────────────────    │
│  Product ID : com.univers.yearly                           │
│  Name : Univers Premium - Annuel                           │
│  Billing period : Yearly                                   │
│  Base price : 39,99 €                                      │
└────────────────────────────────────────────────────────────┘

5. Pour l'achat permanent (lifetime), aller dans :
   Monetize → Products → In-app products → Create product

┌────────────────────────────────────────────────────────────┐
│  Produit 3 : Achat permanent                               │
│  ──────────────────────────────────────────────────────    │
│  Product ID : com.univers.lifetime                         │
│  Name : Univers Premium - À vie                            │
│  Price : 99,99 €                                           │
└────────────────────────────────────────────────────────────┘

6. Activer la facturation :
   - Aller dans Settings → Payments profile
   - Lier un compte bancaire (obligatoire)
   - Remplir les infos fiscales
```

### 🔗 Étape 3 : Lier les stores à RevenueCat

#### 3.1 Configuration iOS

```
1. Dans App Store Connect :
   - Users and Access → Keys → App Store Connect API
   - Créer une nouvelle clé avec rôle "Admin" ou "App Manager"
   - Télécharger le fichier .p8 (à ne pas perdre !)
   - Noter l'Issuer ID et Key ID

2. Dans le dashboard RevenueCat :
   - Apps → Add iOS App
   - App name : Univers iOS
   - Bundle ID : com.univers.app (ton bundle iOS)
   - App Store Connect API :
     ├─ Issuer ID : [copier depuis App Store Connect]
     ├─ Key ID : [copier depuis App Store Connect]
     └─ Private Key : [coller le contenu du fichier .p8]
   
3. RevenueCat synchronise automatiquement les produits
   - Attendre ~5 minutes
   - Vérifier dans Products → View Products
```

#### 3.2 Configuration Android

```
1. Dans Google Cloud Console :
   - Créer un Service Account :
     ├─ IAM & Admin → Service Accounts → Create Service Account
     ├─ Name : RevenueCat Android
     └─ Role : Pas de rôle (sera configuré dans Play Console)
   
   - Créer une clé JSON :
     ├─ Actions → Manage keys → Add Key → JSON
     └─ Télécharger le fichier .json

2. Dans Google Play Console :
   - Settings → API access → Link project (si pas déjà fait)
   - Service Accounts → Grant access au service account créé
   - Permissions :
     ├─ View financial data : ✅
     └─ Manage orders and subscriptions : ✅

3. Dans le dashboard RevenueCat :
   - Apps → Add Android App
   - App name : Univers Android
   - Package name : com.univers.app (ton package Android)
   - Google Play Service Account :
     └─ Upload le fichier .json téléchargé

4. RevenueCat synchronise les produits
   - Attendre ~5 minutes
   - Vérifier dans Products → View Products
```

### 📦 Étape 4 : Créer des Offerings (packs de produits)

Dans le dashboard RevenueCat :

```
1. Offerings → Create Offering
2. Identifier : default (important, c'est le nom par défaut dans le code)
3. Display name : Premium Access
4. Ajouter 3 packages :

┌────────────────────────────────────────────────────────────┐
│  Package 1 : MONTHLY                                       │
│  ──────────────────────────────────────────────────────    │
│  Identifier : $rc_monthly (obligatoire)                    │
│  Product : com.univers.monthly                             │
│  Platform : iOS + Android                                  │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│  Package 2 : ANNUAL                                        │
│  ──────────────────────────────────────────────────────    │
│  Identifier : $rc_annual (obligatoire)                     │
│  Product : com.univers.yearly                              │
│  Platform : iOS + Android                                  │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│  Package 3 : LIFETIME                                      │
│  ──────────────────────────────────────────────────────    │
│  Identifier : $rc_lifetime (obligatoire)                   │
│  Product : com.univers.lifetime                            │
│  Platform : iOS + Android                                  │
└────────────────────────────────────────────────────────────┘

5. Save et rendre Current
```

---

## 5. Implémentation Flutter

### 📦 Étape 1 : Ajouter les dépendances

````yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Dépendances existantes
  supabase_flutter: ^2.0.0
  
  # Nouvelles dépendances pour paiements
  purchases_flutter: ^6.29.0  # RevenueCat SDK
  
  # Pour stocker le user_id localement
  shared_preferences: ^2.2.2
````

Puis dans le terminal :
```bash
flutter pub get
```

### 🔐 Étape 2 : Service d'authentification

````dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service pour gérer l'authentification anonyme
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _userIdKey = 'univers_user_id';

  /// Initialise l'utilisateur (anonyme ou existant)
  Future<User?> initializeUser() async {
    try {
      // 1. Vérifier si on a déjà un user_id stocké localement
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString(_userIdKey);

      // 2. Vérifier si une session existe déjà
      final currentUser = _supabase.auth.currentUser;
      
      if (currentUser != null) {
        // Session active → vérifier si c'est le bon user
        if (storedUserId == null || storedUserId == currentUser.id) {
          await prefs.setString(_userIdKey, currentUser.id);
          return currentUser;
        }
      }

      // 3. Pas de session ou user différent → créer un compte anonyme
      final response = await _supabase.auth.signInAnonymously();
      final newUser = response.user;

      if (newUser != null) {
        await prefs.setString(_userIdKey, newUser.id);
        print('✅ Nouveau user anonyme créé : ${newUser.id}');
        
        // Créer l'abonnement gratuit par défaut
        await _createDefaultSubscription(newUser.id);
      }

      return newUser;
    } catch (e) {
      print('❌ Erreur initializeUser : $e');
      return null;
    }
  }

  /// Crée un abonnement gratuit par défaut pour un nouvel utilisateur
  Future<void> _createDefaultSubscription(String userId) async {
    try {
      await _supabase.from('subscriptions').insert({
        'user_id': userId,
        'subscription_type': 'free',
        'is_paid': false,
        'starts_at': DateTime.now().toIso8601String(),
      });
      print('✅ Abonnement gratuit créé pour $userId');
    } catch (e) {
      print('⚠️ Erreur création abonnement : $e');
    }
  }

  /// Récupère l'utilisateur actuel
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  /// Nettoie les données locales (pour tests uniquement)
  Future<void> clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await _supabase.auth.signOut();
  }
}
````

### ⭐ Étape 3 : Service de notation (ratings)

````dart
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modèle pour un rating
class Rating {
  final String id;
  final String userId;
  final String universeId;
  final int rating;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.userId,
    required this.universeId,
    required this.rating,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      userId: json['user_id'],
      universeId: json['universe_id'],
      rating: json['rating'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

/// Service pour gérer les notes des univers
class RatingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Récupère la note de l'utilisateur pour un univers
  Future<int?> getUserRating(String universeId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('ratings')
          .select('rating')
          .eq('user_id', userId)
          .eq('universe_id', universeId)
          .maybeSingle();

      return response?['rating'] as int?;
    } catch (e) {
      print('❌ Erreur getUserRating : $e');
      return null;
    }
  }

  /// Enregistre ou met à jour la note d'un univers
  Future<bool> setRating(String universeId, int rating) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('❌ User non connecté');
        return false;
      }

      // Upsert (insert ou update si existe déjà)
      await _supabase.from('ratings').upsert({
        'user_id': userId,
        'universe_id': universeId,
        'rating': rating,
      }, onConflict: 'user_id,universe_id');

      print('✅ Note enregistrée : $rating/5 pour univers $universeId');

      // Rafraîchir la vue matérialisée du classement
      await _refreshRankings();

      return true;
    } catch (e) {
      print('❌ Erreur setRating : $e');
      return false;
    }
  }

  /// Récupère le classement des univers
  Future<List<Map<String, dynamic>>> getRankings() async {
    try {
      final response = await _supabase
          .from('universe_rankings')
          .select('*')
          .order('avg_rating', ascending: false)
          .order('rating_count', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erreur getRankings : $e');
      return [];
    }
  }

  /// Rafraîchit la vue matérialisée des classements
  Future<void> _refreshRankings() async {
    try {
      await _supabase.rpc('refresh_universe_rankings');
    } catch (e) {
      print('⚠️ Erreur refresh rankings : $e');
    }
  }
}
````

### 💳 Étape 4 : Service d'abonnement (RevenueCat)

````dart
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modèle pour un abonnement
class Subscription {
  final String userId;
  final String subscriptionType; // 'free', 'monthly', 'yearly', 'lifetime'
  final bool isPaid;
  final DateTime? expiresAt;

  Subscription({
    required this.userId,
    required this.subscriptionType,
    required this.isPaid,
    this.expiresAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      userId: json['user_id'],
      subscriptionType: json['subscription_type'],
      isPaid: json['is_paid'],
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at']) 
          : null,
    );
  }

  /// Vérifie si l'abonnement donne accès au contenu premium
  bool get hasActiveAccess {
    if (!isPaid) return false;
    if (subscriptionType == 'lifetime') return true;
    if (expiresAt == null) return false;
    return DateTime.now().isBefore(expiresAt!);
  }
}

/// Service pour gérer les abonnements via RevenueCat
class SubscriptionService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // ⚠️ À REMPLACER par tes vraies clés RevenueCat
  static const String _revenueCatApiKeyIOS = 'YOUR_IOS_PUBLIC_KEY';
  static const String _revenueCatApiKeyAndroid = 'YOUR_ANDROID_PUBLIC_KEY';

  /// Initialise RevenueCat avec l'utilisateur Supabase
  Future<void> initialize() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('❌ User non connecté, RevenueCat non initialisé');
        return;
      }

      // Configuration RevenueCat
      final configuration = PurchasesConfiguration(_getApiKey())
        ..appUserID = userId  // Link au user Supabase
        ..observerMode = false;  // RevenueCat gère les transactions

      await Purchases.configure(configuration);
      print('✅ RevenueCat initialisé pour user $userId');
    } catch (e) {
      print('❌ Erreur init RevenueCat : $e');
    }
  }

  /// Récupère la clé API selon la plateforme
  String _getApiKey() {
    // À adapter selon ton système de détection de plateforme
    // Pour simplifier ici, on utilise la clé iOS par défaut
    // Tu peux utiliser dart:io pour détecter Platform.isIOS
    return _revenueCatApiKeyIOS;
  }

  /// Récupère l'abonnement actuel depuis Supabase
  Future<Subscription?> getCurrentSubscription() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('subscriptions')
          .select('*')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return Subscription.fromJson(response);
    } catch (e) {
      print('❌ Erreur getCurrentSubscription : $e');
      return null;
    }
  }

  /// Récupère les offres disponibles depuis RevenueCat
  Future<List<Package>> getAvailablePackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      final currentOffering = offerings.current;

      if (currentOffering == null || currentOffering.availablePackages.isEmpty) {
        print('⚠️ Aucune offre disponible');
        return [];
      }

      return currentOffering.availablePackages;
    } catch (e) {
      print('❌ Erreur getAvailablePackages : $e');
      return [];
    }
  }

  /// Lance l'achat d'un package
  Future<bool> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      
      // Vérifier si l'abonnement est actif
      final hasAccess = customerInfo.entitlements.active.isNotEmpty;
      
      if (hasAccess) {
        print('✅ Achat réussi : ${package.identifier}');
        // RevenueCat enverra un webhook à Supabase
        // Attendre 2 secondes puis refresh
        await Future.delayed(Duration(seconds: 2));
        return true;
      }
      
      return false;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        print('ℹ️ Achat annulé par l\'utilisateur');
      } else {
        print('❌ Erreur achat : ${e.message}');
      }
      return false;
    }
  }

  /// Restaure les achats précédents
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final hasAccess = customerInfo.entitlements.active.isNotEmpty;
      
      if (hasAccess) {
        print('✅ Achats restaurés');
        return true;
      } else {
        print('ℹ️ Aucun achat à restaurer');
        return false;
      }
    } catch (e) {
      print('❌ Erreur restorePurchases : $e');
      return false;
    }
  }

  /// Vérifie si un univers est accessible pour l'utilisateur
  Future<bool> canAccessUniverse(bool isFreeUniverse) async {
    // Si l'univers est gratuit, toujours accessible
    if (isFreeUniverse) return true;

    // Sinon, vérifier l'abonnement
    final subscription = await getCurrentSubscription();
    return subscription?.hasActiveAccess ?? false;
  }
}
````

### 🎨 Étape 5 : Custom Widget pour la notation

````dart
import 'package:flutter/material.dart';
import '../services/rating_service.dart';

/// Widget de notation avec étoiles (pour SlideshowPage)
class UniverseRatingWidget extends StatefulWidget {
  final String universeId;
  final RatingService ratingService;

  const UniverseRatingWidget({
    Key? key,
    required this.universeId,
    required this.ratingService,
  }) : super(key: key);

  @override
  State<UniverseRatingWidget> createState() => _UniverseRatingWidgetState();
}

class _UniverseRatingWidgetState extends State<UniverseRatingWidget> {
  int _currentRating = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRating();
  }

  Future<void> _loadUserRating() async {
    final rating = await widget.ratingService.getUserRating(widget.universeId);
    setState(() {
      _currentRating = rating ?? 0;
      _isLoading = false;
    });
  }

  Future<void> _setRating(int rating) async {
    setState(() => _currentRating = rating);
    
    final success = await widget.ratingService.setRating(
      widget.universeId,
      rating,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Note enregistrée : $rating/5'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur lors de l\'enregistrement'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Note cet univers :',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starRating = index + 1;
              return GestureDetector(
                onTap: () => _setRating(starRating),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    starRating <= _currentRating
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
````

### 💎 Étape 6 : Page d'abonnements (Custom Widget)

````dart
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/subscription_service.dart';

/// Page pour afficher les offres d'abonnement
class SubscriptionPage extends StatefulWidget {
  final SubscriptionService subscriptionService;

  const SubscriptionPage({
    Key? key,
    required this.subscriptionService,
  }) : super(key: key);

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  List<Package> _packages = [];
  bool _isLoading = true;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    final packages = await widget.subscriptionService.getAvailablePackages();
    setState(() {
      _packages = packages;
      _isLoading = false;
    });
  }

  Future<void> _purchase(Package package) async {
    setState(() => _isPurchasing = true);

    final success = await widget.subscriptionService.purchasePackage(package);

    setState(() => _isPurchasing = false);

    if (success && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('🎉 Bienvenue !'),
          content: Text('Ton abonnement est maintenant actif.\nTu as accès à tous les univers !'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la dialog
                Navigator.of(context).pop(); // Retour à HomePage
              },
              child: Text('Super !'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _restore() async {
    setState(() => _isPurchasing = true);

    final success = await widget.subscriptionService.restorePurchases();

    setState(() => _isPurchasing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
              ? '✅ Achats restaurés !' 
              : 'ℹ️ Aucun achat à restaurer'),
        ),
      );

      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  String _getPackageTitle(Package package) {
    if (package.identifier.contains('monthly')) return '📅 Mensuel';
    if (package.identifier.contains('annual')) return '📆 Annuel';
    if (package.identifier.contains('lifetime')) return '♾️ À vie';
    return package.storeProduct.title;
  }

  String _getPackageDescription(Package package) {
    if (package.identifier.contains('monthly')) {
      return 'Accès illimité pendant 1 mois\nRenouvellement automatique';
    }
    if (package.identifier.contains('annual')) {
      return 'Accès illimité pendant 1 an\nMeilleur rapport qualité/prix !';
    }
    if (package.identifier.contains('lifetime')) {
      return 'Accès illimité à vie\nAchat unique, pas d\'abonnement';
    }
    return package.storeProduct.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5DC), // Beige comme HomePage
      appBar: AppBar(
        title: Text(
          'Devenir Premium',
          style: TextStyle(
            fontFamily: 'ComicNeue',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFF5F5DC),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        actions: [
          TextButton(
            onPressed: _isPurchasing ? null : _restore,
            child: Text(
              'Restaurer',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                ListView(
                  padding: EdgeInsets.all(20),
                  children: [
                    // Header
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade300, Colors.blue.shade300],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '🌟 Débloquer tous les univers',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Accède à +20 univers exclusifs\navec des centaines d\'images',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 30),

                    // Liste des packages
                    ..._packages.map((package) {
                      final isPopular = package.identifier.contains('annual');
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          border: isPopular 
                              ? Border.all(color: Colors.amber, width: 3)
                              : null,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          child: InkWell(
                            onTap: _isPurchasing ? null : () => _purchase(package),
                            borderRadius: BorderRadius.circular(15),
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _getPackageTitle(package),
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (isPopular)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.amber,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '⭐ POPULAIRE',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    _getPackageDescription(package),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      height: 1.4,
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        package.storeProduct.priceString,
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.blue,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                    SizedBox(height: 20),

                    // Footer
                    Text(
                      'Les abonnements se renouvellent automatiquement.\nAnnule à tout moment dans les réglages du store.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                // Overlay de chargement
                if (_isPurchasing)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Traitement en cours...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
````

### 🚀 Étape 7 : Initialisation dans main.dart

````dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';
import 'services/subscription_service.dart';

// ...existing code...

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialiser Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  // 2. Initialiser l'utilisateur anonyme
  final authService = AuthService();
  await authService.initializeUser();

  // 3. Initialiser RevenueCat
  final subscriptionService = SubscriptionService();
  await subscriptionService.initialize();

  runApp(MyApp());
}

// ...existing code...
````

---

## 6. Webhooks et synchronisation

### 🔗 Étape 1 : Créer l'Edge Function Supabase

````typescript
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    // 1. Créer un client Supabase avec les droits admin
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    // 2. Parser le webhook de RevenueCat
    const event = await req.json()
    console.log('📥 Webhook reçu:', event.type)

    // 3. Gérer les différents types d'événements
    const eventType = event.type
    const { app_user_id, product_id, expiration_at_ms, is_trial_period } = event.event

    // Types d'événements à gérer :
    // - INITIAL_PURCHASE : premier achat
    // - RENEWAL : renouvellement automatique
    // - CANCELLATION : annulation
    // - EXPIRATION : expiration sans renouvellement

    if (eventType === 'INITIAL_PURCHASE' || eventType === 'RENEWAL') {
      // Détermine le type d'abonnement depuis le product_id
      let subscriptionType = 'monthly'
      if (product_id.includes('yearly') || product_id.includes('annual')) {
        subscriptionType = 'yearly'
      } else if (product_id.includes('lifetime')) {
        subscriptionType = 'lifetime'
      }

      // Calculer la date d'expiration
      const expiresAt = subscriptionType === 'lifetime' 
        ? null 
        : new Date(expiration_at_ms)

      // Upsert dans Supabase
      const { error } = await supabase
        .from('subscriptions')
        .upsert({
          user_id: app_user_id,
          subscription_type: subscriptionType,
          is_paid: true,
          starts_at: new Date(),
          expires_at: expiresAt,
          updated_at: new Date(),
        }, {
          onConflict: 'user_id'
        })

      if (error) {
        console.error('❌ Erreur Supabase:', error)
        return new Response(JSON.stringify({ error: error.message }), {
          status: 500,
          headers: { 'Content-Type': 'application/json' },
        })
      }

      console.log(`✅ Abonnement activé pour ${app_user_id}: ${subscriptionType}`)
    }

    else if (eventType === 'CANCELLATION' || eventType === 'EXPIRATION') {
      // Marquer l'abonnement comme expiré
      const { error } = await supabase
        .from('subscriptions')
        .update({
          is_paid: false,
          updated_at: new Date(),
        })
        .eq('user_id', app_user_id)

      if (error) {
        console.error('❌ Erreur Supabase:', error)
        return new Response(JSON.stringify({ error: error.message }), {
          status: 500,
          headers: { 'Content-Type': 'application/json' },
        })
      }

      console.log(`ℹ️ Abonnement désactivé pour ${app_user_id}`)
    }

    // 4. Répondre à RevenueCat
    return new Response(
      JSON.stringify({ received: true }),
      { 
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      }
    )

  } catch (error) {
    console.error('❌ Erreur webhook:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      }
    )
  }
})
````

### 🚀 Étape 2 : Déployer l'Edge Function

Dans le terminal, depuis la racine du projet :

```bash
# Installer Supabase CLI si pas déjà fait
npm install -g supabase

# Login
supabase login

# Link au projet
supabase link --project-ref YOUR_PROJECT_REF

# Déployer la function
supabase functions deploy revenuecat-webhook --no-verify-jwt

# Récupérer l'URL de la function
# Format: https://YOUR_PROJECT_REF.supabase.co/functions/v1/revenuecat-webhook
```

### ⚙️ Étape 3 : Configurer le webhook dans RevenueCat

Dans le dashboard RevenueCat :

```
1. Integrations → Webhooks → Add Webhook

2. URL : https://YOUR_PROJECT_REF.supabase.co/functions/v1/revenuecat-webhook

3. Authorization Header : Bearer YOUR_SUPABASE_ANON_KEY

4. Events à activer (cocher tous) :
   ✅ Initial Purchase
   ✅ Renewal
   ✅ Cancellation
   ✅ Expiration
   ✅ Product Change

5. Save

6. Test en cliquant sur "Send Test"
   → Vérifier dans Supabase Logs que le webhook arrive bien
```

---

## 7. Tests et validation

### ✅ Checklist de test avant production

#### Phase 1 : Authentification
- [ ] Lancer l'app → vérifier qu'un user anonyme est créé dans Supabase `auth.users`
- [ ] Vérifier qu'un abonnement `free` est créé dans `subscriptions`
- [ ] Fermer/relancer l'app → vérifier que le même user est récupéré

#### Phase 2 : Notation
- [ ] Noter un univers → vérifier insertion dans `ratings`
- [ ] Noter à nouveau → vérifier update (pas de doublon)
- [ ] Vérifier que `universe_rankings` se met à jour

#### Phase 3 : Abonnements (Sandbox/Testflight)
- [ ] Ouvrir la page d'abonnements → les 3 offres s'affichent
- [ ] Acheter un abonnement mensuel (compte sandbox)
- [ ] Vérifier dans RevenueCat Dashboard → transaction apparaît
- [ ] Vérifier dans Supabase → `subscriptions.is_paid = true`
- [ ] Vérifier que les univers premium se débloquent
- [ ] Tester "Restaurer les achats"

#### Phase 4 : Webhooks
- [ ] Dans RevenueCat Dashboard → Send Test Event
- [ ] Vérifier dans Supabase Logs que le webhook arrive
- [ ] Vérifier que `subscriptions` se met à jour correctement

---

## 8. Checklist de déploiement

### 📱 iOS

```
☐ 1. App Store Connect
   ├─ Créer l'app
   ├─ Créer les 3 produits IAP (monthly, yearly, lifetime)
   ├─ Créer un Subscription Group
   └─ Soumettre les produits pour review

☐ 2. Xcode
   ├─ Activer "In-App Purchase" capability
   ├─ Signer avec un certificat de distribution
   └─ Build pour TestFlight

☐ 3. TestFlight
   ├─ Upload le build
   ├─ Ajouter des testeurs internes
   ├─ Tester les achats en sandbox
   └─ Valider que les webhooks fonctionnent

☐ 4. Production
   ├─ Soumettre l'app pour review
   └─ Activer les produits IAP
```

### 🤖 Android

```
☐ 1. Google Play Console
   ├─ Créer l'app
   ├─ Créer les 3 produits (2 subscriptions + 1 in-app product)
   ├─ Configurer la facturation
   └─ Ajouter des testeurs (license testing)

☐ 2. Android Studio
   ├─ Générer un Signed APK/AAB
   ├─ Version code/name corrects
   └─ Permissions dans AndroidManifest.xml

☐ 3. Internal Testing
   ├─ Upload l'AAB en internal testing
   ├─ Ajouter des testeurs
   ├─ Tester les achats
   └─ Valider les webhooks

☐ 4. Production
   ├─ Remplir le listing (description, screenshots, etc.)
   ├─ Soumettre pour review
   └─ Publier
```

### 🔐 Supabase

```
☐ 1. RLS (Row Level Security)
   ├─ Vérifier toutes les policies sur ratings/subscriptions
   └─ Tester avec un user anonyme

☐ 2. Edge Functions
   ├─ Déployer revenuecat-webhook
   ├─ Vérifier les logs en production
   └─ Configurer les secrets (service_role_key)

☐ 3. Backup
   ├─ Activer les backups automatiques
   └─ Exporter un dump manuel
```

### 💳 RevenueCat

```
☐ 1. Configuration
   ├─ Vérifier les clés API (production)
   ├─ Lier les stores iOS + Android
   └─ Synchroniser les produits

☐ 2. Webhooks
   ├─ Configurer l'URL Supabase
   ├─ Tester avec "Send Test"
   └─ Monitorer les événements

☐ 3. Dashboard
   ├─ Activer les notifications d'erreurs (Slack/email)
   └─ Surveiller les métriques (MRR, churn, etc.)
```

---

## 🎯 Récapitulatif final

### Ce qui a été mis en place :

1. **Authentification anonyme** → Chaque user reçoit un UUID Supabase
2. **Système de notation** → Table `ratings` + vue `universe_rankings`
3. **Gestion d'abonnements** → RevenueCat + webhooks Supabase
4. **3 formules** → Monthly, Yearly, Lifetime
5. **Univers gratuits/premium** → Colonne `is_free` dans `universes`

### Flux complet :

```
User ouvre l'app
→ Création compte anonyme
→ Consultation univers gratuits
→ Note les univers (⭐⭐⭐⭐⭐)
→ Tente d'accéder à un univers premium 🔒
→ Redirigé vers page d'abonnements
→ Achète via RevenueCat (StoreKit/Google Billing)
→ Webhook met à jour Supabase
→ Unlock universesUser ouvre l'app
→ Création compte anonyme
→ Consultation univers gratuits
→ Note les univers (⭐⭐⭐⭐⭐)
→ Tente d'accéder à un univers premium 🔒
→ Redirigé vers page d'abonnements
→ Achète via RevenueCat (StoreKit/Google Billing)
→ Webhook met à jour Supabase
→ Unlock universes

th1zan: Il faut enregistrer ce document que tu viens de créer dans un nouveau fichier markdown, si ce n'est deja fait...

GitHub Copilot: Optimizing tool selection...