import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ProfileLessor.dart'; // นำเข้า MyDrawer จาก ProfileLessor.dart
import 'addcar.dart';

class MyCar extends StatefulWidget {
  const MyCar({Key? key}) : super(key: key);

  @override
  State<MyCar> createState() => _MyCarState();
}

class _MyCarState extends State<MyCar> {
  // ตัวอย่างข้อมูลรถแบบ Mock Data
  final List<CarModel> cars = [
    CarModel(
      name: 'Honda Jazz',
      imageUrl: 'https://via.placeholder.com/150x100.png?text=Honda+Jazz',
      isActive: true,
      expireDate: 'xx/xx/xxxx',
    ),
    CarModel(
      name: 'Toyota Vios',
      imageUrl: 'https://via.placeholder.com/150x100.png?text=Toyota+Vios',
      isActive: false,
      expireDate: 'xx/xx/xxxx',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // ตรวจสอบว่ามีผู้ใช้ที่ล็อกอินอยู่หรือไม่
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("ไม่พบผู้ใช้ที่ login")),
      );
    }

    // ใช้ StreamBuilder เพื่อดึงข้อมูลผู้ใช้จาก Firestore
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String drawerUsername = "กำลังโหลด...";
        bool isGoogleLogin =
            user.providerData.any((p) => p.providerId == 'google.com');

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          drawerUsername = data['username'] ?? "ไม่มีชื่อ";
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('รถฉัน'),
            backgroundColor: const Color(0xFF00377E),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          // ส่งค่า username ที่ดึงมาให้ MyDrawer
          drawer: MyDrawer(
            username: drawerUsername,
            isGoogleLogin: isGoogleLogin,
          ),

          // ส่วนแสดงรายการรถ
          body: cars.isEmpty
              ? const Center(child: Text('ยังไม่มีรถ'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    return _buildCarItem(car);
                  },
                ),

          // ปรับ FloatingActionButton ให้มีข้อความ "เพิ่มรถ" อยู่ด้านบน และปุ่ม "+" สีขาว
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: SizedBox(
            width: 70,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ข้อความ "เพิ่มรถ" อยู่ด้านบน
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    'เพิ่มรถ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                // ปุ่ม "+"
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context, // ต้องใส่ context
                      MaterialPageRoute(
                          builder: (context) =>
                              AddCar()), // ใช้ MaterialPageRoute
                    );
                    // TODO: กดแล้วไปหน้าเพิ่มรถ (ตอนนี้ยังไม่ต้องไปหน้าไหน)
                  },
                  backgroundColor: Colors.white, // พื้นหลังสีขาว
                  child: const Icon(
                    Icons.add,
                    color: Colors.black, // ไอคอน "+" สีดำ
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ฟังก์ชันสร้าง widget ของรายการรถ
  Widget _buildCarItem(CarModel car) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            // รูปรถ
            Container(
              width: 100,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(car.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // ข้อความ (ชื่อรถ + วันหมดอายุ)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('วันหมดอายุ: ${car.expireDate}'),
                ],
              ),
            ),
            // ปุ่มสวิตช์เปิด/ปิดใช้งาน
            Switch(
              value: car.isActive,
              onChanged: (val) {
                setState(() {
                  car.isActive = val;
                });
              },
            ),
            // ปุ่มแก้ไข
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // TODO: เขียน action แก้ไขรายละเอียดรถ
              },
            ),
            // ปุ่มลบ
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // TODO: เขียน action ลบรถ
              },
            ),
          ],
        ),
      ),
    );
  }
}

// โมเดลข้อมูลรถ
class CarModel {
  String name;
  String imageUrl;
  bool isActive;
  String expireDate;

  CarModel({
    required this.name,
    required this.imageUrl,
    required this.isActive,
    required this.expireDate,
  });
}
