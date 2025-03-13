import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class PhonePage extends StatelessWidget {
  final String rentalId;
  PhonePage({Key? key, required this.rentalId}) : super(key: key);

  // เทมเพลตรายการฉุกเฉิน (mutable เนื่องจากเราจะอัปเดตเบอร์เจ้าของรถ)
  final List<Map<String, dynamic>> emergencyItemsTemplate = [
    {
      'title': 'เจ้าของรถ',
      'subtitle': 'เจ้าของรถ', // placeholder (จะไม่ถูกใช้แล้ว)
      'phone': '0123456789', // placeholder จะถูกแทนที่ด้วยเบอร์จริงจาก Firestore
      'icon': Icons.person,
    },
    {
      'title': 'เหตุด่วนเหตุร้าย',
      'subtitle': 'เหตุด่วนเหตุร้าย',
      'phone': '191',
      'icon': Icons.local_police,
    },
    {
      'title': 'ศูนย์ให้บริการทางการแพทย์',
      'subtitle': 'การแพทย์ฉุกเฉิน',
      'phone': '1669',
      'icon': Icons.health_and_safety,
    },
    {
      'title': 'เหตุเพลิงไหม้',
      'subtitle': 'เหตุเพลิงไหม้',
      'phone': '199',
      'icon': Icons.local_fire_department,
    },
    {
      'title': 'ตำรวจทางหลวง',
      'subtitle': 'ตำรวจทางหลวง',
      'phone': '1193',
      'icon': Icons.directions_car,
    },
    {
      'title': 'อุบัติเหตุทางด่วน',
      'subtitle': 'อุบัติเหตุทางด่วน',
      'phone': '1543',
      'icon': Icons.directions_car,
    },
  ];

  // ฟังก์ชันดึงเบอร์เจ้าของรถจาก Firestore
  Future<String> getOwnerPhone() async {
    // ดึงเอกสาร rentals โดยใช้ rentalId ที่ส่งเข้ามา
    DocumentSnapshot rentalDoc = await FirebaseFirestore.instance
        .collection('rentals')
        .doc(rentalId)
        .get();
    if (rentalDoc.exists) {
      Map<String, dynamic>? rentalData =
          rentalDoc.data() as Map<String, dynamic>?;
      if (rentalData != null && rentalData.containsKey('lessorId')) {
        String lessorId = rentalData['lessorId'];
        // ค้นหาเบอร์เจ้าของรถใน collection users โดยใช้ lessorId
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(lessorId)
            .get();
        if (userDoc.exists) {
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;
          if (userData != null && userData.containsKey('phone')) {
            return userData['phone'];
          }
        }
      }
    }
    return '0123456789'; // fallback หากไม่พบข้อมูล
  }

  // ฟังก์ชันโทรออกจริง ๆ ด้วย url_launcher
  Future<void> _launchPhoneCall(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return FutureBuilder<String>(
      future: getOwnerPhone(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: const Color(0xFFD6EFFF),
            appBar: AppBar(
              backgroundColor: const Color(0xFF00377E),
              centerTitle: true,
              title: const Text(
                'แจ้งปัญหา',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        // ทำสำเนา emergencyItemsTemplate และอัปเดตเบอร์เจ้าของรถ (รายการแรก)
        List<Map<String, dynamic>> emergencyItems =
            List<Map<String, dynamic>>.from(emergencyItemsTemplate);
        for (var item in emergencyItems) {
          if (item['title'] == 'เจ้าของรถ') {
            item['phone'] = snapshot.data; // อัปเดตเบอร์ด้วยค่าใน Firestore
            break;
          }
        }
        return Scaffold(
          backgroundColor: const Color(0xFFD6EFFF),
          appBar: AppBar(
            backgroundColor: const Color(0xFF00377E),
            centerTitle: true,
            title: const Text(
              'แจ้งปัญหา',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
            ),
          ),
          body: SizedBox(
            width: size.width,
            height: size.height,
            child: Column(
              children: [
                for (var item in emergencyItems)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x3F000000),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // ไอคอนซ้ายในวงกลมสีเทาอ่อน
                          Container(
                            margin: const EdgeInsets.all(12),
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD9D9D9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item['icon'],
                              color: Colors.black,
                            ),
                          ),
                          // ข้อความกลาง: ตัวหนาแสดง title และข้อความตัวบาง (แสดงเบอร์)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontFamily: 'IBM Plex Sans Thai Looped',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['phone'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontFamily: 'IBM Plex Sans Thai Looped',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // ปุ่มโทร (สำหรับรายการที่มีเบอร์)
                          if ((item['phone'] as String).isNotEmpty)
                            Container(
                              margin: const EdgeInsets.all(12),
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0065E9),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.call, color: Colors.white),
                                onPressed: () {
                                  _launchPhoneCall(item['phone']);
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
