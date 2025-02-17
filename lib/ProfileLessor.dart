import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ProfileRenter.dart'; // นำเข้า ProfileRenter

class ProfileLessor extends StatefulWidget {
  @override
  _ProfileLessorState createState() => _ProfileLessorState();
}

class _ProfileLessorState extends State<ProfileLessor> {
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
        title: Text('บัญชี (ผู้ปล่อยเช่า)'),
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

          var lessorData =
              snapshot.data!.docs.first.data() as Map<String, dynamic>;

          // รวมข้อมูลที่อยู่
          String address =
              "${lessorData['province'] ?? ''} ${lessorData['district'] ?? ''}\n"
              "${lessorData['subdistrict'] ?? ''} ${lessorData['postCode'] ?? ''}\n"
              "${lessorData['moreInfo'] ?? ''}";

          String phone = lessorData['phone'] ?? '';
          String email = lessorData['email'] ?? '';
          String username = lessorData['username'] ?? 'Name';

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

                // Switch สำหรับสลับไปหน้าผู้เช่า
                SwitchListTile(
                  title: Text('ผู้เช่า / ผู้ปล่อยเช่า (ผู้ปล่อยเช่า)'),
                  value: false,
                  onChanged: (value) {
                    if (value) {
                      // เมื่อสวิตช์ถูกเปลี่ยนเป็น true ให้ navigate ไปที่ ProfileRenter
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProfileRenter()));
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
                      // ฟิลด์สำหรับรูปใบขับขี่
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
                      SizedBox(height: 20),
                      // ฟิลด์สำหรับรูปใบประชาชน
                      Row(
                        children: [
                          Text(
                            'รูปใบประชาชน',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ),
                      SizedBox(height: 5),
                      ElevatedButton.icon(
                        onPressed: () {
                          // ฟังก์ชันอัปโหลดไฟล์รูปใบประชาชน
                        },
                        icon: Icon(Icons.upload),
                        label: Text('เลือกรูป'),
                      ),
                      SizedBox(height: 20),
                      // ฟิลด์สำหรับสัญญาปล่อยเช่า
                      Text(
                        'สัญญาปล่อยเช่า (จำเป็น)',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      SizedBox(height: 5),
                      ElevatedButton.icon(
                        onPressed: () {
                          // ฟังก์ชันอัปโหลดไฟล์สัญญาปล่อยเช่า
                        },
                        icon: Icon(Icons.upload),
                        label: Text('เลือกรูป'),
                      ),
                      // ปุ่มบันทึกข้อมูล
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () {
                            // คำสั่งบันทึกข้อมูล (อัปเดต Firestore หรืออื่น ๆ)
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                            child: Text(
                              "บันทึก",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
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
