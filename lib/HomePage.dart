import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ProfileRenter.dart';
import 'CalendarPage.dart';
import 'login_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ***** เพิ่มไฟล์ใหม่ car_info.dart *****
import 'car_info.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // เก็บวัน-เวลารับรถ/คืนรถ
  DateTime? pickupDate;
  TimeOfDay? pickupTime;
  DateTime? returnDate;
  TimeOfDay? returnTime;

  // ตำแหน่งปัจจุบันของผู้ใช้
  Position? currentPosition;

  // ควบคุมว่าจะแสดงรายการรถหรือไม่
  bool showCarList = false;
  // นับจำนวนรถที่พบ
  int carCount = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // ฟังก์ชันดึงตำแหน่งปัจจุบัน
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ไม่สามารถเข้าถึงตำแหน่งได้")),
        );
        return;
      }
    }
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      currentPosition = pos;
    });
  }

  // เปิดหน้า CalendarPage เพื่อเลือกวัน-เวลา รับรถ/คืนรถ
  Future<void> _openCalendarPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CalendarPage(
          initialPickupDate: pickupDate,
          initialPickupTime: pickupTime,
          initialReturnDate: returnDate,
          initialReturnTime: returnTime,
        ),
      ),
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

  // ฟังก์ชันกดปุ่ม "ค้นหารถว่าง"
  void _searchCars() {
    if (pickupDate == null ||
        pickupTime == null ||
        returnDate == null ||
        returnTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเลือกวัน-เวลารับรถ/คืนรถ")),
      );
      return;
    }
    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ไม่พบตำแหน่งปัจจุบัน")),
      );
      return;
    }
    setState(() {
      showCarList = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth  = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // กำหนดความกว้างของ Container สำหรับเลือกวัน-เวลา
    final double containerWidth = 350;
    final double containerLeft  = (screenWidth - containerWidth) / 2;

    return Scaffold(
      // ***** แก้ไขเฉพาะส่วน AppBar เพื่อแสดงรูป *****
      appBar: AppBar(
        backgroundColor: const Color(0xFF00377E),
        // ใส่รูปแทน Text
        title: Image.asset(
          'assets/image/mustodebcarlogo.png',
          height: 40, // ปรับขนาดตามต้องการ
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      // Drawer ดึงข้อมูลจาก Firestore เพื่อแสดงรูปโปรไฟล์และ username จริง
      drawer: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Drawer(child: Center(child: CircularProgressIndicator()));
          }
          var data = snapshot.data!.data() as Map<String, dynamic>;
          String username = data['username'] ?? "ไม่มีชื่อ";
          String? profileUrl;
          if (data['image'] != null) {
            profileUrl = data['image']['profile'];
          }
          bool isGoogleLogin = FirebaseAuth.instance.currentUser?.providerData
              .any((p) => p.providerId == 'google.com') ?? false;

          return MyDrawerRenter(
            username: username,
            isGoogleLogin: isGoogleLogin,
            profileUrl: profileUrl,
          );
        },
      ),
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Stack(
          children: [
            // Container สำหรับเลือกวัน-เวลา รับรถ/คืนรถ
            Positioned(
              left: containerLeft,
              top: 30,
              child: Container(
                width: containerWidth,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "เลือกวัน-เวลา รับรถ/คืนรถ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // รับรถ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("รับรถ: "),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _openCalendarPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9CD9FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            pickupDate != null
                                ? '${pickupDate!.day}/${pickupDate!.month}/${pickupDate!.year}'
                                : '01/01/2025',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _openCalendarPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9CD9FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            pickupTime != null
                                ? '${pickupTime!.hour.toString().padLeft(2, '0')}:${pickupTime!.minute.toString().padLeft(2, '0')} น.'
                                : '01:30 น.',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // คืนรถ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("คืนรถ: "),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _openCalendarPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9CD9FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            returnDate != null
                                ? '${returnDate!.day}/${returnDate!.month}/${returnDate!.year}'
                                : '02/01/2025',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _openCalendarPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9CD9FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          child: Text(
                            returnTime != null
                                ? '${returnTime!.hour.toString().padLeft(2, '0')}:${returnTime!.minute.toString().padLeft(2, '0')} น.'
                                : '01:30 น.',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // ปุ่ม "อัปเดตตำแหน่ง"
                    ElevatedButton(
                      onPressed: _getCurrentLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE0FFD9),
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("อัปเดตตำแหน่ง"),
                    ),
                    const SizedBox(height: 8),
                    // แสดงตำแหน่งปัจจุบัน
                    Text(
                      currentPosition == null
                          ? 'ตำแหน่ง: -'
                          : 'ตำแหน่ง: ${currentPosition!.latitude.toStringAsFixed(4)}, ${currentPosition!.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            // ปุ่ม "ค้นหารถว่าง"
            Positioned(
              left: containerLeft,
              top: 280,
              child: SizedBox(
                width: containerWidth,
                child: ElevatedButton(
                  onPressed: _searchCars,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC5FF92),
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("ค้นหารถว่าง"),
                ),
              ),
            ),

            // พื้นหลังสีฟ้าเต็มจอด้านล่าง + ขอบโค้งมนด้านบน
            Positioned(
              top: 400,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFD6EFFF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ผลการค้นหา : รถว่างทั้งหมด",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "พบรถว่าง $carCount คัน",
                      style: const TextStyle(
                        color: Color(0xFF09C000),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ใช้ Expanded เพื่อให้ ListView ขยายลงมาได้
                    Expanded(
                      child: showCarList
                          ? StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection("rentals")
                                  .snapshots(),
                              builder: (context, rentalSnapshot) {
                                if (!rentalSnapshot.hasData) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                // ดึงข้อมูล rentals ทั้งหมด
                                final rentalDocs = rentalSnapshot.data!.docs;
                                return StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection("cars")
                                      .snapshots(),
                                  builder: (context, carSnapshot) {
                                    if (!carSnapshot.hasData) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }

                                    // สร้าง userPickup และ userReturn จากวันที่และเวลาที่เลือก
                                    DateTime userPickup = DateTime(
                                      pickupDate!.year,
                                      pickupDate!.month,
                                      pickupDate!.day,
                                      pickupTime!.hour,
                                      pickupTime!.minute,
                                    );
                                    DateTime userReturn = DateTime(
                                      returnDate!.year,
                                      returnDate!.month,
                                      returnDate!.day,
                                      returnTime!.hour,
                                      returnTime!.minute,
                                    );

                                    final docs = carSnapshot.data!.docs.where((doc) {
                                      final data = doc.data() as Map<String, dynamic>;

                                      // หาก statuscar เป็น "no" ให้ไม่แสดง
                                      if ((data["statuscar"]?.toString().toLowerCase() ?? "") == "no") {
                                        return false;
                                      }

                                      // ตรวจสอบข้อมูลตำแหน่ง
                                      if (data["location"] == null ||
                                          data["location"]["latitude"] == null ||
                                          data["location"]["longitude"] == null) {
                                        return false;
                                      }
                                      double carLat = data["location"]["latitude"];
                                      double carLng = data["location"]["longitude"];
                                      if (currentPosition == null) return false;
                                      double distance = Geolocator.distanceBetween(
                                        currentPosition!.latitude,
                                        currentPosition!.longitude,
                                        carLat,
                                        carLng,
                                      );
                                      // ต้องอยู่ในรัศมี 5 กม.
                                      if (distance > 5000) return false;

                                      // ตรวจสอบเงื่อนไขการซ้อนทับของวัน-เวลา
                                      bool hasConflict = false;
                                      for (var rental in rentalDocs) {
                                        final rentalData = rental.data() as Map<String, dynamic>;
                                        if (rentalData["carId"] != doc.id) continue;
                                        Timestamp rentalStartTs = rentalData["rentalStart"];
                                        Timestamp rentalEndTs   = rentalData["rentalEnd"];
                                        DateTime rentalStart = rentalStartTs.toDate();
                                        DateTime rentalEnd   = rentalEndTs.toDate();
                                        if (userPickup.isBefore(rentalEnd) && userReturn.isAfter(rentalStart)) {
                                          // หากสถานะไม่ใช่ canceled ให้ถือว่ามีการจองอยู่
                                          if ((rentalData["status"] ?? "").toString().toLowerCase() != "canceled") {
                                            hasConflict = true;
                                            break;
                                          }
                                        }
                                      }
                                      return !hasConflict;
                                    }).toList();

                                    // อัปเดตจำนวนรถ หากค่ามีการเปลี่ยนแปลงจริง
                                    if (carCount != docs.length) {
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        setState(() {
                                          carCount = docs.length;
                                        });
                                      });
                                    }

                                    if (docs.isEmpty) {
                                      return const Center(
                                        child: Text("ไม่พบรถในรัศมี 5km หรือรถถูกจองแล้ว"),
                                      );
                                    }

                                    return ListView.builder(
                                      itemCount: docs.length,
                                      itemBuilder: (context, index) {
                                        final data = docs[index].data() as Map<String, dynamic>;
                                        String brand    = data["brand"]  ?? "";
                                        String model    = data["model"]  ?? "";
                                        String imageUrl = data["image"]?["carside"] ?? "";

                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 16),
                                          // ตกแต่งเป็นกรอบ
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(color: Colors.grey, width: 1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => CarInfo(carId: docs[index].id),
                                                ),
                                              );
                                            },
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // แสดงรูปภาพรถ
                                                if (imageUrl.isNotEmpty)
                                                  ClipRRect(
                                                    borderRadius: const BorderRadius.vertical(
                                                      top: Radius.circular(8),
                                                    ),
                                                    child: Image.network(
                                                      imageUrl,
                                                      width: double.infinity,
                                                      height: 180,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                else
                                                  Container(
                                                    width: double.infinity,
                                                    height: 180,
                                                    color: Colors.grey,
                                                  ),
                                                const SizedBox(height: 8),
                                                // แสดง bullet + ชื่อรถ
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.circle,
                                                        color: Colors.green,
                                                        size: 12,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        "$brand $model",
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                        ),
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
                                  },
                                );
                              },
                            )
                          : const Center(child: Text("ยังไม่ได้ค้นหา")),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Drawer ที่ใช้ร่วมกัน (MyDrawerRenter)
class MyDrawerRenter extends StatelessWidget {
  final String username;
  final bool isGoogleLogin;
  final String? profileUrl;

  const MyDrawerRenter({
    Key? key,
    required this.username,
    required this.isGoogleLogin,
    this.profileUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF00377E)),
            accountName: Text(username, style: const TextStyle(fontSize: 16)),
            accountEmail: null,
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: (profileUrl != null && profileUrl != 'null')
                  ? NetworkImage(profileUrl!)
                  : null,
              child: (profileUrl == null || profileUrl == 'null')
                  ? const Icon(Icons.person, size: 40, color: Colors.grey)
                  : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('หน้าหลัก'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('แผนที่'),
            onTap: () {
              Navigator.pop(context);
              // TODO: นำทางไปหน้าแผนที่
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('รายการเช่าทั้งหมด'),
            onTap: () {
              Navigator.pop(context);
              // TODO: นำทางไปหน้ารายการเช่าทั้งหมด
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('ตั้งค่าบัญชี'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileRenter()));
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('ออกจากระบบ', style: TextStyle(color: Colors.red)),
            onTap: () async {
              if (isGoogleLogin) {
                await GoogleSignIn().disconnect();
              }
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
