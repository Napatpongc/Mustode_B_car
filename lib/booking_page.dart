import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // import สำหรับ FirebaseAuth
import 'list.dart'; // อย่าลืม import ไฟล์ list.dart ด้วย

class BookingPage extends StatefulWidget {
  final String carId;
  final DateTime? pickupDate;
  final TimeOfDay? pickupTime;
  final DateTime? returnDate;
  final TimeOfDay? returnTime;

  const BookingPage({
    Key? key,
    required this.carId,
    this.pickupDate,
    this.pickupTime,
    this.returnDate,
    this.returnTime,
  }) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  Map<String, dynamic>? carData;
  Map<String, dynamic>? ownerData;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('cars')
          .doc(widget.carId)
          .get(),
      builder: (context, carSnapshot) {
        if (!carSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!carSnapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("ไม่พบข้อมูลรถ")),
          );
        }

        carData = carSnapshot.data!.data() as Map<String, dynamic>;
        final ownerId = carData?['ownerId'] ?? '';

        // ดึงข้อมูลเจ้าของรถ
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(ownerId)
              .get(),
          builder: (context, ownerSnapshot) {
            if (!ownerSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (!ownerSnapshot.data!.exists) {
              return const Scaffold(
                body: Center(child: Text("ไม่พบข้อมูลเจ้าของรถ")),
              );
            }

            ownerData = ownerSnapshot.data!.data() as Map<String, dynamic>;

            return _buildMainScaffold();
          },
        );
      },
    );
  }

  // -------------------------------
  // สร้าง Scaffold หลัก
  // -------------------------------
  Widget _buildMainScaffold() {
    // ดึงข้อมูลรถ
    final String brand = carData?['brand'] ?? '';
    final String model = carData?['model'] ?? '';
    final String carfrontUrl = carData?['carfront'] ?? carData?['image']?['carfront'] ?? '';
    final String gear = carData?['detail']?['gear'] ?? '';
    final String fuel = carData?['detail']?['fuel'] ?? '';
    final double pricePerDay = (carData?['price'] ?? 0).toDouble();

    // ดึงข้อมูลเจ้าของรถ
    final String ownerUsername = ownerData?['username'] ?? '';
    final String ownerProfile = ownerData?['image']?['profile'] ?? '';

    // คำนวณจำนวนวัน
    int days = 1;
    if (widget.pickupDate != null && widget.returnDate != null) {
      final pickupDateTime = DateTime(
        widget.pickupDate!.year,
        widget.pickupDate!.month,
        widget.pickupDate!.day,
        widget.pickupTime?.hour ?? 12,
        widget.pickupTime?.minute ?? 0,
      );
      final returnDateTime = DateTime(
        widget.returnDate!.year,
        widget.returnDate!.month,
        widget.returnDate!.day,
        widget.returnTime?.hour ?? 12,
        widget.returnTime?.minute ?? 0,
      );
      final hoursDiff = returnDateTime.difference(pickupDateTime).inHours;
      days = (hoursDiff / 24).ceil();
      if (days < 1) days = 1;
    }

    // คำนวณราคา
    final double totalRent = pricePerDay * days;
    final double deposit = (totalRent * 0.15).roundToDouble(); // 15%
    final double total = totalRent + deposit;

    // แปลงวัน-เวลา
    final pickupText = _formatDateTime(widget.pickupDate, widget.pickupTime);
    final returnText = _formatDateTime(widget.returnDate, widget.returnTime);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00377E),
        title: const Text("การจอง", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      // -----------------------------------------------------
      // Bottom bar: แสดงจำนวนเงิน + ปุ่ม "ถัดไป"
      // -----------------------------------------------------
      bottomNavigationBar: Container(
        height: 70,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // จำนวนเงินทั้งหมด
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "จำนวนเงินทั้งหมด",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  "฿${total.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            // ปุ่มถัดไป
            ElevatedButton(
              onPressed: () async {
                // สร้าง DateTime สำหรับ pickup และ return
                final pickupDateTime = DateTime(
                  widget.pickupDate?.year ?? 2025,
                  widget.pickupDate?.month ?? 1,
                  widget.pickupDate?.day ?? 1,
                  widget.pickupTime?.hour ?? 12,
                  widget.pickupTime?.minute ?? 0,
                );
                final returnDateTime = DateTime(
                  widget.returnDate?.year ?? 2025,
                  widget.returnDate?.month ?? 1,
                  widget.returnDate?.day ?? 1,
                  widget.returnTime?.hour ?? 12,
                  widget.returnTime?.minute ?? 0,
                );

                // ใช้ renterId เป็น uid ของผู้ใช้ที่ login
                final currentUser = FirebaseAuth.instance.currentUser;
                final renterId = currentUser?.uid ?? '';

                // ดึงข้อมูลตำแหน่งของผู้เช่า (renterLocation) จาก collection 'users'
                final renterDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(renterId)
                    .get();
                final renterLocation = renterDoc.data()?['location'] ??
                    {'latitude': 0.0, 'longitude': 0.0};

                // ดึงข้อมูลตำแหน่งของผู้ให้เช่า (lessorLocation) จาก ownerData ที่ดึงไว้
                final lessorLocation = ownerData?['location'] ??
                    {'latitude': 0.0, 'longitude': 0.0};

                // สร้าง document ใน rentals collection
                await FirebaseFirestore.instance.collection('rentals').add({
                  'renterId': renterId,
                  'lessorId': carData?['ownerId'] ?? '',
                  'carId': widget.carId,
                  'rentalStart': Timestamp.fromDate(pickupDateTime),
                  'rentalEnd': Timestamp.fromDate(returnDateTime),
                  'totalCost': total,
                  'status': 'pending',
                  'renterLocation': renterLocation,
                  'lessorLocation': lessorLocation,
                });

                // Navigate ไปยัง ListPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00377E),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "ถัดไป",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      // -----------------------------------------------------
      // เนื้อหาเลื่อนขึ้นลงได้
      // -----------------------------------------------------
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------------------------------
              // หัวข้อ: สรุปการเดินทาง
              // -------------------------------
              const Text(
                "สรุปการเดินทาง",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // รูปภาพรถ
                    Container(
                      width: 100,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: (carfrontUrl.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                carfrontUrl,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.image_not_supported, size: 40),
                    ),
                    const SizedBox(width: 12),
                    // ข้อมูลรถ
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$brand $model",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "เกียร์: $gear",
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            "เชื้อเพลิง: $fuel",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              _buildGrayDivider(), // เส้นคั่นสีเทา

              // -------------------------------
              // หัวข้อ: วัน รับรถ/คืนรถ
              // -------------------------------
              const SizedBox(height: 16),
              const Text(
                "วัน รับรถ / คืนรถ",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // รับรถ
              Row(
                children: [
                  const Icon(Icons.directions_car, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "$pickupText",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // คืนรถ
              Row(
                children: [
                  const Icon(Icons.directions_car_filled_outlined, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "$returnText",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              _buildGrayDivider(),

              // -------------------------------
              // หัวข้อ: ร้านรถเช่า
              // -------------------------------
              const SizedBox(height: 16),
              const Text(
                "ร้านรถเช่า",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // รูปโปรไฟล์เจ้าของรถ
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: (ownerProfile.isNotEmpty)
                        ? NetworkImage(ownerProfile)
                        : null,
                    child: (ownerProfile.isEmpty)
                        ? const Icon(Icons.person, size: 24, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      ownerUsername,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              _buildGrayDivider(),

              // -------------------------------
              // หัวข้อ: รายการชำระ
              // -------------------------------
              const SizedBox(height: 16),
              const Text(
                "รายการชำระ",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ค่าเช่ารถ
                    Text(
                      "ค่าเช่ารถ $brand $model ฿${pricePerDay.toStringAsFixed(0)} x $days วัน = ฿${totalRent.toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    // ค่ามัดจำ
                    Text(
                      "ค่ามัดจำ ฿${deposit.toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "฿${(total).toStringAsFixed(0)}",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // เพิ่มระยะห่างเผื่อให้เลื่อนขึ้นได้
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // Divider สีเทาอ่อนสำหรับคั่น Section
  // ---------------------------------------------------
  Widget _buildGrayDivider() {
    return Container(
      height: 1,
      color: Colors.grey.shade300,
    );
  }

  // ---------------------------------------------------
  // ฟังก์ชันแปลง DateTime + TimeOfDay เป็น string
  // ---------------------------------------------------
  String _formatDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null) return "01/01/2025 01:30 น.";
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final dateStr = "$day/$month/$year";

    if (time == null) return "$dateStr 01:30 น.";
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return "$dateStr $hh:$mm น.";
  }
}
