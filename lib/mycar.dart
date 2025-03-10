import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'addcar.dart';
import 'ProfileLessor.dart';
import 'editmycar.dart';

class MyCar extends StatelessWidget {
  const MyCar({Key? key}) : super(key: key);

  // ฟังก์ชันลบรูปจาก Imgur โดยใช้ deletehash
  Future<bool> _deleteImageFromImgur(String deleteHash, String clientId) async {
    final uri = Uri.parse('https://api.imgur.com/3/image/$deleteHash');
    final response = await http.delete(
      uri,
      headers: {'Authorization': 'Client-ID $clientId'},
    );
    return response.statusCode == 200;
  }

  // ฟังก์ชันลบรถ: ลบรูปจาก Imgur ทั้งหมด (ตาม deletehash object) แล้วลบ document จาก Firestore
  Future<void> _deleteCar(DocumentSnapshot doc, String clientId) async {
    final data = doc.data() as Map<String, dynamic>;

    // ดึง object deletehash จากโครงสร้าง
    final deleteHashData = (data['deletehash'] ?? {}) as Map<String, dynamic>;

    // วนลูปทุก key ใน deletehash แล้วเรียก _deleteImageFromImgur
    for (String key in deleteHashData.keys) {
      final hash = deleteHashData[key];
      if (hash != null && hash.toString().isNotEmpty) {
        await _deleteImageFromImgur(hash.toString(), clientId);
      }
    }

    // เมื่อเรียกลบรูปจาก Imgur เสร็จแล้ว จึงลบ Document จาก Firestore
    await FirebaseFirestore.instance.collection("cars").doc(doc.id).delete();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("ไม่พบผู้ใช้ที่ login")),
      );
    }
    bool isGoogleLogin =
        user.providerData.any((p) => p.providerId == 'google.com');

    // ดึงข้อมูลผู้ใช้สำหรับ Sidebar
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection("users").doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("ไม่พบข้อมูลผู้ใช้งาน")),
          );
        }
        var userData = snapshot.data!.data() as Map<String, dynamic>;
        String username = userData['username'] ?? "";
        if (username.trim().isEmpty) {
          username = userData['email'] ?? "ไม่มีชื่อ";
        }
        // ดึง URL รูปโปรไฟล์จากข้อมูลผู้ใช้ (ถ้ามี)
        var imageData = userData['image'] ?? {};
        String? profileUrl = imageData['profile'];

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
          drawer: MyDrawer(
            username: username,
            isGoogleLogin: isGoogleLogin,
            profileUrl: profileUrl, // ส่งรูปโปรไฟล์ไปยัง Drawer ด้วย
          ),
          body: StreamBuilder<QuerySnapshot>(
            // ปรับ query ให้ดึงเฉพาะรถของ user ที่ล็อกอินอยู่
            stream: FirebaseFirestore.instance
                .collection("cars")
                .where("ownerId", isEqualTo: user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("เกิดข้อผิดพลาด"));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const Center(child: Text("ไม่มีรถ"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;

                  // รูปรถ (ใช้รูป "carside")
                  String imageUrl = (data["image"] ?? {})["carside"] ?? "";

                  // ยี่ห้อ / รุ่น
                  String brand = data["brand"] ?? "";
                  String model = data["model"] ?? "";

                  // ป้ายทะเบียน
                  String carRegistration = data["Car registration"] ?? "";

                  // วันหมดอายุ
                  Timestamp ts = data["availability"]["availableTo"];
                  DateTime date = ts.toDate();
                  String formattedDate = DateFormat('dd/MM/yyyy').format(date);

                  // สถานะเปิด/ปิด
                  bool isActive = (data["statuscar"] ?? "no") == "yes";

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // รูปภาพ
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 90,
                                    height: 90,
                                    color: Colors.grey,
                                  ),
                          ),
                          const SizedBox(width: 12),

                          // ข้อมูลรถ
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ชื่อยี่ห้อ รุ่น
                                Text(
                                  "$brand $model",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // ป้ายทะเบียน (ถ้ามี)
                                if (carRegistration.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      "ทะเบียน: $carRegistration",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ),
                                // วันหมดอายุ
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      const Text(
                                        "วันหมดอายุ: ",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // แถว: เปิด/ปิดรถ + ปุ่มแก้ไข + ปุ่มลบ
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // เปิด/ปิด
                                      Text(
                                        isActive ? "เปิด" : "ปิด",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Switch(
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        value: isActive,
                                        onChanged: (val) {
                                          FirebaseFirestore.instance
                                              .collection("cars")
                                              .doc(doc.id)
                                              .update({
                                            "statuscar": val ? "yes" : "no"
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      // ปุ่มแก้ไข
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(
                                          Icons.edit,
                                          size: 20,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditVehicleRegistration(
                                                carId: doc.id,
                                                currentImageUrl: (data["image"] ?? {})[
                                                        "vehicle registration"] ??
                                                    "",
                                                currentDeleteHash: (data["deletehash"] ??
                                                        {})[
                                                    "deletehashvehicle_registration"] ??
                                                    "",
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      // ปุ่มลบ พร้อมแสดง overlay ยืนยันและ loading
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 20,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          // แสดง dialog ยืนยันการลบ
                                          bool? confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) => AlertDialog(
                                              title:
                                                  const Text("ยืนยันการลบรถ"),
                                              content: const Text(
                                                  "คุณแน่ใจหรือไม่ว่าต้องการลบรถนี้?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                          context)
                                                      .pop(false),
                                                  child: const Text("ยกเลิก"),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                          context)
                                                      .pop(true),
                                                  child: const Text("ตกลง"),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            // เก็บ BuildContext ของ overlay dialog
                                            BuildContext? dialogContext;
                                            // แสดง overlay loading และเก็บ context
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext ctx) {
                                                dialogContext = ctx;
                                                return Container(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  child: const Center(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        CircularProgressIndicator(),
                                                        SizedBox(height: 10),
                                                        Text(
                                                          "กำลังดำเนินการลบ...",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                            try {
                                              const String clientId =
                                                  "ed6895b5f1bf3d7";
                                              await _deleteCar(doc, clientId);
                                            } finally {
                                              // ใช้ dialogContext ที่เก็บไว้ในการ dismiss overlay
                                              if (dialogContext != null) {
                                                Navigator.pop(dialogContext!);
                                              }
                                            }
                                          }
                                        },
                                      ),
                                    ],
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
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.endFloat,
          floatingActionButton: SizedBox(
            width: 70,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Text('เพิ่มรถ', style: TextStyle(fontSize: 14)),
                ),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddCar()),
                    );
                  },
                  backgroundColor: Colors.white,
                  child:
                      const Icon(Icons.add, color: Colors.black, size: 30),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
