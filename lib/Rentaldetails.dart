import 'package:flutter/material.dart';
import 'dart:async';

class Rentaldetails extends StatelessWidget {
  const Rentaldetails({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF00377E),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Duration countdownDuration =
      const Duration(hours: 2, minutes: 59, seconds: 59);
  Timer? timer;

  final List<Map<String, dynamic>> steps = const [
    {"text": "ร้องขอเช่ารถ", "status": "active"},
    {"text": "ผู้เช่าชำระเงิน", "status": "pending"},
    {"text": "เริ่มการปล่อยใช้รถ", "status": "pending"},
    {"text": "รอผู้เช่ายืนยันรับรถ", "status": "pending"},
    {"text": "ได้รถคืน", "status": "pending"},
  ];

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (countdownDuration.inSeconds > 0) {
          countdownDuration -= const Duration(seconds: 1);
        } else {
          timer?.cancel();
        }
      });
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}';
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'รายละเอียด / สถานะ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF00377E),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ สถานะการจอง
            const Text(
              'สถานะการจอง',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
                width: double.infinity,
                height: 1,
                color: const Color(0xFFD4D4D4)),
            const SizedBox(height: 8),

            SizedBox(
              height: 160,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: steps.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 6,
                              backgroundColor:
                                  steps[index]["status"] == "active"
                                      ? const Color(0xFFFFE36E)
                                      : const Color(0xFFD9D9D9),
                            ),
                            if (index != steps.length - 1)
                              Container(
                                  width: 1,
                                  height: 14,
                                  color: const Color(0xFFD9D9D9)),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              steps[index]["text"],
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 2),
            Container(
                width: double.infinity,
                height: 1,
                color: const Color(0xFFD4D4D4)),

            // ✅ นับเวลาถอยหลัง
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  Text(
                    'นับเวลาถอยหลัง ${formatDuration(countdownDuration)}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '*หากไม่ดำเนินการภายในเวลาที่กำหนด ระบบจะยกเลิกอัตโนมัติ',
                    style: TextStyle(color: Color(0xFFFF0000), fontSize: 12),
                  ),
                  const SizedBox(height: 10),

                  // ✅ ปุ่ม
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('กดปุ่มปฏิเสธ')),
                          ),
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                                color: const Color(0xFFFF5353),
                                borderRadius: BorderRadius.circular(6)),
                            child: const Center(
                                child: Text('ปฏิเสธ',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16))),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('กดปุ่มยืนยันปล่อยเช่า')),
                          ),
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                                color: const Color(0xFF085BC7),
                                borderRadius: BorderRadius.circular(6)),
                            child: const Center(
                                child: Text('ยืนยันปล่อยเช่า',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16))),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                      width: double.infinity,
                      height: 9,
                      color: const Color(0xFFD4D4D4)),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // ✅ รายละเอียดผู้เช่า
            const Text('รายละเอียดผู้เช่า',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            Container(
                width: double.infinity,
                height: 1,
                color: const Color(0xFFD4D4D4)),
            const SizedBox(height: 10),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ✅ รูปโปรไฟล์
                Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/58x58"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // ✅ รายละเอียดผู้เช่า
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.person, size: 16, color: Colors.black),
                          SizedBox(width: 5),
                          Text(
                            'นิสสานน จีทีอาร',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: const [
                          Icon(Icons.phone, size: 16, color: Colors.black),
                          SizedBox(width: 5),
                          Text(
                            '090 xxx xxxx',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: const [
                          Icon(Icons.email, size: 16, color: Colors.black),
                          SizedBox(width: 5),
                          Text(
                            'xxxxx@gmail.com',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
                width: double.infinity,
                height: 9,
                color: const Color(0xFFD4D4D4)),
            const SizedBox(height: 10),
            // ✅ เอกสารหลักฐาน
            const Text(
              'เอกสารหลักฐาน',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),

            Container(
              width: double.infinity,
              height: 1,
              color: const Color(0xFFD4D4D4),
            ),
            const SizedBox(height: 5),
            const Text(
              '*ใช้เป็นหลักฐานในการเช่ารถแบบลายลักษณ์อักษร',
              style: TextStyle(
                color: Color(0xFFFF0000),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),

            // ✅ ปุ่มดาวน์โหลดเอกสาร
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('กำลังดาวน์โหลดเอกสาร...')),
                );
              },
              child: Container(
                width: 188,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x3F000000),
                      blurRadius: 4,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    'ดาวน์โหลดเอกสาร',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),
            Container(
                width: double.infinity,
                height: 9,
                color: const Color(0xFFD4D4D4)),
            const SizedBox(height: 10),
            const Text(
              'ข้อมูลการเช่ารถ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),

            // ✅ รูปภาพตัวอย่าง
            Container(
              width: double.infinity,
              height: 209,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      "https://placehold.co/385x209"), //wait picture form back-end
                  fit: BoxFit.fill,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Honda Jazz",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),

            // ✅ เพิ่มข้อมูลรถยนต์แบบ 2 คอลัมน์
            Wrap(
              spacing: 20,
              runSpacing: 10,
              children: [
                buildCarFeature(Icons.directions_car, "ประเภทรถ", "รถเก๋ง"),
                buildCarFeature(Icons.settings, "ระบบเกียร์", "เกียร์ออโต้"),
                buildCarFeature(Icons.event_seat, "จำนวนที่นั่ง", "5"),
                buildCarFeature(
                    Icons.local_gas_station, "ระบบเชื้อเพลิง", "น้ำมันเบนซิน"),
                buildCarFeature(Icons.meeting_room, "จำนวนประตู", "5 ประตู"),
                buildCarFeature(Icons.speed, "ระบบเครื่องยนต์", "1498 CC"),
                buildCarFeature(Icons.luggage, "จำนวนสัมภาระ", "2 - 3 ชิ้น"),
              ],
            ),

            const SizedBox(height: 20),

            // ✅ ข้อมูลรับ-คืนรถ
            const Text('รายละเอียดการรับ-คืนรถ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            Container(
                width: double.infinity,
                height: 1,
                color: const Color(0xFFD4D4D4)),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // จัดให้ชิดขอบ
              children: [
                buildRentalInfo(
                    "รับรถ", "01/01/2025", "01.30 น.", "สนามบินดอนเมือง"),

                // ✅ ปรับให้เส้นอยู่ตรงกลางพอดี
                Container(
                  width: 1, // ความกว้างเส้น
                  height: 100, // ปรับความสูง
                  color: const Color(0xFFD5D5D5),
                ),

                buildRentalInfo(
                    "คืนรถ", "02/01/2025", "01.30 น.", "สนามบินดอนเมือง"),
              ],
            ),

            const SizedBox(height: 20),

            //ใช้จ่าย

            Container(
              width: double.infinity,
              height: 1,
              color: const Color(0xFFD4D4D4),
            ),
            const SizedBox(height: 20),

// ✅ ค่าเช่ารถ
            const Text(
              'ค่าเช่ารถ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),

// ✅ ข้อมูล Honda Jazz
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Honda Jazz',
                      style: TextStyle(
                        color: Color(0xFF6E6E6E),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '- รายต่อวัน ฿900 x 2 วัน',
                      style: TextStyle(
                        color: Color(0xFF6E6E6E),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  '฿1,800',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

// ✅ ค่ามัดจำ
            const Text(
              'ค่ามัดจำ',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),

// ✅ ข้อมูลค่ามัดจำ
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '- มัดจำ',
                  style: TextStyle(
                    color: Color(0xFF6E6E6E),
                    fontSize: 14,
                  ),
                ),
                Text(
                  '฿200',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

// ✅ Container สีเหลืองของ "ทั้งหมด"
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF0C5),
                borderRadius: BorderRadius.circular(3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ทั้งหมด',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: '฿',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: '2,000',
                          style: TextStyle(
                            color: Color(0xFF0E5EC5),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ✅ ฟังก์ชันสร้างแถวข้อมูลรถ
  Widget buildCarFeature(IconData icon, String label, String value) {
    return SizedBox(
      width: 160,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF00377E),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      const TextStyle(color: Color(0xFF8F8F8F), fontSize: 14)),
              Text(value,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ ฟังก์ชันสร้างข้อมูลรับ-คืนรถ
  Widget buildRentalInfo(
      String label, String date, String time, String location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6E6E6E),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          date,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          location,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
      ],
    );
    // ✅ ฟังก์ชันสร้างข้อมูลค่าใช้จ่าย
  }
}
