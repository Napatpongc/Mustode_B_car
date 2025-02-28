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
          TotalIncome2(),
        ]),
      ),
    );
  }
}

class TotalIncome2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 440,
          height: 956,//เดี๋ยวต้องปรับให้มันเลื่อนลงได้ในกรณ
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              Positioned(//แทบสีน้ำเงินใหญ่ที่อยู่คล้ายแถบพื้นหลัง
                left: 0,
                top: 0,
                child: Container(
                  width: 440,
                  height: 106,
                  decoration: BoxDecoration(color: Color(0xFF00377E)),
                ),
              ),
              Positioned(
                left: 10,
                top: 10,
                child: Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/image/lessterthan_sign_image.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Stack(
                children: [
                  Container(
                    width: double.infinity,  // แถบเต็มความกว้าง
                    height: 140,  // ความสูงของแถบ
                    alignment: Alignment.center,  // จัดตรงกลาง
                    child: Text(
                      'รายได้ในวันนี้',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'IBM Plex Sans Thai Looped',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),

              Positioned(//กรอบรายได้วันนี้
                left: 47,
                top: 129,
                child: Container(
                  width: 345,
                  height: 123,
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
                top: 139,
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
                left: 639,
                top: 362,
                child: Container(width: 3, height: 4),
              ),
              Positioned(
                left: 69,
                top: 186,
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
                top: 247,
                child: Container(
                  width: 342,
                  height: 68,
                  decoration: BoxDecoration(color: Color(0x00D9D9D9)),
                ),
              ),
              Positioned(//เส้นบนค่าเช่าลด แต่ ล่างกรอบรายได้วันนี้
                left: -1,
                top: 295,
                child: Container(
                  width: 441,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: Color(0xFFD4D4D4),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(//เส้นบนค่าเช่าลด อันที่2
                left: -1,
                top: 517,
                child: Container(
                  width: 441,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: Color(0xFFD4D4D4),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                top: 307,
                child: Text(
                  'ค่าเช่ารถ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 306,
                top: 300,
                child: Text(
                  'วันที่  xx/xx/xxxx',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 16,
                top: 408,
                child: Text(
                  'ส่วนต่าง',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 26,
                top: 357,
                child: Text(
                  '-รายต่อวัน ฿900 x 2 วัน',
                  style: TextStyle(
                    color: Color(0xFF6E6E6E),
                    fontSize: 14,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 31,
                top: 376,
                child: Text(
                  'ตั้งแต่วันที่xx/xx/xxxx - xx/xx/xxxx',
                  style: TextStyle(
                    color: Color(0xFF6E6E6E),
                    fontSize: 14,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 26,
                top: 436,
                child: SizedBox(
                  width: 114,
                  height: 22,
                  child: Text(
                    '-หักค่าให้แอพ20%',
                    style: TextStyle(
                      color: Color(0xFF6F6F6F),
                      fontSize: 14,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 32,
                top: 338,
                child: Text(
                  'Toyota Vios ',
                  style: TextStyle(
                    color: Color(0xFF6E6E6E),
                    fontSize: 14,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 350,
                top: 356,
                child: SizedBox(
                  width: 63,
                  child: Text(
                    '฿1,800',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 360,
                top: 434,
                child: SizedBox(
                  width: 47,
                  child: Text(
                    '฿360',
                    style: TextStyle(
                      color: Color(0xFFFF0000),
                      fontSize: 16,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 350,
                top: 478,
                child: SizedBox(
                  width: 55,
                  child: Text(
                    '฿1,440',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                top: 478,
                child: Text(
                  'Total',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 736,
                child: Container(
                  width: 441,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: Color(0xFFD4D4D4),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 17,
                top: 526,
                child: Text(
                  'ค่าเช่ารถ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 307,
                top: 523,
                child: Text(
                  'วันที่  xx/xx/xxxx',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 17,
                top: 627,
                child: Text(
                  'ส่วนต่าง',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 28,
                top: 573,
                child: Text(
                  '-รายต่อวัน ฿900 x 2 วัน',
                  style: TextStyle(
                    color: Color(0xFF6E6E6E),
                    fontSize: 14,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 34,
                top: 592,
                child: Text(
                  'ตั้งแต่วันที่xx/xx/xxxx - xx/xx/xxxx',
                  style: TextStyle(
                    color: Color(0xFF6E6E6E),
                    fontSize: 14,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 28,
                top: 656,
                child: Text(
                  '-หักค่าให้แอพ20%',
                  style: TextStyle(
                    color: Color(0xFF6F6F6F),
                    fontSize: 14,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 35,
                top: 554,
                child: Text(
                  'Honda Jazz',
                  style: TextStyle(
                    color: Color(0xFF6E6E6E),
                    fontSize: 14,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 351,
                top: 575,
                child: SizedBox(
                  width: 63,
                  child: Text(
                    '฿1,800',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 360,
                top: 653,
                child: SizedBox(
                  width: 47,
                  child: Text(
                    '฿360',
                    style: TextStyle(
                      color: Color(0xFFFF0000),
                      fontSize: 16,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 351,
                top: 697,
                child: SizedBox(
                  width: 55,
                  child: Text(
                    '฿1,440',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 17,
                top: 697,
                child: Text(
                  'Total',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
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