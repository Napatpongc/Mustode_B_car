import 'package:flutter/material.dart';
import 'home_with_drawer_page.dart';
import 'vertical_calendar_page.dart';

class HomePageByboss extends StatefulWidget {
  const HomePageByboss({Key? key}) : super(key: key);

  @override
  _HomePageBybossState createState() => _HomePageBybossState();
}

class _HomePageBybossState extends State<HomePageByboss> {
  DateTime? pickupDate;
  TimeOfDay? pickupTime;
  DateTime? returnDate;
  TimeOfDay? returnTime;

  // ฟังก์ชันเปิดปฏิทินผ่าน Dialog
  Future<void> _navigateToCalendar() async {
    final result = await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const VerticalCalendarPage(),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        pickupDate = result['startDate'];
        pickupTime = result['pickupTime'];
        returnDate = result['endDate'];
        returnTime = result['returnTime'];
      });
    }
  }

  // ฟังก์ชันช่วยแปลง DateTime กับ TimeOfDay เป็นสตริง
  String formatDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null) return "01/01/2025 01:30 น.";
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    String datePart = "$day/$month/$year";
    if (time == null) return "$datePart 01:30 น.";
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$datePart $hour:$minute น.";
  }

  @override
  Widget build(BuildContext context) {
    final pickupText = formatDateTime(pickupDate, pickupTime);
    final returnText = formatDateTime(returnDate, returnTime);
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page By Boss"),
        backgroundColor: const Color(0xFF00377E),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // เมื่อกด Burger Bar นำทางไปยังหน้า HomeWithDrawerPage (overlay)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeWithDrawerPage(),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // SECTION 3: กล่องเลือกวัน-เวลา รับรถ/คืนรถ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF8FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "เลือกวัน-เวลา รับรถ/คืนรถ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  // แถว "รับรถ"
                  Row(
                    children: [
                      const Text("รับรถ", style: TextStyle(fontSize: 16, color: Colors.black54)),
                      const Spacer(),
                      GestureDetector(
                        onTap: _navigateToCalendar,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9CD9FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(pickupText.split(' ')[0],
                              style: const TextStyle(fontSize: 16, color: Colors.black87)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _navigateToCalendar,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9CD9FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            pickupText.split(' ').length > 1 ? pickupText.split(' ')[1] : '01:30 น.',
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // แถว "คืนรถ"
                  Row(
                    children: [
                      const Text("คืนรถ", style: TextStyle(fontSize: 16, color: Colors.black54)),
                      const Spacer(),
                      GestureDetector(
                        onTap: _navigateToCalendar,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9CD9FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(returnText.split(' ')[0],
                              style: const TextStyle(fontSize: 16, color: Colors.black87)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _navigateToCalendar,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9CD9FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            returnText.split(' ').length > 1 ? returnText.split(' ')[1] : '01:30 น.',
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // SECTION 4: ปุ่ม "ค้นหารถว่าง" / "ค้นหาบนแผนที่"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => debugPrint("ค้นหารถว่าง"),
                  icon: const Icon(Icons.directions_car, color: Colors.black),
                  label: const Text("ค้นหารถว่าง", style: TextStyle(fontSize: 14, color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC5FF92),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => debugPrint("ค้นหาบนแผนที่"),
                  icon: const Icon(Icons.location_on, color: Colors.black),
                  label: const Text("ค้นหาบนแผนที่", style: TextStyle(fontSize: 14, color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE57D),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // SECTION 5: "กรองผล" + ข้อความ "ผลการค้นหา"
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => debugPrint("กรองผล"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("กรองผล", style: TextStyle(color: Colors.black87)),
                      ),
                      const Text(
                        "ผลการค้นหา : รถว่างทั้งหมด",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text("พบรถว่าง 3 คัน", style: TextStyle(fontSize: 14, color: Color(0xFF09C000))),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 120,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                            image: DecorationImage(
                              image: AssetImage("assets/image/donutscar.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text("Honda Jazz", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50), // spacer ด้านล่าง
          ],
        ),
      ),
    );
  }
}
