import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // ใช้ format วันที่

// เพิ่มไฟล์ booking_page.dart และ signup_page.dart
import 'booking_page.dart';
import 'signup_page.dart';

// ประกาศ Palette constants
const Color kDarkBlue = Color(0xFF050C9C); // สีเข้มสุด
const Color kMidBlue = Color(0xFF3572EF); // สีกลาง
const Color kLightBlue = Color(0xFF3ABEF9); // สีสว่าง
const Color kLighterBlue = Color(0xFFA7E6FF); // สีอ่อนสุด

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
      future:
          FirebaseFirestore.instance.collection('cars').doc(widget.carId).get(),
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

        // ดึง ownerId เพื่อใช้ค้นหาร้านรถเช่า
        String ownerId = data["ownerId"] ?? "";

        return Scaffold(
          // ทำให้ปุ่มย้อนกลับ (back arrow) เป็นสีขาว
          appBar: AppBar(
            backgroundColor: kDarkBlue,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              "$brand $model",
              style: const TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
          bottomNavigationBar: Container(
            height: MediaQuery.of(context).size.height * 0.1,
            color: kDarkBlue,
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
                  // ปุ่ม "เช่ารถ"
                  ElevatedButton(
                    onPressed: () {
                      if (FirebaseAuth.instance.currentUser?.isAnonymous ??
                          true) {
                        showDialog(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              title:
                                  const Text("กรุณาสมัครบัญชีเพื่อไปรายการต่อไป"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => SignUpPage()),
                                    );
                                  },
                                  child: const Text("ไปหน้าสมัครบัญชี"),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
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
                      backgroundColor: kLightBlue, // สีสว่างตาม Palette
                      foregroundColor: kDarkBlue, // สีข้อความ
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "เช่ารถ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
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
                                icon: const Icon(
                                  Icons.arrow_left,
                                  size: 40,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    currentImageIndex =
                                        (currentImageIndex - 1 +
                                                carImages.length) %
                                            carImages.length;
                                  });
                                },
                              ),
                            ),
                            // ปุ่มรูปถัดไป
                            Positioned(
                              right: 10,
                              top: 100,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_right,
                                  size: 40,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    currentImageIndex =
                                        (currentImageIndex + 1) %
                                            carImages.length;
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
                              color: isActive ? kMidBlue : Colors.grey,
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
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
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

                      // ร้านรถเช่า
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "ร้านรถเช่า",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(ownerId)
                                  .get(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (!userSnapshot.hasData ||
                                    !userSnapshot.data!.exists) {
                                  return const Text("ไม่พบข้อมูลร้านรถเช่า");
                                }
                                var userData = userSnapshot.data!.data()
                                    as Map<String, dynamic>;
                                String username = userData["username"] ?? "";
                                String profileImage =
                                    userData["image"]?["profile"] ?? "";

                                return Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: profileImage.isNotEmpty
                                          ? NetworkImage(profileImage)
                                          : null,
                                      child: profileImage.isEmpty
                                          ? const Icon(Icons.person)
                                          : null,
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      username,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // เส้นกั้นหมวด
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 16.0,
                        ),
                        child: Divider(color: Colors.grey),
                      ),

                      // ส่วนแสดง "รีวิวรถ" + คะแนนเฉลี่ยดาว และคะแนนเฉลี่ยความสะอาด
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "รีวิวรถ",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
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
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.data!.docs.isEmpty) {
                                  return const Text("ยังไม่มีรีวิว");
                                }

                                double totalRating = 0;
                                double totalCleanliness = 0;
                                for (var doc in snapshot.data!.docs) {
                                  var commentData =
                                      doc.data() as Map<String, dynamic>;
                                  totalRating +=
                                      (commentData['rating'] ?? 0).toDouble();
                                  totalCleanliness +=
                                      (commentData['cleanliness'] ?? 0)
                                          .toDouble();
                                }

                                double avgRating =
                                    totalRating / snapshot.data!.docs.length;
                                double avgCleanliness = totalCleanliness /
                                    snapshot.data!.docs.length;

                                return Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.star,
                                                    color: Colors.amber),
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
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.cleaning_services,
                                                  color: Colors.blue,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  avgCleanliness
                                                      .toStringAsFixed(1),
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
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
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

                      // เว้นช่องว่างก่อนเข้าสู่หมวด "รีวิวจากผู้ใช้งาน"
                      const SizedBox(height: 16),

                      // ---------------------- รีวิวจากผู้ใช้งาน (List) ----------------------
                      // พื้นหลังสีฟ้าอ่อนกว่าสีเดิม + ขอบโค้ง
                      Container(
                        decoration: BoxDecoration(
                          color: kLighterBlue, // สีฟ้าอ่อน
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 16.0,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "รีวิวจากผู้ใช้งาน",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // จำกัดความสูงให้เห็น ~3 รายการ จากนั้นเลื่อนดูที่เหลือ
                            FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('cars')
                                  .doc(widget.carId)
                                  .collection('carComments')
                                  .orderBy('createdAt', descending: true)
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return const Text("ยังไม่มีรีวิว");
                                }

                                final reviews = snapshot.data!.docs;

                                return SizedBox(
                                  height: 360, // ให้แสดงประมาณ 3 รีวิว จากนั้นเลื่อน
                                  child: ListView.builder(
                                    itemCount: reviews.length,
                                    itemBuilder: (context, index) {
                                      var commentDoc = reviews[index];
                                      var commentData = commentDoc.data()
                                          as Map<String, dynamic>;

                                      double rating =
                                          (commentData['rating'] ?? 0)
                                              .toDouble();
                                      double cleanliness =
                                          (commentData['cleanliness'] ?? 0)
                                              .toDouble();
                                      String comment =
                                          commentData['comment'] ?? "";
                                      Timestamp? createdAt =
                                          commentData['createdAt'];
                                      DateTime? commentDate =
                                          createdAt?.toDate();
                                      String formattedDate = commentDate != null
                                          ? DateFormat('dd/MM/yyyy HH:mm')
                                              .format(commentDate)
                                          : "";

                                      String userId =
                                          commentData['userId'] ?? "";

                                      // ดึงข้อมูล user จาก userId
                                      return FutureBuilder<DocumentSnapshot>(
                                        future: FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(userId)
                                            .get(),
                                        builder: (context, userSnapshot) {
                                          if (userSnapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                          if (!userSnapshot.hasData ||
                                              !userSnapshot.data!.exists) {
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                    color: Colors.black),
                                              ),
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: const Text(
                                                  "ไม่พบข้อมูลผู้ใช้"),
                                            );
                                          }

                                          var userData = userSnapshot.data!
                                                  .data()
                                              as Map<String, dynamic>;
                                          String username =
                                              userData["username"] ?? "";
                                          String profileImage =
                                              userData["image"]?["profile"] ??
                                                  "";

                                          return Container(
                                            margin:
                                                const EdgeInsets.only(bottom: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: Colors.black),
                                            ),
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // ด้านซ้าย: Avatar + ชื่อ + คะแนน
                                                CircleAvatar(
                                                  backgroundImage: profileImage
                                                          .isNotEmpty
                                                      ? NetworkImage(
                                                          profileImage)
                                                      : null,
                                                  child: profileImage.isEmpty
                                                      ? const Icon(
                                                          Icons.person)
                                                      : null,
                                                ),
                                                const SizedBox(width: 8),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // ชื่อผู้ใช้
                                                    Text(
                                                      username,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    // คะแนนดาว + คะแนนความสะอาด
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                          size: 16,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          rating.toString(),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        const Icon(
                                                          Icons
                                                              .cleaning_services,
                                                          color: Colors.blue,
                                                          size: 16,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          cleanliness.toString(),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                // ด้านขวา: คอมเมนต์ + วันที่
                                                Expanded(
                                                  child: Container(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.end,
                                                      children: [
                                                        // คอมเมนต์ ตัวใหญ่ขึ้นและตัวหนา
                                                        Text(
                                                          comment,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        // วันที่ (สีดำ)
                                                        Text(
                                                          "วันที่ $formattedDate",
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      // -------------------------------------------------------------
                    ],
                  ),
                ),
        );
      },
    );
  }

  // Widget สำหรับแสดง icon + label + value
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: kMidBlue),
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
