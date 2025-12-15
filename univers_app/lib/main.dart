import 'package:univers_app/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:univers_app/core/app_state.dart';
import 'package:univers_app/core/themes.dart';
import 'package:univers_app/screens/landing_page.dart';
import 'package:univers_app/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (context) => AppState(),
      builder: (context, child) {
        final appState = context.watch<AppState>();
        return MaterialApp(
          title: 'Univers',
          debugShowCheckedModeBanner: false,
          theme: AppThemes.light,
          darkTheme: AppThemes.dark,
          themeMode: ThemeMode.light, // App enfants = toujours clair

          // Configuration de la localisation via AppLocalizations
          locale: Locale(appState.selectedLanguage),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,

          routes: {'LandingPage': (context) => const LandingPage()},
          initialRoute: 'LandingPage',
        );
      },
    );
  }
}
