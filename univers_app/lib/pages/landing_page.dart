import 'package:flutter/material.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:univers_app/models/univers_model.dart';
import 'package:univers_app/integrations/supabase_service.dart';
import 'package:univers_app/card_univers.dart';
import 'package:univers_app/globals/app_state.dart';
import 'package:provider/provider.dart';

@NowaGenerated({'auto-width': 403.0})
class LandingPage extends StatefulWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() {
    return _LandingPageState();
  }
}

@NowaGenerated()
class _LandingPageState extends State<LandingPage> {
  String? var1 = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Container(
         decoration: BoxDecoration(
           gradient: LinearGradient(
             begin: Alignment.topLeft,
             end: Alignment.bottomRight,
             colors: [
               Color(0xfffff8e7),
               Color(0xffffe5ec),
               Color(0xffe0f7fa),
             ],
           ),
         ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: 20.0,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xffff6b9d).withValues(alpha: 0.3),
                        blurRadius: 20.0,
                        offset: const Offset(0.0, 8.0),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: const Color(0xffffd93d),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xffffd93d).withValues(alpha: 0.4),
                              blurRadius: 12.0,
                              offset: const Offset(0.0, 4.0),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.rocket_launch_rounded,
                          color: Colors.white,
                          size: 32.0,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Text(
                        'Univers',
                        style: TextStyle(
                          fontSize: 42.0,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 1.0,
                          shadows: [
                            const Shadow(
                              color: Colors.black12,
                              offset: Offset(2.0, 2.0),
                              blurRadius: 4.0,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: DataBuilder<List<UniversModel>>(
                  builder: (context, data) => Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: GridView.custom(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 24.0,
                            crossAxisSpacing: 24.0,
                            childAspectRatio: 0.9,
                          ),
                      childrenDelegate: SliverChildBuilderDelegate(
                        childCount: data.length,
                        (context, index) => CardUnivers(univers: data[index]),
                      ),
                    ),
                  ),
                  loadingWidget: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xff4ecdc4).withValues(alpha: 0.3),
                                blurRadius: 20.0,
                              ),
                            ],
                          ),
                          child: const CircularProgressIndicator(
                            strokeWidth: 6.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xff4ecdc4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        const Text(
                          'Chargement...',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff2d3748),
                          ),
                        ),
                      ],
                    ),
                  ),
                  errorBuilder: (context, error) => Center(
                    child: Container(
                      margin: const EdgeInsets.all(32.0),
                      padding: const EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.2),
                            blurRadius: 20.0,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20.0),
                            decoration: const BoxDecoration(
                              color: Color(0xffffe5e5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.cloud_off_rounded,
                              size: 80.0,
                              color: Color(0xffff6b6b),
                            ),
                          ),
                          const SizedBox(height: 24.0),
                          const Text(
                            'Oups !',
                            style: TextStyle(
                              color: Color(0xffff6b6b),
                              fontSize: 32.0,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          const Text(
                            'Une petite erreur...',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff2d3748),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                   future: SupabaseService().getAllUnivers(),
                 ),
               ),
             ],
           ),
               Positioned(
                top: 20.0,
                right: 20.0,
                child: Consumer<AppState>(
                  builder: (context, appState, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DropdownButton<String>(
                        value: appState.selectedLanguage,
                        items: const [
                          DropdownMenuItem(value: 'fr', child: Text('FR')),
                          DropdownMenuItem(value: 'en', child: Text('EN')),
                          DropdownMenuItem(value: 'de', child: Text('DE')),
                          DropdownMenuItem(value: 'es', child: Text('ES')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            appState.setLanguage(value);
                          }
                        },
                        underline: const SizedBox(),
                        icon: const Icon(Icons.language, color: Color(0xFF4ECDC4)),
                        style: const TextStyle(
                          color: Color(0xFF2D3748),
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 20.0,
                right: 20.0,
                child: Consumer<AppState>(
                  builder: (context, appState, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: DropdownButton<String>(
                        value: appState.selectedLanguage,
                        items: const [
                          DropdownMenuItem(value: 'fr', child: Text('FR')),
                          DropdownMenuItem(value: 'en', child: Text('EN')),
                          DropdownMenuItem(value: 'de', child: Text('DE')),
                          DropdownMenuItem(value: 'es', child: Text('ES')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            appState.setLanguage(value);
                          }
                        },
                        underline: const SizedBox(),
                        icon: const Icon(Icons.language, color: Color(0xFF4ECDC4)),
                        style: const TextStyle(
                          color: Color(0xFF2D3748),
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
