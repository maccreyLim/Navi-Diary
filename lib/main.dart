import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:navi_diary/controller/auth_controller.dart';
import 'package:navi_diary/firebase_options.dart';
import 'package:navi_diary/scr/login_screen.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:navi_diary/widget/w.notification.dart';

void main() async {
// Firebase 초기화
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) => Get.put(AuthController()));
  //Local Notification 초기화
  // await _initLocalNotification();
  FlutterLocalNotification.init();
  // 3초 후 권한 요청
  Future.delayed(const Duration(seconds: 3),
      FlutterLocalNotification.requestNotificationPermission());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(
        1080,
        2220,
      ),
      builder: (_, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NAVI Diary',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
