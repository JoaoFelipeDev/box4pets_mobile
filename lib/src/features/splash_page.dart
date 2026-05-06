import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final box = GetStorage();
  late final bool firstAccess;
  @override
  void initState() {
    if (box.read('firstAccess') != null) {
      firstAccess = true;
    } else {
      firstAccess = false;
    }
    Future.delayed(const Duration(seconds: 3), () {
      if (!firstAccess) {
        Navigator.popAndPushNamed(context, '/base_slider');
      } else {
        if (box.read('user') != null) {
          Navigator.popAndPushNamed(context, '/base');
        } else {
          Navigator.popAndPushNamed(context, '/login');
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/logoB4p_centralizado.png'),
      ),
    );
  }
}
