import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ProfileLessor.dart'; // นำเข้า ProfileLessor

class ProfileRenter extends StatefulWidget {
  @override
  _ProfileRenterState createState() => _ProfileRenterState();
}

class _ProfileRenterState extends State<ProfileRenter> {
  @override
  Widget build(BuildContext context) {
    final String? userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null) {
      return Scaffold(
        body: Center(child: Text("ไม่พบผู้ใช้ที่ login")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00377E),
        title: Text('บัญชี (ผู้เช่า)'),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // เปิดเมนูหรือ drawer ตามต้องการ
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('renter')
            .where('email', isEqualTo: userEmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text("เกิดข้อผิดพลาด"));
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(child: Text("ไม่พบข้อมูลผู้ใช้งาน"));

          var renterData =
              snapshot.data!.docs.first.data() as Map<String, dynamic>;

          // รวมข้อมูลที่อยู่
          String address =
              "${renterData['province'] ?? ''} ${renterData['district'] ?? ''}\n"
              "${renterData['subdistrict'] ?? ''} ${renterData['postCode'] ?? ''}\n"
              "${renterData['moreInfo'] ?? ''}";

          String phone = renterData['phone'] ?? '';
          String email = renterData['email'] ?? '';
          String username = renterData['username'] ?? 'Name';

          return SingleChildScrollView(
            child: Column(
              children: [
                // ส่วนหัวแสดง Avatar และชื่อผู้ใช้
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person, size: 40, color: Colors.blue),
                      ),
                      SizedBox(width: 16),
                      Text(username,
                          style: TextStyle(fontSize: 24, color: Colors.black)),
                      Spacer(),
                      Icon(Icons.edit, color: Colors.blue),
                    ],
                  ),
                ),

                // Switch สำหรับสลับไปหน้าผู้ปล่อยเช่า
                SwitchListTile(
                  title: Text('ผู้เช่า / ผู้ปล่อยเช่า (ผู้เช่า)'),
                  value: true,
                  onChanged: (value) {
                    if (!value) {
                      // เมื่อสวิตช์ถูกเปลี่ยนเป็น false ให้ navigate ไปที่ ProfileLessor
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProfileLessor()));
                    }
                  },
                  secondary: Icon(Icons.swap_horiz),
                ),

                // ส่วนข้อมูลหลัก
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0x9ED6EFFF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoField('ที่อยู่:', address),
                      _buildInfoField('เบอร์โทรศัพท์:', phone),
                      _buildInfoField('อีเมล:', email),
                      SizedBox(height: 20),
                      Text(
                        'รูปใบขับขี่',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      SizedBox(height: 5),
                      ElevatedButton.icon(
                        onPressed: () {
                          // ฟังก์ชันอัปโหลดไฟล์รูปใบขับขี่
                        },
                        icon: Icon(Icons.upload),
                        label: Text('เลือกรูป'),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'หมายเหตุ:\nเพื่อให้หลักฐานยืนยันว่าผู้เช่ามีความสามารถในการขับรถยนต์ได้ถูกต้องตามกฎหมาย',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ฟังก์ชันสร้าง widget สำหรับแสดงข้อมูลแต่ละฟิลด์
  Widget _buildInfoField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "$title\n$value",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            Icon(Icons.edit, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
