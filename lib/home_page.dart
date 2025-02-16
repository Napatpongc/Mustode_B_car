import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _pickupDate;
  DateTime? _returnDate;
  TimeOfDay _pickupTime = TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _returnTime = TimeOfDay(hour: 12, minute: 0);
  OverlayEntry? _overlayEntry;

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
              Positioned(
                left: 86,
                top: 103,
                child: Text(
                  'Young Yuri',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 49,
                top: 217,
                child: Text(
                  'หน้าหลัก',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 49,
                top: 270,
                child: Text(
                  'แผนที่',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 45,
                top: 323,
                child: Text(
                  'รายการเช่าทั้งหมด',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 45,
                top: 374,
                child: Text(
                  'การตั้งค่าบัญชี',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 59,
                top: 890,
                child: Container(
                  width: 124,
                  height: 39,
                  decoration: ShapeDecoration(
                    color: Color(0xFFE83A3A),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 75,
                top: 897,
                child: Text(
                  'ออกจากระบบ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 17,
                top: 87,
                child: Container(
                  width: 57,
                  height: 57,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/57x57"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 11,
                top: 210,
                child: Container(
                  width: 34,
                  height: 32,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/34x32"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                top: 262,
                child: Container(
                  width: 24,
                  height: 33,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/24x33"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 11,
                top: 312,
                child: Container(
                  width: 34,
                  height: 36,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/34x36"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 15,
                top: 365,
                child: Container(
                  width: 26,
                  height: 32,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/26x32"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
