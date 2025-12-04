import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univers_app/models/univers_model.dart';
import 'package:univers_app/models/univers_asset_model.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/foundation.dart';

@NowaGenerated()
class SupabaseService {
  SupabaseService._();

  factory SupabaseService() {
    return _instance;
  }

  static final SupabaseService _instance = SupabaseService._();

  Future initialize() async {
    await Supabase.initialize(
      url: 'https://nazvebulhqxnieyeqnxe.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5henZlYnVsaHF4bmlleWVxbnhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQwNzY5NTQsImV4cCI6MjA3OTY1Mjk1NH0.DlpNXu9VTCwd2D1mCQlI4k08BIiI9Rf2OGzaL6L1evA',
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
    final response = await Supabase.instance.client
        .from('univers')
        .select('*, univers_translations(language, name)');
    final Map<String, UniversModel> universMap = {};
    for (final row in response) {
      final universId = row['id'].toString();
      final translations = row['univers_translations'] as List<dynamic>? ?? [];
      final Map<String, String> translationsMap = {};
      for (final trans in translations) {
        translationsMap[trans['language']] = trans['name'];
      }
      final univers = UniversModel.fromJson(row)..translations = translationsMap;
      universMap[universId] = univers;
    }
    return universMap.values.toList();
  }

  Future<List<UniversAssetModel>> getUniversAssets(String universId) async {
    final response = await Supabase.instance.client
        .from('univers_assets')
        .select('*, univers_assets_translations(language, display_name)')
        .eq('univers_id', universId)
        .order('sort_order', ascending: true);
    final List<UniversAssetModel> assets = [];
    for (final row in response) {
      final translations = row['univers_assets_translations'] as List<dynamic>? ?? [];
      final Map<String, String> translationsMap = {};
      for (final trans in translations) {
        translationsMap[trans['language']] = trans['display_name'];
      }
      final asset = UniversAssetModel.fromJson(row)..translations = translationsMap;
      assets.add(asset);
    }
    return assets;
  }

  Future<void> preloadUniversAssets(String slug) async {
    final univers = await Supabase.instance.client
        .from('univers')
        .select('id')
        .eq('slug', slug)
        .single();
    final universId = univers['id'].toString();
    final assets = await getUniversAssets(universId);
    for (var asset in assets) {
      if (asset.imageUrl != null) {
        final imageUrl =
            'https://nazvebulhqxnieyeqnxe.supabase.co/storage/v1/object/public/univers/$slug/${asset.imageUrl}';
        await DefaultCacheManager().downloadFile(imageUrl);
      }
      if (asset.animationUrl != null) {
        await DefaultCacheManager().downloadFile(asset.animationUrl!);
      } else {
        if (asset.imageUrl != null) {
          final videoExtension = kIsWeb ? '_silent.webm' : '_silent.mp4';
          final videoUrl =
              'https://nazvebulhqxnieyeqnxe.supabase.co/storage/v1/object/public/univers/$slug/${asset.imageUrl!.replaceAll('.png', videoExtension)}';
          await DefaultCacheManager().downloadFile(videoUrl);
        }
      }
    }
  }
}
