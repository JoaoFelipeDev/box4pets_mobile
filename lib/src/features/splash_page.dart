import 'package:Box4Pets/core/ui/widgets/welcome_transition.dart';
import 'package:Box4Pets/src/pages/base/base.dart';
import 'package:Box4Pets/src/pages/login/views/login.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _route());
  }

  void _route() {
    if (!mounted) return;
    final hasUser = box.read('user') != null;
    if (hasUser) {
      Navigator.of(context).pushAndRemoveUntil(
        WelcomePageRoute(page: const Base()),
        (_) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 420),
          pageBuilder: (_, __, ___) => const Login(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/images/splash.png', fit: BoxFit.cover),
      ),
    );
  }
}
