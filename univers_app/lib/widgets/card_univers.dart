import 'package:flutter/material.dart';
import 'package:univers_app/screens/slideshow_page.dart';
import 'package:univers_app/models/univers_model.dart';
import 'package:univers_app/core/app_state.dart';
import 'package:univers_app/core/themes.dart';
import 'package:provider/provider.dart';

class CardUnivers extends StatefulWidget {
  const CardUnivers({super.key, required this.univers});

  final UniversModel univers;

  @override
  State<CardUnivers> createState() {
    return _CardUniversState();
  }
}

class _CardUniversState extends State<CardUnivers>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SlideshowPage(univers: widget.univers),
          ),
        );
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 20.0,
                offset: const Offset(0, 10),
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30.0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image avec overlay gradient
                Image.network(
                  widget.univers.coverImageUrl.isNotEmpty
                      ? widget.univers.coverImageUrl
                      : 'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=400',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.3),
                          AppColors.secondary.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      size: 80.0,
                      color: AppColors.textOnDark,
                    ),
                  ),
                ),

                // Titre avec fond gradient
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 16.0,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.85),
                          Colors.black.withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Consumer<AppState>(
                      builder: (context, appState, child) => Text(
                        widget.univers
                            .getLocalizedName(appState.selectedLanguage),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(1, 1),
                              blurRadius: 3.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
