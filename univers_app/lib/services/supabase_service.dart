import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univers_app/models/univers_model.dart';
import 'package:univers_app/models/univers_asset_model.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:univers_app/core/constants.dart';

/// Service pour communiquer avec Supabase.
/// Utilise le pattern Singleton pour éviter les instances multiples.
class SupabaseService {
  SupabaseService._();

  factory SupabaseService() {
    return _instance;
  }

  static final SupabaseService _instance = SupabaseService._();

  /// Client Supabase (accessible après initialize).
  SupabaseClient get client => Supabase.instance.client;

  /// Initialise la connexion Supabase.
  /// Les credentials sont lus depuis les constantes (variables d'environnement).
  Future<void> initialize() async {
    await Supabase.initialize(
      url: ApiConstants.supabaseUrl,
      anonKey: ApiConstants.supabaseAnonKey,
    );
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp(String email, String password) async {
    return Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  Future<List<UniversModel>> getAllUnivers() async {
    final response = await client
        .from('univers')
        .select('*, univers_translations(language, name)');
    final List<UniversModel> universList = [];
    for (final row in response) {
      final translations = row['univers_translations'] as List<dynamic>? ?? [];
      final Map<String, String> translationsMap = {};
      for (final trans in translations) {
        translationsMap[trans['language']] = trans['name'];
      }
      // Utiliser copyWith pour ajouter les traductions (immutabilité)
      final univers = UniversModel.fromJson(row).copyWith(
        translations: translationsMap,
      );
      universList.add(univers);
    }
    return universList;
  }

  Future<List<UniversAssetModel>> getUniversAssets(String universId) async {
    // Récupérer tous les assets de cet univers
    final assetsResponse = await client
        .from('univers_assets')
        .select('*')
        .eq('univers_id', universId)
        .order('sort_order', ascending: true);

    // Récupérer les IDs des assets
    final assetIds = assetsResponse.map((row) => row['id'] as String).toList();
    debugPrint('🔍 Asset IDs: $assetIds');

    // Récupérer toutes les traductions pour ces assets
    final translationsResponse = await client
        .from('univers_assets_translations')
        .select('asset_id, language, display_name')
        .inFilter('asset_id', assetIds);

    debugPrint(
        '🔍 Translations response count: ${translationsResponse.length}');
    debugPrint('🔍 Translations data: $translationsResponse');

    // Construire un map des traductions par asset_id
    final Map<String, Map<String, String>> translationsByAssetId = {};
    for (final trans in translationsResponse) {
      final assetId = trans['asset_id'] as String;
      if (!translationsByAssetId.containsKey(assetId)) {
        translationsByAssetId[assetId] = {};
      }
      translationsByAssetId[assetId]![trans['language']] =
          trans['display_name'];
    }

    // Construire les assets avec leurs traductions (immutabilité)
    final List<UniversAssetModel> assets = [];
    for (final row in assetsResponse) {
      final assetId = row['id'] as String;
      final translationsMap = translationsByAssetId[assetId] ?? {};
      debugPrint(
          'Asset ${row['display_name']} - Translations: $translationsMap');
      final asset = UniversAssetModel.fromJson(row).copyWith(
        translations: translationsMap,
      );
      assets.add(asset);
    }
    return assets;
  }

  Future<void> preloadUniversAssets(String slug) async {
    try {
      final univers =
          await client.from('univers').select('id').eq('slug', slug).single();
      final universId = univers['id'].toString();
      final assets = await getUniversAssets(universId);

      for (var asset in assets) {
        try {
          if (asset.imageUrl.isNotEmpty) {
            final imageUrl = ApiConstants.getStorageUrl(slug, asset.imageUrl);
            await DefaultCacheManager().downloadFile(imageUrl);
          }
          if (asset.animationUrl != null) {
            await DefaultCacheManager().downloadFile(asset.animationUrl!);
          } else if (asset.imageUrl.isNotEmpty) {
            final videoExtension = kIsWeb ? '_silent.webm' : '_silent.mp4';
            final videoName = asset.imageUrl.replaceAll('.png', videoExtension);
            final videoUrl = ApiConstants.getStorageUrl(slug, videoName);
            await DefaultCacheManager().downloadFile(videoUrl);
          }
        } catch (e) {
          // Ignore individual asset download errors
          debugPrint('Failed to preload asset: ${asset.imageUrl}, error: $e');
        }
      }
    } catch (e) {
      // Ignore preload errors to not block app startup
      debugPrint('Failed to preload universe assets: $e');
    }
  }
}
