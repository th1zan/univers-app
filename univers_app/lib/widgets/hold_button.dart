import 'package:flutter/material.dart';
import 'dart:async';

class HoldButton extends StatefulWidget {
  const HoldButton({
    required this.iconBuilder,
    required this.onHold,
    this.gradientColors,
    this.size = 60.0,
    this.iconSize = 36.0,
    this.holdDuration = const Duration(seconds: 2),
    super.key,
  });

  final IconData Function() iconBuilder;
  final VoidCallback onHold;
  final List<Color>? gradientColors;
  final double size;
  final double iconSize;
  final Duration holdDuration;

  @override
  State<HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<HoldButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  Timer? _holdTimer;
  bool _isHolding = false;


  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: widget.holdDuration,
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onHold();
        _resetProgress();
      }
    });

    
  }

  @override
  void dispose() {
    _progressController.dispose();
    _holdTimer?.cancel();
    super.dispose();
  }

  void _onPressStart() {
    setState(() {
      _isHolding = true;
    });
    _progressController.forward();
  }

  void _onPressEnd() {
    setState(() {
      _isHolding = false;
    });
    _resetProgress();
  }

  void _resetProgress() {
    _progressController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = widget.gradientColors ??
        [
          const Color(0xFFFF6B9D),
          const Color(0xFFFF8CAB),
        ];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Bouton principal avec anneau de progression
        GestureDetector(
          onTapDown: (_) => _onPressStart(),
          onTapUp: (_) => _onPressEnd(),
          onTapCancel: _onPressEnd,
          child: AnimatedScale(
            scale: _isHolding ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Anneau de progression
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return SizedBox(
                        width: widget.size,
                        height: widget.size,
                        child: CircularProgressIndicator(
                          value: _progressController.value,
                          strokeWidth: 4.0,
                           backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            gradientColors[0],
                          ),
                        ),
                      );
                    },
                  ),

                  // Bouton central avec gradient
                  Container(
                    width: widget.size - 12.0,
                    height: widget.size - 12.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: gradientColors,
                      ),
                      boxShadow: [
                        BoxShadow(
                           color: gradientColors[0].withValues(alpha: 0.5),
                          blurRadius: 16.0,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.iconBuilder(),
                      size: widget.iconSize,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        
      ],
    );
  }
}