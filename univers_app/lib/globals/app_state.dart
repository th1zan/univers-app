import 'package:flutter/material.dart';
import 'package:univers_app/globals/themes.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:univers_app/models/models.dart';

@NowaGenerated()
class AppState extends ChangeNotifier {
  AppState();

  factory AppState.of(BuildContext context, {bool listen = true}) {
    return Provider.of<AppState>(context, listen: listen);
  }

  ThemeData _theme = lightTheme;

  ThemeData get theme {
    return _theme;
  }

  void changeTheme(ThemeData theme) {
    _theme = theme;
    notifyListeners();
  }

  // Supabase client
  SupabaseClient get supabase => Supabase.instance.client;

  // Initialize Supabase
  Future<void> initializeSupabase() async {
    await Supabase.initialize(
      url: 'YOUR_SUPABASE_URL', // Remplacer par l'URL réelle
      anonKey: 'YOUR_SUPABASE_ANON_KEY', // Remplacer par la clé réelle
    );
  }

  // Fetch universes
  Future<List<Universe>> fetchUniverses() async {
    final response = await supabase
        .from('universes')
        .select()
        .order('order');
    return response.map((json) => Universe.fromJson(json)).toList();
  }

  // Fetch slides for a universe
  Future<List<Slide>> fetchSlides(String universeId) async {
    final response = await supabase
        .from('slides')
        .select()
        .eq('universe_id', universeId)
        .order('order');
    return response.map((json) => Slide.fromJson(json)).toList();
  }
}
