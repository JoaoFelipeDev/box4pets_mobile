import 'package:Box4Pets/core/ui/widgets/box_4_pets_loader.dart';
import 'package:asyncstate/asyncstate.dart';
import 'package:flutter/material.dart';

import 'package:Box4Pets/src/pages/base/base.dart';
import 'package:Box4Pets/src/pages/login/views/login.dart';
import 'package:Box4Pets/src/pages/register/views/register.dart';
import 'package:Box4Pets/src/pages/sliders/base_slider.dart';
import 'package:get_storage/get_storage.dart';

import '../src/pages/profile/views/profile.dart';
import 'features/splash_page.dart';
import 'pages/ativacao/views/activation.dart';

class Box4PetsApp extends StatefulWidget {
  const Box4PetsApp({Key? key}) : super(key: key);

  @override
  _Box4PetsAppState createState() => _Box4PetsAppState();
}

class _Box4PetsAppState extends State<Box4PetsApp> {
  final box = GetStorage();
  @override
  void initState() {
    box.write('version', '1.4.8');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AsyncStateBuilder(
      customLoader: const Box4PetsLoader(),
      builder: (asyncNavigatorObserver) {
        return MaterialApp(
          theme: ThemeData(
            scaffoldBackgroundColor: const Color(0xffDADADA),
            fontFamily: 'Urbanist',
          ),
          debugShowCheckedModeBanner: false,
          title: 'Box 4 Pets',
          navigatorObservers: [asyncNavigatorObserver],
          routes: {
            '/': (_) => const SplashPage(),
            '/base_slider': (_) => const BaseSlider(),
            '/login': (_) => const Login(),
            '/register': (_) => const Register(),
            '/base': (_) => const Base(),
            '/activation': (_) => const Activation(),
            '/profile': (_) => const Profile(),
          },
        );
      },
    );
  }
}
