import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// เพิ่มไฟล์ booking_page.dart และ signup_page.dart
import 'booking_page.dart';
import 'signup_page.dart';

class CarInfo extends StatefulWidget {
  final String carId;

  // รับวัน-เวลาสำหรับการเช่ารถ
  final DateTime? pickupDate;
  final TimeOfDay? pickupTime;
  final DateTime? returnDate;
  final TimeOfDay? returnTime;

  const CarInfo({
    Key? key,
    required this.carId,
    this.pickupDate,
    this.pickupTime,
    this.returnDate,
    this.returnTime,
  }) : super(key: key);

  @override
  State<CarInfo> createState() => _CarInfoState();
}

class _CarInfoState extends State<CarInfo> {
  int currentImageIndex = 0; // สำหรับเปลี่ยนรูปถัดไป/ก่อนหน้า
  List<String> carImages = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('cars')
          .doc(widget.carId)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("ไม่พบข้อมูลรถ")),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;

        // ข้อมูลพื้นฐาน
        String brand = data["brand"]?.toString() ?? "";
        String model = data["model"]?.toString() ?? "";
        double price = (data["price"] ?? 0).toDouble();
        double deposit = price * 0.15; // มัดจำ 15%

        // detail
        String vehicle = data["detail"]?["Vehicle"]?.toString() ?? "";
        String baggage = data["detail"]?["baggage"]?.toString() ?? "";
        int door = data["detail"]?["door"] ?? 0;
        String engine = data["detail"]?["engine"]?.toString() ?? "";
        String fuel = data["detail"]?["fuel"]?.toString() ?? "";
        String gear = data["detail"]?["gear"]?.toString() ?? "";
        int seat = data["detail"]?["seat"] ?? 0;

        // รูปภาพ
        String carfront = data["image"]?["carfront"]?.toString() ?? "";
        String carside = data["image"]?["carside"]?.toString() ?? "";
        String carback = data["image"]?["carback"]?.toString() ?? "";
        String carinside = data["image"]?["carinside"]?.toString() ?? "";

        carImages = [carfront, carside, carback, carinside]
            .where((url) => url.isNotEmpty)
            .toList();

        // ปรับ currentImageIndex ไม่ให้เกินขอบเขต
        if (currentImageIndex >= carImages.length) {
          currentImageIndex = 0;
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF00377E),
            title: Text(
              "$brand $model",
              style: const TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
          // BottomNavigationBar แสดงราคา, มัดจำ และปุ่ม "เช่ารถ"
          bottomNavigationBar: Container(
            height: MediaQuery.of(context).size.height * 0.1,
            color: const Color(0xFF00377E),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ราคาและมัดจำ
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "฿ ${price.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "มัดจำ ฿ ${deposit.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  // ปุ่ม "เช่ารถ" โดยตรวจสอบสิทธิ์แบบ Anonymous
                  ElevatedButton(
                    onPressed: () {
                      if (FirebaseAuth.instance.currentUser?.isAnonymous ?? true) {
                        // ถ้าเป็น Anonymous ให้แสดง AlertDialog โดยไม่มีปุ่ม "ย้อนกลับ"
                        showDialog(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              title: const Text("กรุณาสมัครบัญชีเพื่อไปรายการต่อไป"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>  SignUpPage()),
                                    );
                                  },
                                  child: const Text("ไปหน้าสมัครบัญชี"),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        // หากไม่เป็น Anonymous ไปหน้า BookingPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingPage(
                              carId: widget.carId,
                              pickupDate: widget.pickupDate,
                              pickupTime: widget.pickupTime,
                              returnDate: widget.returnDate,
                              returnTime: widget.returnTime,
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: const Color(0xFF00377E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      "เช่ารถ",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ส่วน body สำหรับแสดงรูปภาพและรายละเอียดรถ
          body: carImages.isEmpty
              ? const Center(child: Text("ไม่มีรูปภาพรถ"))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // รูปภาพรถ
                      SizedBox(
                        height: 250,
                        child: Stack(
                          children: [
                            Image.network(
                              carImages[currentImageIndex],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 250,
                            ),
                            // ปุ่มรูปก่อนหน้า
                            Positioned(
                              left: 10,
                              top: 100,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_left, size: 40, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    currentImageIndex =
                                        (currentImageIndex - 1 + carImages.length) % carImages.length;
                                  });
                                },
                              ),
                            ),
                            // ปุ่มรูปถัดไป
                            Positioned(
                              right: 10,
                              top: 100,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_right, size: 40, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    currentImageIndex =
                                        (currentImageIndex + 1) % carImages.length;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      // จุดบอกหน้าของรูป (Page Indicator)
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(carImages.length, (index) {
                          bool isActive = (index == currentImageIndex);
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: isActive ? 10 : 8,
                            height: isActive ? 10 : 8,
                            decoration: BoxDecoration(
                              color: isActive ? Colors.blue : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                      // รายละเอียดรถ
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "รายละเอียดรถ",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            // แถวที่ 1: ประเภทรถ / ระบบเกียร์
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildInfoItem(
                                    icon: Icons.directions_car,
                                    label: "ประเภทรถ",
                                    value: vehicle,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildInfoItem(
                                    icon: Icons.settings,
                                    label: "ระบบเกียร์",
                                    value: gear,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // แถวที่ 2: จำนวนที่นั่ง / ระบบเชื้อเพลิง
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildInfoItem(
                                    icon: Icons.event_seat,
                                    label: "จำนวนที่นั่ง",
                                    value: "$seat",
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildInfoItem(
                                    icon: Icons.ev_station,
                                    label: "ระบบเชื้อเพลิง",
                                    value: fuel,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // แถวที่ 3: จำนวนประตู / ระบบเครื่องยนต์
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildInfoItem(
                                    icon: Icons.door_front_door,
                                    label: "จำนวนประตู",
                                    value: "$door",
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildInfoItem(
                                    icon: Icons.build,
                                    label: "ระบบเครื่องยนต์",
                                    value: engine,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // แถวที่ 4: จำนวนสัมภาระ
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildInfoItem(
                                    icon: Icons.card_travel,
                                    label: "จำนวนสัมภาระ",
                                    value: baggage,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(child: SizedBox()),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),

                      // ----------------------------------------------------------------------------
                      // ส่วนแสดง "รีวิวรถ" + คะแนนเฉลี่ยดาว และคะแนนเฉลี่ยความสะอาด
                      // ----------------------------------------------------------------------------
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "รีวิวรถ",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('cars')
                                  .doc(widget.carId)
                                  .collection('carComments')
                                  .get(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                // ถ้าไม่มีรีวิวใด ๆ
                                if (snapshot.data!.docs.isEmpty) {
                                  return const Text("ยังไม่มีรีวิว");
                                }

                                double totalRating = 0;
                                double totalCleanliness = 0;
                                for (var doc in snapshot.data!.docs) {
                                  var commentData = doc.data() as Map<String, dynamic>;
                                  totalRating += (commentData['rating'] ?? 0).toDouble();
                                  totalCleanliness += (commentData['cleanliness'] ?? 0).toDouble();
                                }

                                double avgRating = totalRating / snapshot.data!.docs.length;
                                double avgCleanliness =
                                    totalCleanliness / snapshot.data!.docs.length;

                                return Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.star, color: Colors.amber),
                                                const SizedBox(width: 4),
                                                Text(
                                                  avgRating.toStringAsFixed(1),
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              "ดาว",
                                              style: TextStyle(color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.cleaning_services,
                                                    color: Colors.blue),
                                                const SizedBox(width: 4),
                                                Text(
                                                  avgCleanliness.toStringAsFixed(1),
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              "สะอาด",
                                              style: TextStyle(color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  // Widget สำหรับแสดง icon + label (ตัวบาง) + value (ตัวหนา)
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
