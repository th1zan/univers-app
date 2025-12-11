import 'package:flutter/material.dart';

class SlidesShow extends StatelessWidget {
  const SlidesShow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          alignment: const Alignment(0.0, 0.0),
          children: [],
        ),
      ),
    );
  }
}
