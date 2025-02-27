import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'into_app.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'map.dart';
import 'into_app.dart';  // นำเข้าไฟล์ IntoApp.dart
import 'home_page.dart';
import 'calendar_page.dart';
import 'calendar_page.dart';
import 'select_filter.dart';
import 'TarHomePage.dart';
import 'Rentaldetails.dart';

// 1+1=2

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initial Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: IntoApp(),
    );
  }
}
