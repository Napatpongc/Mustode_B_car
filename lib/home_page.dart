import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'map.dart';
import 'ProfileRenter.dart';
import 'login_page.dart';
import 'car_info.dart';
import 'vertical_calendar_page.dart';
import 'list.dart'; // import สำหรับ navigate ไปยัง ListPage
import 'map_forsidebar.dart';

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

  // ควบคุมการแสดงรายการรถและจำนวนรถที่ค้นพบ
  bool showCarList = false;
  int carCount = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // ฟังก์ชันแสดง Alert Dialog แจ้งเตือน
  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("แจ้งเตือน"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text("ตกลง"),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // ฟังก์ชันดึงตำแหน่งปัจจุบันจาก GPS
  // --------------------------------------------------
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        _showAlertDialog("ไม่สามารถเข้าถึงตำแหน่งได้");
        return;
      }
    }

    // ได้รับอนุญาตแล้ว => getCurrentPosition
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (!mounted) return;
    setState(() {
      currentPosition = pos;
    });
  }

  // --------------------------------------------------
  // เปิดหน้า VerticalCalendarPage เพื่อเลือกวัน-เวลารับรถ/คืนรถ
  // --------------------------------------------------
  Future<void> _openCalendarPage() async {
    final result = await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: VerticalCalendarPage(
          initialPickupDate: pickupDate,
          initialPickupTime: pickupTime,
          initialReturnDate: returnDate,
          initialReturnTime: returnTime,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic> && mounted) {
      setState(() {
        pickupDate = result['pickupDate'];
        pickupTime = result['pickupTime'];
        returnDate = result['returnDate'];
        returnTime = result['returnTime'];
      });
    }
  }

  // --------------------------------------------------
  // ฟังก์ชันค้นหารถว่าง
  // --------------------------------------------------
  void _searchCars() {
    if (pickupDate == null ||
        pickupTime == null ||
        returnDate == null ||
        returnTime == null) {
      _showAlertDialog("กรุณาเลือกวัน-เวลา รับรถ/คืนรถ");
      return;
    }
    if (currentPosition == null) {
      _showAlertDialog("ไม่พบตำแหน่งปัจจุบัน");
      return;
    }

    // แค่เปิด list ขึ้นมาแสดง
    if (!mounted) return;
    setState(() {
      showCarList = true;
    });
  }

  // --------------------------------------------------
  // ฟังก์ชันแปลง DateTime + TimeOfDay เป็นสตริง
  // --------------------------------------------------
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

  // --------------------------------------------------
  // build
  // --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double containerWidth = 350;
    final double containerLeft = (screenWidth - containerWidth) / 2;

    final pickupText = _formatDateTime(pickupDate, pickupTime);
    final returnText = _formatDateTime(returnDate, returnTime);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00377E),
        // เปลี่ยน title เป็นรูปจาก assets
        title: Image.asset(
          'assets/image/mustodebcarlogo.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Drawer(
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final username = data['username'] ?? "ไม่มีชื่อ";
          String? profileUrl;
          if (data['image'] != null) {
            profileUrl = data['image']['profile'];
          }
          bool isGoogleLogin = FirebaseAuth.instance.currentUser?.providerData
                  .any((p) => p.providerId == 'google.com') ??
              false;
          return MyDrawerRenter(
            username: username,
            isGoogleLogin: isGoogleLogin,
            profileUrl: profileUrl,
          );
        },
      ),
      // ไล่เฉดสีพื้นหลัง
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB3E5FC),
              Color(0xFFE1F5FE),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: SizedBox(
            width: screenWidth,
            height: screenHeight,
            child: Stack(
              children: [
                // กล่องเลือกวัน-เวลา รับรถ/คืนรถ
                Positioned(
                  left: containerLeft,
                  top: 30,
                  child: Container(
                    width: containerWidth,
                    padding: const EdgeInsets.all(16),
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // แถว "รับรถ"
                        Row(
                          children: [
                            const Text("รับรถ",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black54)),
                            const Spacer(),
                            GestureDetector(
                              onTap: _openCalendarPage,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF9CD9FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  pickupText.split(' ')[0],
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _openCalendarPage,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF9CD9FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  pickupText.split(' ').length > 1
                                      ? pickupText.split(' ')[1]
                                      : '12:30 น.',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // แถว "คืนรถ"
                        Row(
                          children: [
                            const Text("คืนรถ",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black54)),
                            const Spacer(),
                            GestureDetector(
                              onTap: _openCalendarPage,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF9CD9FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  returnText.split(' ')[0],
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _openCalendarPage,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF9CD9FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  returnText.split(' ').length > 1
                                      ? returnText.split(' ')[1]
                                      : '15:30 น.',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // ปุ่ม "ค้นหารถว่าง" / "ค้นหาบนแผนที่"
                Positioned(
                  left: containerLeft,
                  top: 215,
                  child: SizedBox(
                    width: containerWidth,
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _searchCars,
                            icon: const Icon(Icons.directions_car,
                                color: Colors.black),
                            label: const Text(
                              "ค้นหารถว่าง",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC5FF92),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (pickupDate == null ||
                                  pickupTime == null ||
                                  returnDate == null ||
                                  returnTime == null) {
                                _showAlertDialog("กรุณาเลือกวัน-เวลา รับรถ/คืนรถ");
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MapDetailPage(
                                    pickupDate: pickupDate,
                                    pickupTime: pickupTime,
                                    returnDate: returnDate,
                                    returnTime: returnTime,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.location_on,
                                color: Colors.black),
                            label: const Text(
                              "ค้นหาบนแผนที่",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFE57D),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // กล่อง "กรองผล" + "ผลการค้นหา" + List รถ
                Positioned(
                  left: containerLeft,
                  top: 280,
                  child: Container(
                    width: containerWidth,
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
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("กรองผล",
                                  style: TextStyle(color: Colors.black87)),
                            ),
                            const Text(
                              "ผลการค้นหา : รถว่างทั้งหมด",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "พบรถว่าง $carCount คัน",
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF09C000)),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: showCarList
                              ? _buildCarList()
                              : const Center(child: Text("ยังไม่ได้ค้นหา")),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันสร้าง List รถ (เดิมใช้ใน HomePage)
  Widget _buildCarList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("rentals").snapshots(),
      builder: (context, rentalSnapshot) {
        if (!rentalSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final rentalDocs = rentalSnapshot.data!.docs;
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("cars").snapshots(),
          builder: (context, carSnapshot) {
            if (!carSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final userPickup = DateTime(
              pickupDate!.year,
              pickupDate!.month,
              pickupDate!.day,
              pickupTime!.hour,
              pickupTime!.minute,
            );
            final userReturn = DateTime(
              returnDate!.year,
              returnDate!.month,
              returnDate!.day,
              returnTime!.hour,
              returnTime!.minute,
            );

            final docs = carSnapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              // ถ้า statuscar เป็น "no" ให้ไม่แสดง
              if ((data["statuscar"]?.toString().toLowerCase() ?? "") == "no") {
                return false;
              }
              // ตรวจสอบข้อมูลตำแหน่ง
              if (data["location"] == null ||
                  data["location"]["latitude"] == null ||
                  data["location"]["longitude"] == null) {
                return false;
              }
              final double carLat = data["location"]["latitude"];
              final double carLng = data["location"]["longitude"];
              if (currentPosition == null) return false;
              final double distance = Geolocator.distanceBetween(
                currentPosition!.latitude,
                currentPosition!.longitude,
                carLat,
                carLng,
              );
              // สมมติค้นหาในรัศมี 5km
              if (distance > 5000) return false;

              // เช็ค conflict เวลาการเช่า
              for (var rental in rentalDocs) {
                final rentalData = rental.data() as Map<String, dynamic>;
                if (rentalData["carId"] != doc.id) continue;
                final Timestamp rentalStartTs = rentalData["rentalStart"];
                final Timestamp rentalEndTs = rentalData["rentalEnd"];
                final DateTime rentalStart = rentalStartTs.toDate();
                final DateTime rentalEnd = rentalEndTs.toDate();
                if (userPickup.isBefore(rentalEnd) &&
                    userReturn.isAfter(rentalStart)) {
                  final status =
                      (rentalData["status"] ?? "").toString().toLowerCase();
                  if (status != "canceled" &&
                      status != "successed" &&
                      status != "done") {
                    return false;
                  }
                }
              }
              return true;
            }).toList();

            if (docs.isEmpty) {
              return const Center(
                  child: Text("ไม่พบรถในรัศมี 5km หรือรถถูกจองแล้ว"));
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final String brand = data["brand"] ?? "";
                final String model = data["model"] ?? "";
                final String imageUrl = data["image"]?["carside"] ?? "";

                return InkWell(
                  onTap: () {
                    // ไปหน้า CarInfo พร้อมส่ง pickupDate, pickupTime, returnDate, returnTime
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CarInfo(
                          carId: docs[index].id,
                          pickupDate: pickupDate,
                          pickupTime: pickupTime,
                          returnDate: returnDate,
                          returnTime: returnTime,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.circle,
                                  color: Colors.green, size: 12),
                              const SizedBox(width: 8),
                              Text(
                                "$brand $model",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// --------------------------------------------------
// Drawer สำหรับผู้เช่า
// --------------------------------------------------
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
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const HomePage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('แผนที่'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>  MapScreen(
                            // ไม่จำเป็นต้องส่ง parameterอีกครั้งถ้าเรียกจาก Drawer
                          )));
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('รายการเช่าทั้งหมด'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ListPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('ตั้งค่าบัญชี'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => ProfileRenter()));
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
