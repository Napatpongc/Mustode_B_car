import 'package:flutter/material.dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        body: ListView(children: [
          TotalIncome1(),
        ]),
      ),
    );
  }
}

class TotalIncome1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 440,
          height: 956,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 440,
                  height: 106,
                  decoration: BoxDecoration(color: Color(0xFF00377E)),
                ),
              ),
              Positioned(
                left: 148,
                top: 178,
                child: Text(
                  'Name',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(//burger bar
                left: 20,
                top: 19,
                child: Container(
                  width: 60,
                  height: 60,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(3, (index) => 
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3), // เพิ่มช่องไฟแนวตั้ง
                          child: Row(
                            children: [
                              Container(
                                width: 4, // ลดขนาดของจุดให้เล็กลง
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6), // ปรับระยะห่างระหว่างจุดกับเส้น
                              Container(
                                width: 29, // ลดความยาวของขีดให้เหมาะสม
                                height: 4, // คงความหนาเท่าเดิม
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 217,
                top: 184,
                child: Container(
                  width: 30,
                  height: 28,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                       image: AssetImage("assets/image/checkmark_image.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 192,
                top: 60,
                child: SizedBox(
                  width: 55,
                  height: 38,
                  child: Text(
                    'บัญชี',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 47,
                top: 366,
                child: Container(
                  width: 345,
                  height: 179,
                  decoration: ShapeDecoration(
                    color: Color(0xFFD6EFFF),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(29),
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
                left: 66,
                top: 376,
                child: Text(
                  'รายได้วันนี้',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 66,
                top: 492,
                child: SizedBox(
                  width: 286,
                  height: 37,
                  child: Text(
                    'คุณภาพร้านสัปดาห์นี้',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 354,
                top: 490,
                child: Container(
                  width: 24,
                  height: 39,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/image/greaterthan_sign_image.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 354,
                top: 416,
                child: Container(
                  width: 24,
                  height: 39,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/image/greaterthan_sign_image.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 69,
                top: 423,
                child: Text(
                  '฿ 3240.00',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 40,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 49,
                top: 483,
                child: Container(
                  width: 343,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignCenter,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 305,
                top: 122,
                child: Container(
                  width: 96,
                  height: 57,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 5,
                        top: 36,
                        child: SizedBox(
                          width: 23.47,
                          height: 20,
                          child: Text(
                            'ผู้เช่า',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontFamily: 'IBM Plex Sans Thai Looped',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 38.87,
                        top: 36,
                        child: SizedBox(
                          width: 50.13,
                          height: 18,
                          child: Text(
                            'ผู้ปล่อยเช่า',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontFamily: 'IBM Plex Sans Thai Looped',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      Positioned(//กรอบเลื่อนตรง ผู้เช่า กับผู้ปล่อยเช่า
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 90.67,
                          height: 34,
                          decoration: ShapeDecoration(
                            color: Color(0xFFD6EFFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
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
                      Positioned(//ตัวปุ่มเลื่อนที่ถูกจัดอยู่ในกรอบ เป็นตัวโชวว่าตอนนี้อยู่ในหน้า ผู้เช่าหรือผู้ปล่อยเช่า
                        left: 53.33,
                        top: 4,
                        child: Container(
                          width: 27.73,
                          height: 26,
                          decoration: ShapeDecoration(
                            color: Color(0xFF00377E),
                            shape: OvalBorder(),
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
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 49,
                top: 484,
                child: Container(
                  width: 342,
                  height: 68,
                  decoration: BoxDecoration(color: Color(0x00D9D9D9)),
                ),
              ),
              Positioned(
                left: 38,
                top: 152,
                child: Container(
                  width: 93,
                  height: 90,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/image/profile_image.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(////ตรงที่คลิกแล้วเปลี่ยนสีของ ข้อมูลส่วนตัว 
                left: 0,
                top: 254,
                child: Container(
                  width: 221,
                  height: 43,
                  decoration: ShapeDecoration(
                    color: Color(0xFF94D4FB),
                    shape: RoundedRectangleBorder(side: BorderSide(width: 1)),
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
              Positioned(//ตรงที่คลิกแล้วเปลี่ยนสีของ  รายได้ทั้งหมด
                left: 220,
                top: 254,
                child: Container(
                  width: 221,
                  height: 43,
                  decoration: ShapeDecoration(
                    color: Color(0xFFD6EFFF),
                    shape: RoundedRectangleBorder(side: BorderSide(width: 1)),
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
                left: 247,
                top: 266,
                child: SizedBox(
                  width: 175,
                  height: 20,
                  child: Text(
                    'รายได้ทั้งหมด',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 23,
                top: 266,
                child: SizedBox(
                  width: 175,
                  height: 20,
                  child: Text(
                    'ข้อมูลส่วนตัว',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
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