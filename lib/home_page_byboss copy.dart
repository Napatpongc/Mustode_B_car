import 'package:flutter/material.dart';
import 'calendar_page.dart';

void main() {
  runApp(const HomePage());
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        body: ListView(children: [
          Search(),
        ]),
      ),
    );
  }
}

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  DateTime? pickupDate;
  TimeOfDay? pickupTime;
  DateTime? returnDate;
  TimeOfDay? returnTime;

  Future<void> _navigateToCalendar() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CalendarPage()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        pickupDate = result['pickupDate'];
        pickupTime = result['pickupTime'];
        returnDate = result['returnDate'];
        returnTime = result['returnTime'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 440,
          height: 956,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              // Original UI remains completely unchanged
              const Positioned(
                left: 0,
                top: 0,
                child: SizedBox(
                  width: 440,
                  height: 153,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Color(0xFF00377E)),
                  ),
                ),
              ),
              Positioned(
                left: (MediaQuery.of(context).size.width - 95) / 2,
                top: 53,
                child: Container(
                  width: 103,
                  height: 84,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/image/mustodebcarmain.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 19,
                child: Container(
                  width: 60,
                  height: 60,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        3,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 29,
                                height: 4,
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
                left: -9,
                top: 645,
                child: Container(
                  width: 456,
                  height: 321,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFD6EFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 41,
                top: 226,
                child: Container(
                  width: 358,
                  height: 240,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: Colors.black.withOpacity(0.2),
                      ),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    shadows: [
                      BoxShadow(
                        color: const Color(0x3F000000),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 41,
                top: 485,
                child: Container(
                  width: 167,
                  height: 58,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFC5FF92),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: Colors.black.withOpacity(0.2),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadows: [
                      BoxShadow(
                        color: const Color(0x3F000000),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 223,
                top: 485,
                child: Container(
                  width: 176,
                  height: 58,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFFE57D),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: Colors.black.withOpacity(0.2),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadows: [
                      BoxShadow(
                        color: const Color(0x3F000000),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 50,
                top: 493,
                child: const SizedBox(
                  width: 120,
                  height: 28,
                  child: Text(
                    'ค้นหารถว่าง',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 34,
                top: 663,
                child: const SizedBox(
                  width: 383,
                  height: 39,
                  child: Text(
                    'ผลการค้นหา : รถว่างทั้งหมด',
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
                left: 96,
                top: 916,
                child: const SizedBox(
                  width: 212,
                  height: 32,
                  child: Text(
                    'Honda Jazz',
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
                left: 39,
                top: 696,
                child: const SizedBox(
                  width: 179,
                  height: 28,
                  child: Text(
                    'พบรถว่าง 3 คัน',
                    style: TextStyle(
                      color: Color(0xFF09C000),
                      fontSize: 15,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 97,
                top: 235,
                child: const Text(
                  'เลือกวัน-เวลา รับรถ/คืนรถ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 64,
                top: 266,
                child: const Text(
                  'รับรถ',
                  style: TextStyle(
                    color: Color(0xFF575454),
                    fontSize: 16,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 61,
                top: 371,
                child: const Text(
                  'คืนรถ',
                  style: TextStyle(
                    color: Color(0xFF575454),
                    fontSize: 16,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 234,
                top: 492,
                child: const SizedBox(
                  width: 154,
                  height: 27,
                  child: Text(
                    'ค้นหาบนแผนที่',
                    style: TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 11,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 181,
                top: 650,
                child: Container(
                  width: 75,
                  height: 7,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF8F8F8F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 64,
                top: 297,
                child: Container(
                  width: 310,
                  height: 42,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF9CD9FF),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    shadows: [
                      BoxShadow(
                        color: const Color(0x3F000000),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 64,
                top: 408,
                child: Container(
                  width: 310,
                  height: 42,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF9CD9FF),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    shadows: [
                      BoxShadow(
                        color: const Color(0x3F000000),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 53,
                top: 365,
                child: Container(
                  width: 332,
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
                left: 220,
                top: 303,
                child: Transform(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                  child: Container(
                    width: 29,
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
                left: 219,
                top: 414,
                child: Transform(
                  transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(1.57),
                  child: Container(
                    width: 29,
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
              // ---- Date/Time fields with calendar navigation ----
              Positioned(
                left: 79,
                top: 303,
                child: GestureDetector(
                  onTap: _navigateToCalendar,
                  child: Text(
                    pickupDate != null
                        ? '${pickupDate!.day}/${pickupDate!.month}/${pickupDate!.year}'
                        : '01/01/2025',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 256,
                top: 303,
                child: GestureDetector(
                  onTap: _navigateToCalendar,
                  child: Text(
                    pickupTime != null
                        ? '${pickupTime!.hour}:${pickupTime!.minute} น.'
                        : '01:30 น.',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 79,
                top: 414,
                child: GestureDetector(
                  onTap: _navigateToCalendar,
                  child: Text(
                    returnDate != null
                        ? '${returnDate!.day}/${returnDate!.month}/${returnDate!.year}'
                        : '02/01/2025',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 256,
                top: 414,
                child: GestureDetector(
                  onTap: _navigateToCalendar,
                  child: Text(
                    returnTime != null
                        ? '${returnTime!.hour}:${returnTime!.minute} น.'
                        : '01:30 น.',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'IBM Plex Sans Thai Looped',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              // ------------------------------------------------------------------
              Positioned(
                left: 172,
                top: 62,
                child: Container(
                  width: 103,
                  height: 84,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(""),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 359,
                top: 514,
                child: Container(
                  width: 18,
                  height: 22,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/image/pinicon.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 166,
                top: 517,
                child: Container(
                  width: 21,
                  height: 20,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/image/caricon.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 349,
                top: 655,
                child: Container(
                  width: 68,
                  height: 64,
                  decoration: ShapeDecoration(
                    color: const Color(0x846B6B6B),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 371,
                top: 665,
                child: const SizedBox(
                  width: 25,
                  height: 14,
                  child: Text(
                    'ว่าง',
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
                left: 371,
                top: 678,
                child: const SizedBox(
                  width: 48,
                  height: 13,
                  child: Text(
                    'ติดจอง',
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
                left: 371,
                top: 693,
                child: const SizedBox(
                  width: 50,
                  height: 13,
                  child: Text(
                    'ไม่ว่าง',
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
                left: 356,
                top: 667,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFC5FF92),
                    shape: OvalBorder(side: BorderSide(width: 1)),
                  ),
                ),
              ),
              Positioned(
                left: 356,
                top: 681,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFFF399),
                    shape: OvalBorder(side: BorderSide(width: 1)),
                  ),
                ),
              ),
              Positioned(
                left: 356,
                top: 695,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFF8E8E),
                    shape: OvalBorder(side: BorderSide(width: 1)),
                  ),
                ),
              ),
              Positioned(
                left: 41,
                top: 567,
                child: Container(
                  width: 93,
                  height: 31,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFB6B6B6),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadows: [
                      BoxShadow(
                        color: const Color(0x3F000000),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 64,
                top: 574,
                child: const Text(
                  'กรองผล',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontFamily: 'IBM Plex Sans Thai Looped',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Positioned(
                left: 55,
                top: 724,
                child: Container(
                  width: 331,
                  height: 193,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/image/donutscar.png"),
                      fit: BoxFit.fill,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(31),
                    ),
                    shadows: [
                      BoxShadow(
                        color: const Color(0x3F000000),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 73,
                top: 922,
                child: Container(
                  width: 17,
                  height: 17,
                  decoration: ShapeDecoration(
                    color: const Color(0xFFFF8E8E),
                    shape: OvalBorder(side: BorderSide(width: 1)),
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
