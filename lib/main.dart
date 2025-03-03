import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:myproject/ProfileRenter.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'map.dart';
import 'into_app.dart';  // นำเข้าไฟล์ IntoApp.dart
import 'home_page.dart';
import 'calendar_page.dart';
import 'calendar_page.dart';
import 'select_filter.dart';
import 'TarHomePage.dart';
import 'Rentaldetails.dart';
import 'mycar.dart';

//version1.1+2=3.1
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ ตรวจสอบ Platform และ Initialize Firebase
    if (Platform.isAndroid) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'xxxxxxxxxxxx-g-famDgC3jx6VV4h-xxxxxx',
          appId: '1:xxxxxxxxxxxx:android:xxxxxxxb7ea052854b0005',
          messagingSenderId: 'xxxxxxxxxxxx',
          projectId: 'flutterxxxxxxxxx-9xxxa',
        ),
      );
    } else if (Platform.isIOS) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'xxxxxxxxxxxx-ios-xxxxxx',
          appId: '1:xxxxxxxxxxxx:ios:xxxxxxxb7ea052854b0005',
          messagingSenderId: 'xxxxxxxxxxxx',
          projectId: 'flutterxxxxxxxxx-9xxxa',
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint("🔥 Firebase Initialization Error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp( // ✅ เปลี่ยนเป็น GetMaterialApp เพื่อรองรับ GetX
      debugShowCheckedModeBanner: false,
      title: 'Flutter OTP Authentication',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 253, 188, 51),
      ),
      home: CarListScreen(),  // กำหนดให้หน้า IntoApp เป็นหน้าเริ่มต้น
    );
  }
}
//
