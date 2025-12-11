import 'package:flutter/material.dart';
import 'package:univers_app/pages/slideshow_page.dart';
import 'package:univers_app/models/univers_model.dart';

class CardUnivers extends StatefulWidget {
  const CardUnivers({super.key, required this.univers});

  final UniversModel univers;

  @override
  State<CardUnivers> createState() {
    return _CardUniversState();
  }
}

class _CardUniversState extends State<CardUnivers> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SlideshowPage(univers: widget.univers),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10.0,
              offset: const Offset(0.0, 4.0),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.univers.coverImageUrl ??
                    'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=400',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 60.0,
                    color: Colors.grey,
                  ),
                ),
              ),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 12.0,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    widget.univers.name ?? 'Untitled',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
