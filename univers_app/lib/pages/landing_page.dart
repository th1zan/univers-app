import 'package:flutter/material.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:univers_app/models/univers_model.dart';
import 'package:univers_app/card_univers.dart';
import 'package:univers_app/integrations/supabase_service.dart';

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
      backgroundColor: const Color(0xfff5e6d3),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 30.0,
                horizontal: 20.0,
              ),
              child: Text(
                'Choisis ton univers',
                style: TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: DataBuilder<List<UniversModel>>(
                builder: (context, data) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.custom(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20.0,
                          crossAxisSpacing: 20.0,
                          childAspectRatio: 1.0,
                        ),
                    childrenDelegate: SliverChildBuilderDelegate(
                      childCount: data.length,
                      (context, index) => CardUnivers(univers: data[index]),
                    ),
                  ),
                ),
                loadingWidget: const Center(
                  child: CircularProgressIndicator(strokeWidth: 5.0),
                ),
                errorBuilder: (context, error) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 60.0,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Oups ! Une erreur est survenue',
                        style: TextStyle(color: Colors.red, fontSize: 18.0),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                future: SupabaseService().getAllUnivers(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
