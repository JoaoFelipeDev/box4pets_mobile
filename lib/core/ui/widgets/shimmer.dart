import 'package:flutter/material.dart';

class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final List<Color> colors;

  const Shimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1400),
    this.colors = const [
      Color(0xFFE7DDF8),
      Color(0xFFF3EEFC),
      Color(0xFFE7DDF8),
    ],
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) {
            final t = _ctrl.value;
            return LinearGradient(
              begin: const Alignment(-1.5, -0.3),
              end: const Alignment(1.5, 0.3),
              colors: widget.colors,
              stops: [
                (t - 0.3).clamp(0.0, 1.0),
                t.clamp(0.0, 1.0),
                (t + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(rect);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: const Color(0xFFE7DDF8),
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class SmartNetworkImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final Alignment alignment;
  final int? cacheWidth;
  final int? cacheHeight;

  const SmartNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ShimmerBox(borderRadius: BorderRadius.zero),
        if (url != null && url!.isNotEmpty)
          Image.network(
            url!,
            fit: fit,
            alignment: alignment,
            cacheWidth: cacheWidth ?? 400,
            cacheHeight: cacheHeight,
            frameBuilder: (context, child, frame, wasSync) {
              if (wasSync) return child;
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOut,
                child: child,
              );
            },
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFFE7DDF8),
              alignment: Alignment.center,
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: Color(0xFFB5A4D9),
                size: 28,
              ),
            ),
          ),
      ],
    );
  }
}
