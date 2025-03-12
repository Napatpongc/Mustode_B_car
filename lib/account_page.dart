import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountPage extends StatelessWidget {
  final String docId;

  const AccountPage({super.key, required this.docId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(docId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User not found"));
          }

          final userDoc = snapshot.data!.data() as Map<String, dynamic>;
          final username = userDoc['username'] ?? "Unknown"; // **เพิ่มชื่อ**
          final phone = userDoc['phone'] ?? "ไม่ระบุ";
          final profileImage = userDoc['image']?['profile'] ?? "https://via.placeholder.com/150";

          String formattedAddress = "ไม่ระบุ";
          final addressData = userDoc['address'];
          if (addressData is Map<String, dynamic>) {
            formattedAddress = "${addressData['district'] ?? ''}, ${addressData['subdistrict'] ?? ''}, ${addressData['province'] ?? ''}, ${addressData['postalCode'] ?? ''}, ${addressData['moreinfo'] ?? ''}";
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 250,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      /// **พื้นหลังโค้งที่ปลายล่าง**
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          child: Container(
                            width: double.infinity,
                            height: 185,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(profileImage),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),

                      /// **รูปโปรไฟล์ + ชื่ออยู่ใต้กัน**
                      Positioned(
                        top: 120,
                        left: 30,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// **รูปโปรไฟล์ + ชื่อ**
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 4),
                                      ),
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundImage: NetworkImage(profileImage),
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 15), // **ขยับชื่อให้ต่ำลงอีกนิด**
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        username,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black, // **เปลี่ยนเป็นสีดำ**
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            /// **ดาวรีวิว**
                            Padding(
                              padding: const EdgeInsets.only(right: 16, top: 20),
                              child: Row(
                                children: List.generate(
                                  5,
                                  (index) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 1),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.location_on, color: Colors.red),
                          title: Text("ที่อยู่: $formattedAddress"),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.phone, color: Colors.blue),
                          title: Text("เบอร์ติดต่อ : $phone"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// **เพิ่มกรอบคลุมรายการรถทั้งหมด**
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white, // **สีพื้นหลัง**
                      borderRadius: BorderRadius.circular(16), // **ทำขอบโค้ง**
                      border: Border.all(color: Colors.grey.shade300, width: 2), // **เส้นขอบ**
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          spreadRadius: 2,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        /// **หัวข้อ "รายการรถ"**
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "รายการรถ",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

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
                              height: 180,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: carDocs.length,
                                itemBuilder: (context, index) {
                                  final carData = carDocs[index].data() as Map<String, dynamic>;
                                  final carName = "${carData['brand'] ?? ''} ${carData['model'] ?? ''}";
                                  final carFrontUrl = carData['image']?['carfront'] ?? "";
                                  return Card(
                                    margin: const EdgeInsets.only(right: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: SizedBox(
                                      width: 130,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                              child: carFrontUrl.isNotEmpty
                                                  ? Image.network(carFrontUrl, fit: BoxFit.cover, width: double.infinity)
                                                  : Container(color: Colors.grey, width: double.infinity, height: 100),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              carName,
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
