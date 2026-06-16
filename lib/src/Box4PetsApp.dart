import 'package:Box4Pets/core/ui/widgets/box_4_pets_loader.dart';
import 'package:asyncstate/asyncstate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:Box4Pets/src/pages/base/base.dart';
import 'package:Box4Pets/src/pages/login/views/login.dart';
import 'package:Box4Pets/src/pages/register/views/register.dart';
import 'package:Box4Pets/src/pages/sliders/base_slider.dart';
import 'package:get_storage/get_storage.dart';

import '../src/pages/profile/views/profile.dart';
import 'features/splash_page.dart';
import 'pages/ativacao/views/activation.dart';

final GlobalKey<NavigatorState> appNavigatorKey =
    GlobalKey<NavigatorState>();

class Box4PetsApp extends StatefulWidget {
  const Box4PetsApp({Key? key}) : super(key: key);

  @override
  _Box4PetsAppState createState() => _Box4PetsAppState();
}

class _Box4PetsAppState extends State<Box4PetsApp> {
  final box = GetStorage();
  @override
  void initState() {
    box.write('version', '2.0.1');
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
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
              },
            ),
            textTheme: GoogleFonts.archivoTextTheme().copyWith(
              displayLarge: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600, letterSpacing: -2.3),
              displayMedium: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600, letterSpacing: -2.0),
              displaySmall: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600, letterSpacing: -1.6),
              headlineLarge: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600, letterSpacing: -1.3),
              headlineMedium: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600, letterSpacing: -1.1),
              headlineSmall: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w500, letterSpacing: -0.9),
              titleLarge: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w500, letterSpacing: -0.7),
              bodyLarge: GoogleFonts.archivo(height: 1.6),
              bodyMedium: GoogleFonts.archivo(height: 1.6),
              bodySmall: GoogleFonts.archivo(height: 1.6),
              labelLarge: GoogleFonts.archivo(fontWeight: FontWeight.w500),
              labelMedium: GoogleFonts.archivo(fontWeight: FontWeight.w500),
              labelSmall: GoogleFonts.archivo(fontWeight: FontWeight.w500),
            ),
            primaryTextTheme: GoogleFonts.archivoTextTheme(),
          ),
          debugShowCheckedModeBanner: false,
          title: 'Box 4 Pets',
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [Locale('pt', 'BR')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          navigatorKey: appNavigatorKey,
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
