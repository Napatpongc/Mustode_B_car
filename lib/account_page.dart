import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountPage extends StatelessWidget {
  final String docId;

  const AccountPage({super.key, required this.docId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(docId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // กำลังโหลดข้อมูล
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            // ไม่พบเอกสาร หรือเอกสารไม่มีอยู่จริง
            return const Center(child: Text("User not found"));
          }
          // ข้อมูลผู้ใช้
          final userDoc = snapshot.data!.data() as Map<String, dynamic>;
          final username = userDoc['username'] ?? "Unknown";
          final phone = userDoc['phone'] ?? "ไม่ระบุ";

          // -------------------------
          // แปลง address (Map) ให้เป็นสตริง
          // -------------------------
          String formattedAddress = "ไม่ระบุ";
          final addressData = userDoc['address'];
          if (addressData is Map<String, dynamic>) {
            final district = addressData['district'] ?? '';
            final subdistrict = addressData['subdistrict'] ?? '';
            final province = addressData['province'] ?? '';
            final postalCode = addressData['postalCode'] ?? '';
            final moreinfo = addressData['moreinfo'] ?? '';
            formattedAddress =
                "$district, $subdistrict, $province, $postalCode, $moreinfo";
          }

          final profileImage =
              userDoc['image']?['profile'] ?? "https://via.placeholder.com/150";

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // -------------------------
                  // ส่วนบน: รูปโปรไฟล์ + ชื่อ + ดาว
                  // -------------------------
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(profileImage),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star, color: Colors.amber),
                      Icon(Icons.star_border, color: Colors.amber),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // -------------------------
                  // ข้อมูลติดต่อ
                  // -------------------------
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "ที่อยู่: $formattedAddress",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(
                        "เบอร์ติดต่อ : $phone",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // -------------------------
                  // รายการรถ
                  // -------------------------
                  Row(
                    children: const [
                      Text(
                        "รายการรถ",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // ดึงข้อมูลจาก collection 'cars' ระดับบนสุด โดย filter เฉพาะรถที่ ownerId == docId
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('cars')
                        .where('ownerId', isEqualTo: docId)
                        .snapshots(),
                    builder: (context, carSnapshot) {
                      if (carSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!carSnapshot.hasData || carSnapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("ไม่มีข้อมูลรถ"));
                      }
                      final carDocs = carSnapshot.data!.docs;
                      return SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: carDocs.length,
                          itemBuilder: (context, index) {
                            final carData =
                                carDocs[index].data() as Map<String, dynamic>;
                            // ประกอบชื่อรถจาก brand และ model
                            final brand = carData['brand'] ?? '';
                            final model = carData['model'] ?? '';
                            final carName = "$brand $model";

                            // ดึงรูป carfront จาก image (Map)
                            final imageData = carData['image'];
                            String carFrontUrl = '';
                            if (imageData is Map<String, dynamic>) {
                              carFrontUrl = imageData['carfront'] ?? '';
                            }

                            return Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // รูปรถ (เติม BoxFit.contain เพื่อให้รูปพอดีกับกรอบ)
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: carFrontUrl.isNotEmpty
                                          ? Image.network(
                                              carFrontUrl,
                                              fit: BoxFit.contain,
                                            )
                                          : Container(color: Colors.grey),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // ชื่อรถ
                                  Text(
                                    carName,
                                    style: const TextStyle(fontSize: 14),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}