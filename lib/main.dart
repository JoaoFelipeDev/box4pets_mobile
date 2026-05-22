import 'dart:io';

import 'package:Box4Pets/debug_agent_log.dart';
import 'package:Box4Pets/src/Box4PetsApp.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("837c2976-44e4-427d-84dc-af0182b12175");
  OneSignal.Notifications.requestPermission(true);

  try {
    await dotenv.load(fileName: ".env");
    final token = dotenv.env['AIRTABLE_TOKEN']?.trim() ?? '';
    agentDebugLog(
      location: 'main.dart:dotenv',
      message: 'dotenv loaded',
      hypothesisId: 'H-E',
      data: {
        'tokenPresent': token.isNotEmpty,
        'tokenLength': token.length,
        'tokenLooksValid': token.startsWith('pat') && token.length >= 40,
        'baseUrlSet': (dotenv.env['AIRTABLE_BASE_URL']?.trim().isNotEmpty ?? false),
        'smtpUserSet': (dotenv.env['SMTP_USER']?.trim().isNotEmpty ?? false),
      },
    );
  } catch (e) {
    agentDebugLog(
      location: 'main.dart:dotenv',
      message: 'dotenv load failed',
      hypothesisId: 'H-E',
      data: {'error': e.toString()},
    );
  }
  await GetStorage.init();
  await ScreenUtil.ensureScreenSize();
  await FlutterDownloader.initialize();
  runApp(const Box4PetsApp());
}
