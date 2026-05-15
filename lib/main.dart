import 'dart:io';

import 'package:Box4Pets/src/Box4PetsApp.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // OneSignal desativado em build de dev: Personal Team grátis não provê entitlement
  // de push, e a chamada nativa de registerForRemoteNotifications crasha o app.
  // Reativar em build de produção com Bundle ID e certificados oficiais.
  // OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // OneSignal.initialize("837c2976-44e4-427d-84dc-af0182b12175");
  // OneSignal.Notifications.requestPermission(true);

  await dotenv.load(fileName: ".env");
  await GetStorage.init();
  await ScreenUtil.ensureScreenSize();
  await FlutterDownloader.initialize();
  runApp(const Box4PetsApp());
}
