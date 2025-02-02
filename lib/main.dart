import 'package:flutter/material.dart';
import 'into_app.dart';  // นำเข้าไฟล์ IntoApp.dart

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
      home: IntoApp(),  // กำหนดให้หน้า IntoApp เป็นหน้าเริ่มต้น
    );
  }
}
//hello world
