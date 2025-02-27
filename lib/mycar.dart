import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'mycar.dart';
import 'addcar.dart';
import 'ProfileLessor.dart';

class MyCar extends StatelessWidget {
  const MyCar({Key? key}) : super(key: key);

  // ฟังก์ชันลบรูปจาก Imgur โดยใช้ deletehash
  Future<bool> _deleteImageFromImgur(String deleteHash, String clientId) async {
    final uri = Uri.parse('https://api.imgur.com/3/image/$deleteHash');
    final response = await http.delete(uri, headers: {'Authorization': 'Client-ID $clientId'});
    return response.statusCode == 200;
  }

  // ฟังก์ชันลบรถ: ลบรูปจาก Imgur ทั้งหมดแล้วลบ document จาก Firestore
  Future<void> _deleteCar(DocumentSnapshot doc, String clientId) async {
    final data = doc.data() as Map<String, dynamic>;
    final image = data['image'] ?? {};
    // ดึง deletehash สำหรับแต่ละรูป (ค่าเหล่านี้เก็บไว้ตอนอัปโหลด)
    String deletehashCar = image['deletehash_car'] ?? "";
    String deletehashVehicleReg = image['deletehash_vehicle_registration'] ?? "";
    String deletehashMotorVehicle = image['deletehash_motor_vehicle'] ?? "";
    String deletehashCheckVehicle = image['deletehash_check_vehicle'] ?? "";

    // ลบรูปจาก Imgur (ถ้ามี deletehash)
    if (deletehashCar.isNotEmpty) {
      await _deleteImageFromImgur(deletehashCar, clientId);
    }
    if (deletehashVehicleReg.isNotEmpty) {
      await _deleteImageFromImgur(deletehashVehicleReg, clientId);
    }
    if (deletehashMotorVehicle.isNotEmpty) {
      await _deleteImageFromImgur(deletehashMotorVehicle, clientId);
    }
    if (deletehashCheckVehicle.isNotEmpty) {
      await _deleteImageFromImgur(deletehashCheckVehicle, clientId);
    }
    // ลบ document ใน Firestore
    await FirebaseFirestore.instance.collection("cars").doc(doc.id).delete();
  }

  @override
  Widget build(BuildContext context) {
    final String clientId = "ed6895b5f1bf3d7"; // Imgur Client ID
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
      drawer: const MyDrawer(username: "User", isGoogleLogin: false),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("cars").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("เกิดข้อผิดพลาด"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("ไม่มีรถ"));
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              // รูปภาพรถ
              String imageUrl = (data["image"] ?? {})["car"] ?? "";
              // ชื่อยี่ห้อและรุ่น
              String brand = data["brand"] ?? "";
              String model = data["model"] ?? "";
              // วันที่ availableFrom (ใช้เป็นวันหมดอายุ)
              Timestamp ts = data["availability"]["availableFrom"];
              DateTime date = ts.toDate();
              String formattedDate = DateFormat('dd/MM/yyyy').format(date);
              // สถานะรถ
              bool isActive = (data["statuscar"] ?? "no") == "yes";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: imageUrl.isNotEmpty
                      ? Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover)
                      : Container(width: 80, height: 80, color: Colors.grey),
                  title: Text("$brand $model", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("วันหมดอายุ: $formattedDate"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // สวิตช์สำหรับเปิด/ปิดสถานะรถ
                      Switch(
                        value: isActive,
                        onChanged: (val) {
                          FirebaseFirestore.instance.collection("cars").doc(doc.id)
                              .update({"statuscar": val ? "yes" : "no"});
                        },
                      ),
                      // ปุ่มแก้ไข (ยังไม่มี event)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // TODO: เพิ่ม event แก้ไข
                        },
                      ),
                      // ปุ่มลบ
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await _deleteCar(doc, clientId);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text('เพิ่มรถ', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            ),
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddCar()),
                );
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.add, color: Colors.black, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
