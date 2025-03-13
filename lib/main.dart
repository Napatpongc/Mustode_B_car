import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myproject/into_app.dart';
import 'into_app.dart';
import 'phone_auth_page.dart';
import 'home_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      if (Platform.isAndroid) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'YOUR_API_KEY',
            appId: 'YOUR_ANDROID_APP_ID',
            messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
            projectId: 'YOUR_PROJECT_ID',
          ),
        );
      } else if (Platform.isIOS) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'YOUR_API_KEY',
            appId: 'YOUR_IOS_APP_ID',
            messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
            projectId: 'YOUR_PROJECT_ID',
          ),
        );
      } else {
        await Firebase.initializeApp();
      }
    }
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter OTP Authentication',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      home:  IntoApp(), // กำหนด navigation flow ของคุณ
      getPages: [
        // กำหนด GetX routes หากต้องการ
      ],
    );
  }
}