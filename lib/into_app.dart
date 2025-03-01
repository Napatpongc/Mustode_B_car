import 'package:flutter/material.dart';
import 'login_page.dart'; // นำเข้าไฟล์ login_page.dart

class IntoApp extends StatelessWidget {
  const IntoApp({super.key});

  @override
  Widget build(BuildContext context) {
    // หน่วงเวลา 4 วินาทีแล้วเปลี่ยนไปยังหน้า login_page
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoginPage()), // ไปยังหน้า LoginPage
      );
    });

    return Scaffold(
      body: Center(
        child: Container(
          width: 389,
          height: 389,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/icon/app_icon.png"),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}
