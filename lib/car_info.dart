import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CarInfo extends StatefulWidget {
  final String carId;
  const CarInfo({Key? key, required this.carId}) : super(key: key);

  @override
  State<CarInfo> createState() => _CarInfoState();
}

class _CarInfoState extends State<CarInfo> {
  int currentImageIndex = 0; // สำหรับเปลี่ยนรูปถัดไป/ก่อนหน้า
  
  // เก็บ url รูป 4 รูปหลัก
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
        
        // หากในฐานข้อมูลบางฟิลด์เป็น int เราแปลงเป็น String ด้วย .toString()
        String brand = data["brand"]?.toString() ?? "";
        String model = data["model"]?.toString() ?? "";
        
        // ข้อมูลรายละเอียดใน detail
        int door = data["detail"]?["door"] ?? 0;
        int seat = data["detail"]?["seat"] ?? 0;
        String gear = data["detail"]?["gear"]?.toString() ?? "";
        String engine = data["detail"]?["engine"]?.toString() ?? "";
        String baggage = data["detail"]?["baggage"]?.toString() ?? "";
        
        // ราคาและมัดจำ
        double price = (data["price"] ?? 0).toDouble();
        double deposit = price * 0.15; // มัดจำ 15%
        
        // รูปภาพ (แปลงเป็น String ด้วย)
        String carfront  = data["image"]?["carfront"]?.toString()  ?? "";
        String carside   = data["image"]?["carside"]?.toString()   ?? "";
        String carback   = data["image"]?["carback"]?.toString()   ?? "";
        String carinside = data["image"]?["carinside"]?.toString() ?? "";
        
        // รวมรูปเป็น list เพื่อให้เลื่อนซ้ายขวา
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
            title: Text("$brand $model"),
            centerTitle: true,
          ),
          // Bottom App Bar ด้วย Container ที่มีความสูงคงที่ (แก้ปัญหา overflow)
          bottomNavigationBar: Container(
  height: MediaQuery.of(context).size.height * 0.1, // 10% ของความสูงหน้าจอ
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
        // ปุ่มเช่ารถ
        ElevatedButton(
          onPressed: () {
            // TODO: กดปุ่มเช่ารถ (ยังไม่ทำ event)
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

          body: carImages.isEmpty
              ? const Center(child: Text("ไม่มีรูปภาพรถ"))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // รูปภาพรถชิดกับ AppBar
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
                            // ปุ่มก่อนหน้า
                            Positioned(
                              left: 10,
                              top: 100,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_left, size: 40, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    currentImageIndex = (currentImageIndex - 1 + carImages.length) % carImages.length;
                                  });
                                },
                              ),
                            ),
                            // ปุ่มถัดไป
                            Positioned(
                              right: 10,
                              top: 100,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_right, size: 40, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    currentImageIndex = (currentImageIndex + 1) % carImages.length;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // รายละเอียดรถ จัดเรียงให้ใช้พื้นที่คุ้ม
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "รายละเอียดรถ",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            // แถวแรก: ประตู, ที่นั่ง, เกียร์
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildInfoItem(
                                  icon: Icons.directions_car,
                                  label: "ประตู",
                                  value: "$door",
                                ),
                                _buildInfoItem(
                                  icon: Icons.event_seat,
                                  label: "ที่นั่ง",
                                  value: "$seat",
                                ),
                                _buildInfoItem(
                                  icon: Icons.settings,
                                  label: "เกียร์",
                                  value: gear,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // แถวที่สอง: เครื่องยนต์, กระเป๋า
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildInfoItem(
                                  icon: Icons.local_fire_department,
                                  label: "เครื่องยนต์",
                                  value: engine,
                                ),
                                _buildInfoItem(
                                  icon: Icons.card_travel,
                                  label: "กระเป๋า",
                                  value: baggage,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
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
  
  // Widget สำหรับแสดงไอคอน + label + value
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.blueAccent),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
