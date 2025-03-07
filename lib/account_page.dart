import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountPage extends StatelessWidget {
  final String docId;

  const AccountPage({super.key, required this.docId});

  @override
  Widget build(BuildContext context) {
    print("📌 Fetching user with ownerId: $docId"); // Debugging

    return Scaffold(
      appBar: AppBar(title: const Text('Owner Profile')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(docId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User not found"));
          }

          var userDoc = snapshot.data!.data() as Map<String, dynamic>;

          // ✅ ดึงข้อมูลพื้นฐานของเจ้าของรถ
          String username = userDoc['username'] ?? "Unknown";
          String phone = userDoc['ownedCars']?['phone'] ?? "ไม่ระบุ";
          String profileImage = userDoc['profile'] ?? "https://via.placeholder.com/150";
          String address = "${userDoc['address']?['district'] ?? ''}, ${userDoc['address']?['province'] ?? ''}";
          
          // ✅ ดึงพิกัดเจ้าของรถ
          double latitude = userDoc['location']?['latitude'] ?? 0.0;
          double longitude = userDoc['location']?['longitude'] ?? 0.0;

          // ✅ ดึงรูปภาพจาก `image`
          String drivingLicense = userDoc['image']?['driving_license'] ?? "";
          String idCard = userDoc['image']?['id_card'] ?? "";

          // ✅ ดึงข้อมูลรถที่เจ้าของให้เช่า (รองรับทั้ง Map และ List)
          List<dynamic> cars = [];
          if (userDoc['ownedCars']?['cars'] is List) {
            cars = userDoc['ownedCars']?['cars'];
          } else if (userDoc['ownedCars']?['cars'] is Map) {
            cars = (userDoc['ownedCars']?['cars'] as Map).values.toList();
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 รูปโปรไฟล์ + ชื่อ
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(radius: 50, backgroundImage: NetworkImage(profileImage)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(username, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, color: Colors.blue, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 🔹 รายละเอียดที่อยู่ & เบอร์โทรศัพท์
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(children: [Icon(Icons.location_on, color: Colors.red), SizedBox(width: 6), Text("ที่ตั้ง:")]),
                          Text(address, style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 10),
                          Row(children: [const Icon(Icons.phone, color: Colors.blue), const SizedBox(width: 6), Text("เบอร์ติดต่อ: $phone")]),
                          const SizedBox(height: 10),
                          Text("พิกัด: Lat: $latitude, Lng: $longitude"),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔹 รายการรถที่ให้เช่า
                  const Text("รายการรถ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: cars.length,
                      itemBuilder: (context, index) {
                        var car = cars[index];
                        return CarCard(
                          imageUrl: car['image'] ?? "https://via.placeholder.com/150",
                          name: car['model'] ?? "ไม่ระบุ",
                          status: car['statuscar'] ?? "ไม่ระบุ",
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔹 เอกสารสำคัญ (ใบขับขี่ & บัตรประชาชน)
                  const Text("เอกสารสำคัญ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (drivingLicense.isNotEmpty)
                    Image.network(drivingLicense, height: 100, width: 100, fit: BoxFit.cover),
                  const SizedBox(height: 8),
                  if (idCard.isNotEmpty)
                    Image.network(idCard, height: 100, width: 100, fit: BoxFit.cover),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// 🔹 Widget แสดงข้อมูลรถ
class CarCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String status;

  const CarCard({super.key, required this.imageUrl, required this.name, required this.status});

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == "ว่าง" ? Colors.green : (status == "จองแล้ว" ? Colors.orange : Colors.red);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 120,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.circle, color: statusColor, size: 10),
                    const SizedBox(width: 4),
                    Text(status, style: TextStyle(color: statusColor)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
