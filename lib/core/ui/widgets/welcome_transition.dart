import 'package:flutter/material.dart';

/// Custom Page Route used after successful login.
///
/// Plays a soft fade + gentle scale + slight upward translate, easing the user
/// into the home (~700ms). Feels less abrupt than the default iOS slide and
/// avoids the "snap" of popAndPushNamed.
class WelcomePageRoute<T> extends PageRouteBuilder<T> {
  WelcomePageRoute({required Widget page})
      : super(
          opaque: true,
          transitionDuration: const Duration(milliseconds: 520),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (context, animation, secondary, child) {
            final eased = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            final slide = Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(eased);

            return SlideTransition(
              position: slide,
              child: child,
            );
          },
        );
}

/// Brief welcome splash shown between login and home.
///
/// White screen with a fading "Olá, [name]" + small pulse. Pushes [destination]
/// after [holdFor] using a fade transition.
class WelcomeOverlay extends StatefulWidget {
  final String name;
  final Widget destination;
  final Duration holdFor;

  const WelcomeOverlay({
    super.key,
    required this.name,
    required this.destination,
    this.holdFor = const Duration(milliseconds: 1100),
  });

  @override
  State<WelcomeOverlay> createState() => _WelcomeOverlayState();
}

class _WelcomeOverlayState extends State<WelcomeOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    Future.delayed(widget.holdFor, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        WelcomePageRoute(page: widget.destination),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final t = Curves.easeOutCubic.transform(_ctrl.value);
            return Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, (1 - t) * 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Olá,',
                      style: TextStyle(
                        fontSize: 18,
                        color: const Color(0xFF3F2873).withOpacity(0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3F2873),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
