import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ProfileRenter.dart'; // นำเข้า ProfileRenter

class ProfileLessor extends StatefulWidget {
  @override
  _ProfileLessorState createState() => _ProfileLessorState();
}

class _ProfileLessorState extends State<ProfileLessor> {
  bool _initializedAddress = false;

  // ตัวแปร state สำหรับข้อมูลที่อยู่
  String province = "";
  String district = "";
  String subdistrict = "";
  String postCode = "";
  String moreInfo = "";

  // ตัวแปร state สำหรับข้อมูลอื่น ๆ
  String phone = "";
  String email = "";
  String username = "Name";

  // เก็บ docId ของ Firestore เพื่อใช้ตอน update
  String docId = "";

  // ------------------ ฟังก์ชันแก้ไขข้อมูลที่อยู่ ------------------
  void _editAddressField(String fieldLabel, String currentValue) async {
    final TextEditingController controller =
        TextEditingController(text: currentValue);

    final newValue = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("แก้ไข$fieldLabel"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "กรอก$fieldLabel"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("ยกเลิก"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text("บันทึก"),
            ),
          ],
        );
      },
    );

    if (newValue != null) {
      setState(() {
        switch (fieldLabel) {
          case "จังหวัด":
            province = newValue;
            break;
          case "อำเภอ":
            district = newValue;
            break;
          case "ตำบล":
            subdistrict = newValue;
            break;
          case "รหัสไปรษณีย์":
            postCode = newValue;
            break;
          case "เพิ่มเติม":
            moreInfo = newValue;
            break;
        }
      });
    }
  }

  // ------------------ ฟังก์ชันแก้ไขข้อมูลทั่วไป (เบอร์โทร, อีเมล, ชื่อผู้ใช้) ------------------
  void _editField(String fieldLabel, String currentValue) async {
    final TextEditingController controller =
        TextEditingController(text: currentValue);

    final newValue = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("แก้ไข$fieldLabel"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "กรอก$fieldLabel"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("ยกเลิก"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text("บันทึก"),
            ),
          ],
        );
      },
    );

    if (newValue != null) {
      setState(() {
        if (fieldLabel == "เบอร์โทรศัพท์") {
          phone = newValue;
        } else if (fieldLabel == "อีเมล") {
          email = newValue;
        } else if (fieldLabel == "ชื่อผู้ใช้") {
          username = newValue;
        }
      });
    }
  }

  // ------------------ Widget สำหรับกรอบสีขาวแต่ละหมวด ------------------
  Widget _buildWhiteBox(Widget child) {
    return Container(
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

          var docSnapshot = snapshot.data!.docs.first;
          docId = docSnapshot.id; // เก็บ docId สำหรับอัปเดตข้อมูล
          var lessorData = docSnapshot.data() as Map<String, dynamic>;

          // กำหนดค่าเริ่มต้นเฉพาะครั้งแรก
          if (!_initializedAddress) {
            province = lessorData['province'] ?? "";
            district = lessorData['district'] ?? "";
            subdistrict = lessorData['subdistrict'] ?? "";
            postCode = lessorData['postCode'] ?? "";
            moreInfo = lessorData['moreInfo'] ?? "";
            phone = lessorData['phone'] ?? '';
            email = lessorData['email'] ?? '';
            username = lessorData['username'] ?? 'Name';
            _initializedAddress = true;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // ส่วนหัว (Avatar + ชื่อ)
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
                      // ชื่อผู้ใช้ + ปุ่มแก้ไข
                      Expanded(
                        child: Text(
                          username,
                          style: TextStyle(fontSize: 24, color: Colors.black),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editField("ชื่อผู้ใช้", username),
                      ),
                    ],
                  ),
                ),

                // Switch สลับไป ProfileRenter
                SwitchListTile(
                  title: Text('ผู้เช่า / ผู้ปล่อยเช่า (ผู้ปล่อยเช่า)'),
                  value: false,
                  onChanged: (value) {
                    if (value) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => ProfileRenter()),
                      );
                    }
                  },
                  secondary: Icon(Icons.swap_horiz),
                ),

                // กรอบสีฟ้าใหญ่ ครอบข้อมูลส่วนตัวทั้งหมด
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
                      // หัวข้อหลัก
                      Text(
                        "ข้อมูลส่วนตัว",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      // หมวด: ที่อยู่
                      _buildWhiteBox(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "ที่อยู่:",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.edit, color: Colors.blue),
                              ],
                            ),
                            SizedBox(height: 8),
                            // บรรทัดที่ 1
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(child: Text("จังหวัด : $province")),
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _editAddressField("จังหวัด", province),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(child: Text("อำเภอ : $district")),
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _editAddressField("อำเภอ", district),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // บรรทัดที่ 2
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(child: Text("ตำบล : $subdistrict")),
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _editAddressField("ตำบล", subdistrict),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(child: Text("รหัสไปรษณีย์ : $postCode")),
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _editAddressField("รหัสไปรษณีย์", postCode),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // บรรทัดที่ 3
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(child: Text("เพิ่มเติม : $moreInfo")),
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _editAddressField("เพิ่มเติม", moreInfo),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text("เบอร์โทรศัพท์: $phone", style: TextStyle(fontSize: 16)),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editField("เบอร์โทรศัพท์", phone),
                            ),
                          ],
                        ),
                      ),

                      // หมวด: อีเมล
                      _buildWhiteBox(
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text("อีเมล: $email", style: TextStyle(fontSize: 16)),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editField("อีเมล", email),
                            ),
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
                                // ฟังก์ชันอัปโหลดไฟล์รูปใบขับขี่
                              },
                              icon: Icon(Icons.upload),
                              label: Text('เลือกรูป'),
                            ),
                            SizedBox(height: 20),
                            Text('รูปใบประชาชน', style: TextStyle(fontSize: 18)),
                            SizedBox(height: 5),
                            ElevatedButton.icon(
                              onPressed: () {
                                // ฟังก์ชันอัปโหลดไฟล์รูปใบประชาชน
                              },
                              icon: Icon(Icons.upload),
                              label: Text('เลือกรูป'),
                            ),
                            SizedBox(height: 20),
                            Text('สัญญาปล่อยเช่า (จำเป็น)', style: TextStyle(fontSize: 18)),
                            SizedBox(height: 5),
                            ElevatedButton.icon(
                              onPressed: () {
                                // ฟังก์ชันอัปโหลดไฟล์สัญญาปล่อยเช่า
                              },
                              icon: Icon(Icons.upload),
                              label: Text('เลือกรูป'),
                            ),
                          ],
                        ),
                      ),

                      // ปุ่มบันทึกข้อมูล
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (docId.isNotEmpty) {
                              await FirebaseFirestore.instance
                                  .collection('renter')
                                  .doc(docId)
                                  .update({
                                'province': province,
                                'district': district,
                                'subdistrict': subdistrict,
                                'postCode': postCode,
                                'moreInfo': moreInfo,
                                'phone': phone,
                                'email': email,
                                'username': username,
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย')),
                              );
                            }
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
                              style: TextStyle(fontSize: 16, color: Colors.white),
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
}
