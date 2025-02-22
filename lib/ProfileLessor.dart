import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ProfileRenter.dart';

class ProfileLessor extends StatefulWidget {
  @override
  _ProfileLessorState createState() => _ProfileLessorState();
}

class _ProfileLessorState extends State<ProfileLessor> {
  // ฟังก์ชันสำหรับแก้ไขข้อมูลผ่าน dialog
  Future<String?> _editDialog(String fieldLabel, String? currentValue) {
    final controller = TextEditingController(text: currentValue ?? "");
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("แก้ไข$fieldLabel"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "กรอก$fieldLabel"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("ยกเลิก")),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: Text("บันทึก")),
        ],
      ),
    );
  }

  // Widget สำหรับกรอบสีขาว
  Widget _buildWhiteBox(Widget child) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return Scaffold(body: Center(child: Text("ไม่พบผู้ใช้ที่ login")));
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00377E),
        title: Text("บัญชี (ผู้ปล่อยเช่า)"),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // เปิดเมนูหรือ drawer ตามต้องการ
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("เกิดข้อผิดพลาด"));
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || !snapshot.data!.exists)
            return Center(child: Text("ไม่พบข้อมูลผู้ใช้งาน"));
          
          // ดึงข้อมูลจาก document
          var data = snapshot.data!.data() as Map<String, dynamic>;
          String? username = data['username'] as String?;
          String? email = data['email'] as String?;
          String? phone = data['phone'] as String?;
          var address = data['address'] as Map<String, dynamic>?;
          String? province = address?['province'] as String?;
          String? district = address?['district'] as String?;
          String? subdistrict = address?['subdistrict'] as String?;
          String? postalCode = address?['postalCode'] as String?;
          String? moreinfo = address?['moreinfo'] as String?;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header: Avatar, Username และ Edit button
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
                      Expanded(
                        child: Text(
                          username ?? "ไม่มีชื่อ",
                          style: TextStyle(fontSize: 24, color: Colors.black),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          String? newVal = await _editDialog("ชื่อผู้ใช้", username);
                          if (newVal != null) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(currentUser.uid)
                                .update({'username': newVal});
                          }
                        },
                      ),
                    ],
                  ),
                ),
                // SwitchListTile สำหรับสลับไปหน้า ProfileRenter
                SwitchListTile(
                  title: Text("ผู้เช่า / ผู้ปล่อยเช่า (ผู้ปล่อยเช่า)"),
                  value: false,
                  onChanged: (val) {
                    if (val) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => ProfileRenter()),
                      );
                    }
                  },
                  secondary: Icon(Icons.swap_horiz),
                ),
                // Container หลักสำหรับข้อมูลส่วนตัว
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
                      Text("ข้อมูลส่วนตัว", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      // หมวด: ที่อยู่
                      _buildWhiteBox(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ที่อยู่:", style: TextStyle(fontSize: 18)),
                            SizedBox(height: 8),
                            // บรรทัดที่ 1: จังหวัด & อำเภอ
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(child: Text("จังหวัด : ${province ?? "ไม่มีข้อมูล"}")),
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () async {
                                          String? newVal = await _editDialog("จังหวัด", province);
                                          if (newVal != null) {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(currentUser.uid)
                                                .update({'address.province': newVal});
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(child: Text("อำเภอ : ${district ?? "ไม่มีข้อมูล"}")),
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () async {
                                          String? newVal = await _editDialog("อำเภอ", district);
                                          if (newVal != null) {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(currentUser.uid)
                                                .update({'address.district': newVal});
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // บรรทัดที่ 2: ตำบล & รหัสไปรษณีย์
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(child: Text("ตำบล : ${subdistrict ?? "ไม่มีข้อมูล"}")),
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () async {
                                          String? newVal = await _editDialog("ตำบล", subdistrict);
                                          if (newVal != null) {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(currentUser.uid)
                                                .update({'address.subdistrict': newVal});
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(child: Text("รหัสไปรษณีย์ : ${postalCode ?? "ไม่มีข้อมูล"}")),
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () async {
                                          String? newVal = await _editDialog("รหัสไปรษณีย์", postalCode);
                                          if (newVal != null) {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(currentUser.uid)
                                                .update({'address.postalCode': newVal});
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // บรรทัดที่ 3: เพิ่มเติม
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(child: Text("เพิ่มเติม : ${moreinfo ?? "ไม่มีข้อมูล"}")),
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () async {
                                          String? newVal = await _editDialog("เพิ่มเติม", moreinfo);
                                          if (newVal != null) {
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(currentUser.uid)
                                                .update({'address.moreinfo': newVal});
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // หมวด: เบอร์โทรศัพท์
                      _buildWhiteBox(
                        Row(
                          children: [
                            Expanded(child: Text("เบอร์โทรศัพท์: ${phone ?? "ไม่มีข้อมูล"}", style: TextStyle(fontSize: 16))),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                String? newVal = await _editDialog("เบอร์โทรศัพท์", phone);
                                if (newVal != null) {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(currentUser.uid)
                                      .update({'phone': newVal});
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      // หมวด: อีเมล
                      _buildWhiteBox(
                        Row(
                          children: [
                            Expanded(child: Text("อีเมล: ${email}", style: TextStyle(fontSize: 16))),
                      
                          ],
                        ),
                      ),
                      // หมวด: รูปใบขับขี่, รูปใบประชาชน, สัญญาปล่อยเช่า
                      _buildWhiteBox(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('รูปใบขับขี่', style: TextStyle(fontSize: 18)),
                            SizedBox(height: 5),
                            ElevatedButton.icon(
                              onPressed: () {
                                // ฟังก์ชันอัปโหลดไฟล์รูปใบขับขี่ (ยังไม่ implement)
                              },
                              icon: Icon(Icons.upload),
                              label: Text('เลือกรูป'),
                            ),
                            SizedBox(height: 20),
                            Text('รูปใบประชาชน', style: TextStyle(fontSize: 18)),
                            SizedBox(height: 5),
                            ElevatedButton.icon(
                              onPressed: () {
                                // ฟังก์ชันอัปโหลดไฟล์รูปใบประชาชน (ยังไม่ implement)
                              },
                              icon: Icon(Icons.upload),
                              label: Text('เลือกรูป'),
                            ),
                            SizedBox(height: 20),
                            Text('สัญญาปล่อยเช่า (จำเป็น)', style: TextStyle(fontSize: 18)),
                            SizedBox(height: 5),
                            ElevatedButton.icon(
                              onPressed: () {
                                // ฟังก์ชันอัปโหลดไฟล์สัญญาปล่อยเช่า (ยังไม่ implement)
                              },
                              icon: Icon(Icons.upload),
                              label: Text('เลือกรูป'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("บันทึกข้อมูลเรียบร้อย")),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                            child: Text("บันทึก", style: TextStyle(fontSize: 16, color: Colors.white)),
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
}
