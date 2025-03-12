import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart'; //https: //console.firebase.google.com/u/4/project/mustodebcar-ac28a/overview
import 'car_info.dart';

class AccountPage extends StatefulWidget {
  final String docId;
  final DateTime? pickupDate;
  final TimeOfDay? pickupTime;
  final DateTime? returnDate;
  final TimeOfDay? returnTime;
  final double? currentLat;
  final double? currentLng;

  const AccountPage({
    Key? key,
    required this.docId,
    this.pickupDate,
    this.pickupTime,
    this.returnDate,
    this.returnTime,
    this.currentLat,
    this.currentLng,
  }) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(widget.docId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User not found"));
          }

          final userDoc = snapshot.data!.data() as Map<String, dynamic>;
          final username = userDoc['username'] ?? "Unknown";
          final phone = userDoc['phone'] ?? "ไม่ระบุ";
          final profileImage = userDoc['image']?['profile'] ?? "https://via.placeholder.com/150";

          String formattedAddress = "ไม่ระบุ";
          final addressData = userDoc['address'];
          if (addressData is Map<String, dynamic>) {
            formattedAddress =
                "${addressData['district'] ?? ''}, ${addressData['subdistrict'] ?? ''}, ${addressData['province'] ?? ''}, ${addressData['postalCode'] ?? ''}, ${addressData['moreinfo'] ?? ''}";
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
                      // พื้นหลังโค้งที่ปลายล่าง
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
                      // รูปโปรไฟล์ + ชื่อ
                      Positioned(
                        top: 120,
                        left: 30,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                                    const SizedBox(height: 15),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        username,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
                  // รายการรถ (กรองตามเงื่อนไขเหมือนใน HomePage)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300, width: 2),
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
                        _buildCarList(),
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

  Widget _buildCarList() {
    // ใช้ nested StreamBuilder เพื่อดึง rentals และ cars ของเจ้าของ (ownerId == widget.docId)
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("rentals").snapshots(),
      builder: (context, rentalSnapshot) {
        if (!rentalSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final rentalDocs = rentalSnapshot.data!.docs;
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("cars")
              .where('ownerId', isEqualTo: widget.docId)
              .snapshots(),
          builder: (context, carSnapshot) {
            if (!carSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (widget.pickupDate == null ||
                widget.pickupTime == null ||
                widget.returnDate == null ||
                widget.returnTime == null ||
                widget.currentLat == null ||
                widget.currentLng == null) {
              return const Center(child: Text("กรุณาเลือกวันและเวลา"));
            }

            final userPickup = DateTime(
              widget.pickupDate!.year,
              widget.pickupDate!.month,
              widget.pickupDate!.day,
              widget.pickupTime!.hour,
              widget.pickupTime!.minute,
            );
            final userReturn = DateTime(
              widget.returnDate!.year,
              widget.returnDate!.month,
              widget.returnDate!.day,
              widget.returnTime!.hour,
              widget.returnTime!.minute,
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
              final double distance = Geolocator.distanceBetween(
                widget.currentLat!,
                widget.currentLng!,
                carLat,
                carLng,
              );
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
                  final status = (rentalData["status"] ?? "").toString().toLowerCase();
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

            return SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final String brand = data["brand"] ?? "";
                  final String model = data["model"] ?? "";
                  final String carFrontUrl = data["image"]?["carfront"] ?? "";
                  return InkWell(
                    onTap: () {
                      // Navigate ไปหน้า CarInfo พร้อมส่ง parameter
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CarInfo(
                            carId: docs[index].id,
                            pickupDate: widget.pickupDate,
                            pickupTime: widget.pickupTime,
                            returnDate: widget.returnDate,
                            returnTime: widget.returnTime,
                          ),
                        ),
                      );
                    },
                    child: Card(
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
                                "$brand $model",
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
