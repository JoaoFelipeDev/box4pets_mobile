import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ParallaxBackground extends StatefulWidget {
  final Widget child;
  final double maxOffset;
  final double opacity;

  const ParallaxBackground({
    Key? key,
    required this.child,
    this.maxOffset = 22,
    this.opacity = 0.35,
  }) : super(key: key);

  @override
  State<ParallaxBackground> createState() => _ParallaxBackgroundState();
}

class _ParallaxBackgroundState extends State<ParallaxBackground>
    with SingleTickerProviderStateMixin {
  late final StreamSubscription _sub;
  late final Ticker _ticker;

  double _offsetX = 0;
  double _offsetY = 0;
  double _targetX = 0;
  double _targetY = 0;

  static const double _smoothing = 0.08;

  @override
  void initState() {
    super.initState();
    _sub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 33),
    ).listen((event) {
      _targetX = (-event.x).clamp(-3.0, 3.0) * (widget.maxOffset / 3.0);
      _targetY = (event.y).clamp(-3.0, 3.0) * (widget.maxOffset / 3.0);
    }, onError: (_) {});

    _ticker = createTicker((_) {
      final dx = (_targetX - _offsetX) * _smoothing;
      final dy = (_targetY - _offsetY) * _smoothing;
      if (dx.abs() > 0.05 || dy.abs() > 0.05) {
        if (mounted) {
          setState(() {
            _offsetX += dx;
            _offsetY += dy;
          });
        }
      }
    })
      ..start();
  }

  @override
  void dispose() {
    _sub.cancel();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8F5FF), Color(0xFFFDFCFF)],
            ),
          ),
        ),
        Positioned(
          left: -widget.maxOffset * 1.5 + _offsetX,
          right: -widget.maxOffset * 1.5 - _offsetX,
          top: -widget.maxOffset * 1.5 + _offsetY,
          bottom: -widget.maxOffset * 1.5 - _offsetY,
          child: Opacity(
            opacity: widget.opacity,
            child: Image.asset(
              'assets/images/circles.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        RepaintBoundary(child: widget.child),
      ],
    );
  }
}
