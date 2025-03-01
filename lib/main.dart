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


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // เรียกใช้การ initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,  // ปิดแถบ Debug
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: IntoApp(),  // กำหนดให้หน้า IntoApp เป็นหน้าเริ่มต้น
    );
  }
}
