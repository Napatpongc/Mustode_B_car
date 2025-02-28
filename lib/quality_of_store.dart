import 'package:flutter/material.dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
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
          QualityOfStore(),
        ]),
      ),
    );
  }
}

class QualityOfStore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 440,
          height: 956,
          clipBehavior: Clip.antiAlias,//ตัดขอบให้ดูsmooth
          decoration: BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 440,
                  height: 116,
                  decoration: BoxDecoration(color: Color(0xFF00377E)),
                ),
              ),
              Positioned( //'รีวิวโดยรวม'
                left: 159,
                top: 65,
                child: SizedBox(
                  width: 146,
                  height: 38,
                  child: Text(
                    'รีวิวโดยรวม',
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
                left: 26,
                top: 337,
                child: SizedBox(
                  width: 63,
                  height: 21,
                  child: Text(
                    'ช่วงเวลา',
                    style: TextStyle(
                      color: Color(0xFF6D6D6D),
                      fontSize: 14,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 27,
                top: 392,
                child: SizedBox(
                  width: 84,
                  height: 23,
                  child: Text(
                    '1 - 3 ธ.ค 67',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 336,
                top: 393,
                child: SizedBox(
                  width: 46,
                  height: 23,
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 229,
                top: 394,
                child: SizedBox(
                  width: 29,
                  height: 23,
                  child: Text(
                    '4.7',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 229,
                top: 443,
                child: SizedBox(
                  width: 29,
                  height: 23,
                  child: Text(
                    '4.9',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 337,
                top: 443,
                child: SizedBox(
                  width: 46,
                  height: 23,
                  child: Text(
                    '2',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 28,
                top: 442,
                child: SizedBox(
                  width: 84,
                  height: 23,
                  child: Text(
                    '1 - 7 ม.ค 67',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 311,
                top: 338,
                child: SizedBox(
                  width: 79,
                  height: 21,
                  child: Text(
                    'ความสะอาด',
                    style: TextStyle(
                      color: Color(0xFF6D6D6D),
                      fontSize: 14,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 239,
                top: 340,
                child: SizedBox(
                  width: 31,
                  height: 21,
                  child: Text(
                    'รีวิว',
                    style: TextStyle(
                      color: Color(0xFF6D6D6D),
                      fontSize: 14,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(//รุปเครื่องหมายน้อยกว่าสำหรับกลับไปหน้าก่อน
                left: 10,
                top: 10,
                child: Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(//เป็น Decoration ที่ใช้กับ Container เพื่อกำหนด ...,รูปภาพ
                    image: DecorationImage(//ใช้สำหรับกำหนด รูปภาพ ให้กับ Container
                      image: AssetImage("assets/image/lessterthan_sign_image.png"),
                      fit: BoxFit.fill,//ขยายภาพให้เต็มพื้นที่โดย ยืด/บีบ ภาพให้เต็ม Container
                    ),
                  ),
                ),
              ),
              /*Positioned(
  left: 41,
  top: 20,
  child: Transform(
    transform: Matrix4.identity()..rotateZ(3.14), // หมุน 180 องศา
    child: Container(
      width: 36,
      height: 38,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/image/star_icon.png"), // ใส่รูปไอคอนลูกศรย้อนกลับที่ถูกต้อง
          fit: BoxFit.cover,
        ),
      ),
    ),
  ),
),*/ //เป็นรูปลูกษรย้อนกลับน่าซ้ำกับอันบน
              Positioned(//เส้นบาร์เลื่อน
                left: 432,
                top: 175,
                child: Container(
                  width: 5,
                  height: 752,
                  decoration: ShapeDecoration(
                    color: Color(0xFF00377E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                ),
              ),
              Positioned(//กรอบดาวเฉลี่ย
                left: 35,
                top: 188,
                child: Container(
                  width: 168,
                  height: 101,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              Positioned(//กรอบโตโยต้า
                left: 72,
                top: 122,
                child: Container(
                  width: 291,
                  height: 40,
                  decoration: ShapeDecoration(
                    color: Color(0xFFD6EFFF),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              Positioned(//กรอบคะแนนความสะอาด
                left: 237,
                top: 188,
                child: Container(
                  width: 168,
                  height: 101,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 98,
                top: 199,
                child: SizedBox(
                  width: 40,
                  height: 28,
                  child: Text(
                    'รีวิว',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 111,
                top: 233,
                child: SizedBox(
                  width: 40,
                  height: 33,
                  child: Text(
                    '4.4',
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
                left: 309,
                top: 233,
                child: SizedBox(
                  width: 40,
                  height: 26,
                  child: Text(
                    '3.2',
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
                left: 267,
                top: 199,
                child: SizedBox(
                  width: 112,
                  height: 25,
                  child: Text(
                    'ความสะอาด',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(//รูปดาวตรงรีวิวเฉลี่ย
                left: 72,
                top: 235,
                child: Container(
                  width: 32,
                  height: 26,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/image/star_icon.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(//รูปไม้กวาดตรงความสะอาด
                left: 269,
                top: 235,
                child: Container(
                  width: 32,
                  height: 26,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/image/broom_icon.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            /*  Positioned(
  left: 283,
  top: 238,
  child: Container(
    width: 26,
    height: 26,
    padding: const EdgeInsets.all(3.25),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 19.50,
          height: 19.50,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/image/broom_icon.png"), // แสดงไอคอนไม้กวาด
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    ),
  ),
),*///เป็นรูปไม้กวาดทำความสะอาดซำ้กับด้านบน

             Positioned(//ดาวที่ใส่ในรีวิวของอันแรก(1-3ธค67)
  left: 360,
  top: 393,
  child: Container(
    width: 19.50,
    height: 19.50,
    child: Image.asset("assets/image/broom_icon.png"), // ใส่รูปไม้กวาด
  ),
),
Positioned(//ดาวที่ใส่ในรีวิวของอันสอง(1-7มค67)
  left: 360,
  top: 443,
  child: Container(
    width: 19.50,
    height: 19.50,
    child: Image.asset("assets/image/broom_icon.png"), // ใส่รูปไม้กวาด
  ),
),
Positioned(// ดาวที่ใส่ใน comment ของอันแรก (1-3 ธค 67)
  left: 252,
  top: 391,
  child: Container(
    width: 19.50,
    height: 19.50,
    child: Image.asset("assets/image/star_icon.png"), // ใส่รูปดาว
  ),
),
Positioned(// ดาวที่ใส่ใน comment ของอันที่สอง (1-7 มค 67)
  left: 252,
  top: 442, // ปรับ top ให้ห่างจากอันแรก
  child: Container(
    width: 19.50,
    height: 19.50,
    child: Image.asset("assets/image/star_icon.png"), // ใส่รูปดาว
  ),
),


              Positioned(//เป็นกรอบสีเทาเอาไว้ใส่ข้อความของ 'คะแนนที่ให้ความสะอาดสูงสุด',
                left: 158,
                top: 296,
                child: Container(
                  width: 142,
                  height: 17,
                  decoration: ShapeDecoration(
                    color: Color(0xFFD9D9D9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  ),
                ),
              ),
              Positioned(
                left: 181,
                top: 299,
                child: Text(
                  'คะแนนที่ให้ความสะอาดสูงสุด',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 7,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(//เป็นกรอบสีเทาเอาไว้ใส่ข้อความของ 'คะแนนที่ให้ดาวสูงสุด'
                left: 33,
                top: 296,
                child: Container(
                  width: 105,
                  height: 17,
                  decoration: ShapeDecoration(
                    color: Color(0xFFD9D9D9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  ),
                ),
              ),
              Positioned(
                left: 47,
                top: 299,
                child: Text(
                  'คะแนนที่ให้ดาวสูงสุด',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 7,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 175,
                top: 130,
                child: Text(
                  'Toyota Vios',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 75,
                top: 168,
                child: Text(
                  'คะแนนดาวเฉลี่ย',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 245,
                top: 168,
                child: Text(
                  'คะแนนความสะอาดเฉลี่ย',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(//เป็นรูปไอคอนดาวอันเล็กมากๆ ที่อยู่ในกรอบสีเทาที่มีข้อความว่า 'คะแนนที่ให้ดาวสูงสุด'
                left: 36,
                top: 301,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/image/star_icon.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 166,
                top: 300,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/image/broom_icon.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),

              Positioned(//เป็นไอคอนรูปสามเหลี่ยมเล็กมากๆ ตรงข้อความ คะแนนที่ให้ดาวสูงสุด
                left: 130,
                top: 307,
                child: Transform(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(3.14),
                  child: Container(
                    width: 6,
                    height: 5,
                    decoration: ShapeDecoration(
                      color: Color(0xFFA6A6A6),
                      shape: StarBorder.polygon(sides: 3),
                    ),
                  ),
                ),
              ),

              Positioned(//เป็นไอคอนรูปสามเหลี่ยมเล็กมากๆ ตรงข้อความ คะแนนที่ให้ความสะอาดสูงสุด
                left: 291,
                top: 307,
                child: Transform(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(3.14),
                  child: Container(
                    width: 6,
                    height: 5,
                    decoration: ShapeDecoration(
                      color: Color(0xFFA6A6A6),
                      shape: StarBorder.polygon(sides: 3),
                    ),
                  ),
                ),
              ),
              Positioned(//ลูกศรเปลี่ยนรถเลื่อนไปทางขวา
                left: 355,
                top: 132,
                child: Transform(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                  child: Container(
                    width: 20,
                    height: 17,
                    decoration: ShapeDecoration(
                      color: Colors.black,
                      shape: StarBorder.polygon(sides: 3),
                    ),
                  ),
                ),
              ),
              Positioned(//ลูกศรเปลี่ยนรถเลื่อนไปทางซ้าย
  left: 79,
  top: 152,
  child: Transform(
    transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-1.57), // เปลี่ยนเป็น -90 องศา (ชี้ซ้าย)
    child: Container(
      width: 20,
      height: 17,
      decoration: ShapeDecoration(
        color: Colors.black,
        shape: StarBorder.polygon(sides: 3), // สามเหลี่ยมสีดำ
      ),
    ),
  ),
),

              
              Positioned(//เส้น ดำข้างล่างช่วงเวลา รีวิว
                left: -3,
                top: 375,
                child: Container(
                  width: 440,
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
              Positioned(//เส้นดำต่อจากบรรทัดบน
                left: 0,
                top: 428,
                child: Container(
                  width: 440,
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
              Positioned(//เส้นดำบรร
                left: 0,
                top: 478,
                child: Container(
                  width: 440,
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
              Positioned( //เส้นดำบรรทัดแรก
                left: 0,
                top: 324,
                child: Container(
                  width: 440,
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
            ],
          ),
        ),
      ],
    );
  }
}