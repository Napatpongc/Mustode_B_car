import 'package:flutter/material.dart';
import 'into_app.dart';  // นำเข้าไฟล์ IntoApp.dart
import 'home_page.dart';
import 'calendar_page.dart';
import 'map.dart';

void main() {
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
      home: MapDetailPage(),  // กำหนดให้หน้า IntoApp เป็นหน้าเริ่มต้น
    );
  }
}
//hello world
