import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univers_app/models/univers_model.dart';
import 'package:univers_app/models/univers_asset_model.dart';

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
    final response = await Supabase.instance.client.from('univers').select('*');
    return response.map((json) => UniversModel.fromJson(json)).toList();
  }

  Future<List<UniversAssetModel>> getUniversAssets(String universId) async {
    final response = await Supabase.instance.client
        .from('univers_assets')
        .select('*')
        .eq('univers_folder', universId)
        .order('sort_order', ascending: true);
    return response.map((json) => UniversAssetModel.fromJson(json)).toList();
  }
}
