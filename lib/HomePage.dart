import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ProfileRenter.dart';
import 'CalendarPage.dart';
import 'login_page.dart';  // สำหรับนำทางไปหน้า Login เมื่อ Logout
import 'package:google_sign_in/google_sign_in.dart'; // สำหรับใช้งาน GoogleSignIn

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
    if (pickupDate == null || pickupTime == null || returnDate == null || returnTime == null) {
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF00377E),
        title: const Text("หน้าหลัก"),
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
          // สมมติว่าตรวจสอบว่า user นี้ล็อกอินด้วย Google หรือไม่
          // (กรณีคุณเก็บข้อมูลไว้ใน Firestore หรือ providerData)
          // ตัวอย่างเช่น:
          bool isGoogleLogin = FirebaseAuth.instance.currentUser?.providerData
              .any((p) => p.providerId == 'google.com') ?? false;
          
          return MyDrawerRenter(
            username: username,
            isGoogleLogin: isGoogleLogin,
            profileUrl: profileUrl,
          );
        },
      ),
      body: SingleChildScrollView(
        child: SizedBox(
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
                          GestureDetector(
                            onTap: _openCalendarPage,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9CD9FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                pickupDate != null
                                    ? '${pickupDate!.day}/${pickupDate!.month}/${pickupDate!.year}'
                                    : '01/01/2025',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _openCalendarPage,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9CD9FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                pickupTime != null
                                    ? '${pickupTime!.hour.toString().padLeft(2, '0')}:${pickupTime!.minute.toString().padLeft(2, '0')} น.'
                                    : '01:30 น.',
                                style: const TextStyle(fontSize: 16),
                              ),
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
                          GestureDetector(
                            onTap: _openCalendarPage,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9CD9FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                returnDate != null
                                    ? '${returnDate!.day}/${returnDate!.month}/${returnDate!.year}'
                                    : '02/01/2025',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _openCalendarPage,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9CD9FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                returnTime != null
                                    ? '${returnTime!.hour.toString().padLeft(2, '0')}:${returnTime!.minute.toString().padLeft(2, '0')} น.'
                                    : '01:30 น.',
                                style: const TextStyle(fontSize: 16),
                              ),
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
              
              // Container สำหรับ "ผลการค้นหา" (พื้นหลังสีฟ้า)
              Positioned(
                left: containerLeft,
                top: 400,
                child: Container(
                  width: containerWidth,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6EFFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                      // กล่องขาวแสดงรายการรถ
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: showCarList
                            ? StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance.collection("cars").snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  final docs = snapshot.data!.docs.where((doc) {
                                    final data = doc.data() as Map<String, dynamic>;
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
                                    return distance <= 5000; // 5 km
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
                                    return const Center(child: Text("ไม่พบรถในรัศมี 5km"));
                                  }
                                  
                                  return ListView.builder(
                                    itemCount: docs.length,
                                    itemBuilder: (context, index) {
                                      final data = docs[index].data() as Map<String, dynamic>;
                                      String brand = data["brand"] ?? "";
                                      String model = data["model"] ?? "";
                                      String imageUrl = data["image"]?["carside"] ?? "";
                                      
                                      return Card(
                                        child: ListTile(
                                          leading: imageUrl.isNotEmpty
                                              ? Image.network(
                                                  imageUrl,
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                )
                                              : Container(
                                                  width: 60,
                                                  height: 60,
                                                  color: Colors.grey,
                                                ),
                                          title: Text("$brand $model"),
                                        ),
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
                // ล้างข้อมูลบัญชี Google ออก เพื่อให้ครั้งต่อไปต้องเลือกบัญชีใหม่
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
