import 'package:flutter/material.dart';
import 'dart:async';



class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: const Scaffold(
        body: RentalDetailsScreen(),
      ),
    );
  }
}

class RentalDetailsScreen extends StatelessWidget {
  const RentalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(
      children: [
        Container(
          width: 440,
          height: 1818,
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
                left: 92,
                top: 70,
                child: SizedBox(
                  width: 236,
                  height: 38,
                  child: Text(
                    'รายละเอียด / สถานะ',
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
                left: 16,
                top: 118,
                child: Text(
                  'สถานะการจอง',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 16,
                top: 460,
                child: Text(
                  'รายละเอียดผู้เช่า',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 443,
                child: Container(
                  width: 440,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 9,
                        strokeAlign: BorderSide.strokeAlignCenter,
                        color: Color(0xFFD4D4D4),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: -1,
                top: 161,
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
                left: 0,
                top: 496,
                child: Container(
                  width: 445,
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
                left: -19,
                top: 509,
                child: Container(
                  width: 482,
                  height: 1265,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 290,
                        top: 0,
                        child: Text(
                          '090 xxx xxxx', //phone number
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'IBM Plex Sans Thai Looped',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 141,
                        top: 1,
                        child: Text(
                          'นิสสานน จีทีอาร', // name costomer
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'IBM Plex Sans Thai Looped',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 140,
                        top: 37,
                        child: Text(
                          'xxxxx@gmail.com', //email costommer
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'IBM Plex Sans Thai Looped',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 32,
                        top: 1,
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: ShapeDecoration(
                            image: DecorationImage(
                              image: NetworkImage("https://placehold.co/58x58"),
                              fit: BoxFit.fill,
                            ),
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 37,
                        top: 270,
                        child: Text(
                          'ข้อมูลการเช่ารถ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'IBM Plex Sans Thai Looped',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        top: 96,
                        child: Container(
                          width: 440,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 9,
                                strokeAlign: BorderSide.strokeAlignCenter,
                                color: Color(0xFFD4D4D4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 23,
                        top: 304,
                        child: Container(
                          width: 385,
                          height: 209,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image:
                                  NetworkImage("https://placehold.co/385x209"),
                              fit: BoxFit.fill,
                            ),
                            boxShadow: [
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
                        left: 0,
                        top: 527,
                        child: Container(
                          width: 482,
                          height: 738,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 95,
                                top: 61,
                                child: SizedBox(
                                  width: 89,
                                  height: 26,
                                  child: SizedBox(
                                    width: 89,
                                    height: 26,
                                    child: Text(
                                      'ประเภทรถ',
                                      style: TextStyle(
                                        color: Color(0xFF8F8F8F),
                                        fontSize: 16,
                                        fontFamily: 'IBM Plex Sans Thai Looped',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 95,
                                top: 79,
                                child: SizedBox(
                                  width: 119,
                                  height: 23,
                                  child: SizedBox(
                                    width: 119,
                                    height: 23,
                                    child: Text(
                                      'รถเก๋ง',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontFamily: 'IBM Plex Sans Thai Looped',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 295,
                                top: 79,
                                child: SizedBox(
                                  width: 119,
                                  height: 23,
                                  child: SizedBox(
                                    width: 119,
                                    height: 23,
                                    child: Text(
                                      'เกียร์ออโต้',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontFamily: 'IBM Plex Sans Thai Looped',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 295,
                                top: 170,
                                child: SizedBox(
                                  width: 119,
                                  height: 23,
                                  child: SizedBox(
                                    width: 119,
                                    height: 23,
                                    child: Text(
                                      'น้ำมันเบนซิน',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontFamily: 'IBM Plex Sans Thai Looped',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 295,
                                top: 255,
                                child: SizedBox(
                                  width: 119,
                                  height: 23,
                                  child: SizedBox(
                                    width: 119,
                                    height: 23,
                                    child: Text(
                                      '1498 CC',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontFamily: 'IBM Plex Sans Thai Looped',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 95,
                                top: 255,
                                child: SizedBox(
                                  width: 119,
                                  height: 23,
                                  child: SizedBox(
                                    width: 119,
                                    height: 23,
                                    child: Text(
                                      '5 ประตู',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontFamily: 'IBM Plex Sans Thai Looped',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 95,
                                top: 170,
                                child: SizedBox(
                                  width: 119,
                                  height: 23,
                                  child: SizedBox(
                                    width: 119,
                                    height: 23,
                                    child: Text(
                                      '5',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontFamily: 'IBM Plex Sans Thai Looped',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 95,
                                top: 335,
                                child: SizedBox(
                                  width: 119,
                                  height: 23,
                                  child: SizedBox(
                                    width: 119,
                                    height: 23,
                                    child: Text(
                                      '2 - 3 ชิ้น',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontFamily: 'IBM Plex Sans Thai Looped',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 295,
                                top: 61,
                                child: SizedBox(
                                  width: 89,
                                  height: 26,
                                  child: SizedBox(
                                    width: 89,
                                    height: 26,
                                    child: Text(
                                      'ระบบเกียร์',
                                      style: TextStyle(
                                        color: Color(0xFF8F8F8F),
                                        fontSize: 16,
                                        fontFamily: 'IBM Plex Sans Thai Looped',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 295,
                                top: 151,
                                child: SizedBox(
                                  width: 123,
                                  height: 26,
                                  child: SizedBox(
                                    width: 123,
                                    height: 26,
                                    child: Text(
                                      'ระบบเชื้อเพลิง',
                                      style: TextStyle(
                                        color: Color(0xFF8F8F8F),
                                        fontSize: 16,
                                        fontFamily: 'IBM Plex Sans Thai Looped',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 95,
                                top: 151,
                                child: SizedBox(
                                  width: 89,
                                  height: 26,
                                  child: SizedBox(
                                    width: 89,
                                    height: 26,
                                    child: Text(
                                      'จำนวนที่นั่ง',
                                      style: TextStyle(
                                        color: Color(0xFF8F8F8F),
                                        fontSize: 16,
                                        fontFamily: 'IBM Plex Sans Thai Looped',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 95,
                                top: 236,
                                child: SizedBox(
                                  width: 124,
                                  height: 26,
                                  child: SizedBox(
                                    width: 124,
                                    height: 26,
                                    child: Text(
                                      'จำนวนประตู',
                                      style: TextStyle(
                                        color: Color(0xFF8F8F8F),
                                        fontSize: 16,
                                        fontFamily: 'IBM Plex Sans Thai Looped',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 95,
                                top: 316,
                                child: SizedBox(
                                  width: 119,
                                  height: 27,
                                  child: SizedBox(
                                    width: 119,
                                    height: 27,
                                    child: Text(
                                      'จำนวนสัมภาระ',
                                      style: TextStyle(
                                        color: Color(0xFF8F8F8F),
                                        fontSize: 16,
                                        fontFamily: 'IBM Plex Sans Thai Looped',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 295,
                                top: 236,
                                child: SizedBox(
                                  width: 140,
                                  height: 23,
                                  child: SizedBox(
                                    width: 140,
                                    height: 23,
                                    child: Text(
                                      'ระบบเครื่องยนต์',
                                      style: TextStyle(
                                        color: Color(0xFF8F8F8F),
                                        fontSize: 16,
                                        fontFamily: 'IBM Plex Sans Thai Looped',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 22,
                                top: 46,
                                child: Container(
                                  width: 89,
                                  height: 335,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          "https://placehold.co/89x335"),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 234,
                                top: 36,
                                child: Container(
                                  width: 91,
                                  height: 334,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          "https://placehold.co/91x334"),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 70,
                                top: 404,
                                child: Text(
                                  'รับรถ',
                                  style: TextStyle(
                                    color: Color(0xFF6E6E6E),
                                    fontSize: 14,
                                    fontFamily: 'IBM Plex Sans Thai Looped',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 250,
                                top: 404,
                                child: Text(
                                  'คืนรถ',
                                  style: TextStyle(
                                    color: Color(0xFF6E6E6E),
                                    fontSize: 14,
                                    fontFamily: 'IBM Plex Sans Thai Looped',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 70,
                                top: 448,
                                child: Text(
                                  '01/01/2025',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'IBM Plex Sans Thai Looped',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 250,
                                top: 448,
                                child: Text(
                                  '02/01/2025',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'IBM Plex Sans Thai Looped',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 70,
                                top: 471,
                                child: SizedBox(
                                  width: 55,
                                  height: 18,
                                  child: SizedBox(
                                    width: 55,
                                    height: 18,
                                    child: Text(
                                      '01.30 น.',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontFamily: 'IBM Plex Sans Thai Looped',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 250,
                                top: 471,
                                child: SizedBox(
                                  width: 55,
                                  height: 18,
                                  child: SizedBox(
                                    width: 55,
                                    height: 18,
                                    child: Text(
                                      '01.30 น.',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontFamily: 'IBM Plex Sans Thai Looped',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 70,
                                top: 425,
                                child: Text(
                                  'สนามบินดอนเมือง',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'IBM Plex Sans Thai Looped',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 250,
                                top: 425,
                                child: Text(
                                  'สนามบินดอนเมือง',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'IBM Plex Sans Thai Looped',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 220,
                                top: 503,
                                child: Transform(
                                  transform: Matrix4.identity()
                                    ..translate(0.0, 0.0)
                                    ..rotateZ(-1.57),
                                  child: Container(
                                    width: 109,
                                    decoration: ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                          width: 1,
                                          strokeAlign:
                                              BorderSide.strokeAlignCenter,
                                          color: Color(0xFFD5D5D5),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: 503,
                                child: Container(
                                  width: 482,
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1,
                                        strokeAlign:
                                            BorderSide.strokeAlignCenter,
                                        color: Color(0xFFD4D4D4),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 35,
                                top: 516,
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
                                left: 35,
                                top: 603,
                                child: Text(
                                  'ค่ามัดจำ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'IBM Plex Sans Thai Looped',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 48,
                                top: 568,
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
                                left: 48,
                                top: 630,
                                child: Text(
                                  '-มัดจำ',
                                  style: TextStyle(
                                    color: Color(0xFF6F6F6F),
                                    fontSize: 14,
                                    fontFamily: 'IBM Plex Sans Thai Looped',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 48,
                                top: 549,
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
                                left: 340,
                                top: 565,
                                child: SizedBox(
                                  width: 63,
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
                              ),
                              Positioned(
                                left: 340,
                                top: 630,
                                child: SizedBox(
                                  width: 47,
                                  child: SizedBox(
                                    width: 47,
                                    child: Text(
                                      '฿200',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'IBM Plex Sans Thai Looped',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 25,
                                top: 679,
                                child: Container(
                                  width: 382,
                                  height: 59,
                                  decoration: ShapeDecoration(
                                    color: Color(0xFFFAF0C5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3)),
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
                                left: 338,
                                top: 697,
                                child: SizedBox(
                                  width: 58,
                                  height: 36,
                                  child: SizedBox(
                                    width: 58,
                                    height: 36,
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '฿',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontFamily:
                                                  'IBM Plex Sans Thai Looped',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '2,000',
                                            style: TextStyle(
                                              color: Color(0xFF0E5EC5),
                                              fontSize: 16,
                                              fontFamily:
                                                  'IBM Plex Sans Thai Looped',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 39,
                                top: 697,
                                child: SizedBox(
                                  width: 169,
                                  height: 36,
                                  child: SizedBox(
                                    width: 169,
                                    height: 36,
                                    child: Text(
                                      'ทั้งหมด',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'IBM Plex Sans Thai Looped',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 45,
                                top: 0,
                                child: Text(
                                  'Honda Jazz',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 24,
                                    fontFamily: 'IBM Plex Sans Thai Looped',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 46,
                        top: 153,
                        child: Container(
                          width: 188,
                          height: 46,
                          decoration: ShapeDecoration(
                            color: Color(0xFFD9D9D9),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: 1),
                              borderRadius: BorderRadius.circular(9),
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
                        left: 60,
                        top: 163,
                        child: Text(
                          'ดาวโหลดเอกสาร',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'IBM Plex Sans Thai Looped',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 195,
                        top: 164,
                        child: Container(
                          width: 24,
                          height: 24,
                          padding: const EdgeInsets.all(4),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 37,
                        top: 110,
                        child: Text(
                          'เอกสารหลักฐาน',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'IBM Plex Sans Thai Looped',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 46,
                        top: 211,
                        child: Text(
                          '*ใช้เป็นหลักฐานในการเช่ารถแบบลายลักษณ์อักษร',
                          style: TextStyle(
                            color: Color(0xFFFF0000),
                            fontSize: 12,
                            fontFamily: 'IBM Plex Sans Thai Looped',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        top: 255,
                        child: Container(
                          width: 440,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 9,
                                strokeAlign: BorderSide.strokeAlignCenter,
                                color: Color(0xFFD4D4D4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        top: 143,
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
                        left: 0,
                        top: 60,
                        child: Container(
                          width: 482,
                          height: 424,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 101,
                                top: 0,
                                child: SizedBox(
                                  width: 119,
                                  height: 23,
                                  child: SizedBox(
                                    width: 119,
                                    height: 23,
                                    child: Text(
                                      '',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontFamily: 'IBM Plex Sans Thai Looped',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 48,
                top: 308,
                child: Container(
                  width: 310,
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
                left: 41,
                top: 34,
                child: Transform(
                  transform: Matrix4.identity()
                    ..translate(0.0, 0.0)
                    ..rotateZ(3.14),
                  child: Container(
                    width: 36,
                    height: 38,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage("https://placehold.co/36x38"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 200,
                top: 375,
                child: Container(
                  width: 184,
                  height: 38,
                  decoration: ShapeDecoration(
                    color: Color(0xFF085BC7),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(6),
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
                left: 10,
                top: 375,
                child: Container(
                  width: 184,
                  height: 38,
                  decoration: ShapeDecoration(
                    color: Color(0xFFFF5353),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(6),
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
                left: 80,
                top: 382,
                child: SizedBox(
                  width: 50,
                  child: SizedBox(
                    width: 50,
                    child: Text(
                      'ปฏิเสธ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'IBM Plex Sans Thai Looped',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 244,
                top: 381,
                child: SizedBox(
                  width: 109,
                  child: SizedBox(
                    width: 109,
                    child: Text(
                      'ยืนยันปล่อยเช่า',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'IBM Plex Sans Thai Looped',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 110,
                top: 315,
                child: Text(
                  'นับเวลาถอยหลัง 02:59:00', // timer
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 40,
                top: 344,
                child: Text(
                  '*หากไม่ดำเนินการภายในเวลาที่กำหนดระบบจะยกเลิกอัตโนมัติ',
                  style: TextStyle(
                    color: Color(0xFFFF0000),
                    fontSize: 12,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 15,
                top: 165,
                child: Container(
                  width: 168,
                  height: 141,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 31,
                        top: 0,
                        child: SizedBox(
                          width: 96,
                          child: SizedBox(
                            width: 96,
                            child: Text(
                              'ร้องขอเช่ารถ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'IBM Plex Sans Thai Looped',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 32,
                        top: 29,
                        child: Text(
                          'ผู้เช่าชำระเงิน',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'IBM Plex Sans Thai Looped',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 32,
                        top: 58,
                        child: Text(
                          'เริ่มการปล่อยใช้รถ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'IBM Plex Sans Thai Looped',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 32,
                        top: 86,
                        child: Text(
                          'รอผู้เช่ายืนยันรับรถ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'IBM Plex Sans Thai Looped',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 33,
                        top: 115,
                        child: Text(
                          'ได้รถคืน',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'IBM Plex Sans Thai Looped',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 2,
                        child: Container(
                          width: 21,
                          height: 21,
                          decoration: ShapeDecoration(
                            color: Color(0xFFFFE36E),
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 31,
                        child: Container(
                          width: 21,
                          height: 21,
                          decoration: ShapeDecoration(
                            color: Color(0xFFD9D9D9),
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 60,
                        child: Container(
                          width: 21,
                          height: 21,
                          decoration: ShapeDecoration(
                            color: Color(0xFFD9D9D9),
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 1,
                        top: 118,
                        child: Container(
                          width: 21,
                          height: 21,
                          decoration: ShapeDecoration(
                            color: Color(0xFFD9D9D9),
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 1,
                        top: 89,
                        child: Container(
                          width: 21,
                          height: 21,
                          decoration: ShapeDecoration(
                            color: Color(0xFFD9D9D9),
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        top: 23,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..translate(0.0, 0.0)
                            ..rotateZ(1.57),
                          child: Container(
                            width: 8,
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
                      ),
                      Positioned(
                        left: 10,
                        top: 52,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..translate(0.0, 0.0)
                            ..rotateZ(1.57),
                          child: Container(
                            width: 8,
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
                      ),
                      Positioned(
                        left: 10,
                        top: 81,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..translate(0.0, 0.0)
                            ..rotateZ(1.57),
                          child: Container(
                            width: 8,
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
                      ),
                      Positioned(
                        left: 10,
                        top: 110,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..translate(0.0, 0.0)
                            ..rotateZ(1.57),
                          child: Container(
                            width: 8,
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    )));
  }
}
