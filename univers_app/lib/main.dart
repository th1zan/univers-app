import 'package:shared_preferences/shared_preferences.dart';
import 'package:univers_app/integrations/supabase_service.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:univers_app/globals/app_state.dart';
import 'package:univers_app/pages/landing_page.dart';
import 'package:univers_app/pages/slides_show.dart';

@NowaGenerated()
late final SharedPreferences sharedPrefs;

@NowaGenerated()
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPrefs = await SharedPreferences.getInstance();
  await SupabaseService().initialize();
  runApp(const MyApp());
}

@NowaGenerated({'visibleInNowa': false})
class MyApp extends StatelessWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (context) => AppState(),
      builder: (context, child) => MaterialApp(
        theme: AppState.of(context).theme,
        routes: {
          'LandingPage': (context) => const LandingPage(),
          'SlidesShow': (context) => const SlidesShow(),
        },
        initialRoute: 'LandingPage',
      ),
    );
  }
}
