import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        backgroundColor: Color(0xFF00377E),  // สีเดียวกับปุ่ม Sign In
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ข้อความยินดีต้อนรับ
            Text(
              'Welcome to Home Page!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            // ปุ่ม Logout
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // กลับไปยังหน้าล็อกอิน
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00377E),  // สีเดียวกับปุ่ม Sign In
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
