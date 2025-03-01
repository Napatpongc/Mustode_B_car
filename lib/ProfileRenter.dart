import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ProfileLessor.dart'; // เพื่อใช้ MyDrawer ที่เราได้สร้างไว้ใน ProfileLessor.dart


class ProfileRenter extends StatefulWidget {
  @override
  _ProfileRenterState createState() => _ProfileRenterState();
}

class _ProfileRenterState extends State<ProfileRenter> {
  // Local state variables
  String? username;
  String? email;
  String? phone;
  String? province;
  String? district;
  String? subdistrict;
  String? postalCode;
  String? moreinfo;

  // Dialog for editing field (updates local state only)
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

  // Widget for white box style
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

  // Update local state with data from Firestore snapshot (only once)
  void _initializeLocalData(Map<String, dynamic> data) {
    if (username == null) {
      username = data['username'] as String?;
      email = data['email'] as String?;
      phone = data['phone'] as String?;
      var address = data['address'] as Map<String, dynamic>?;
      province = address?['province'] as String?;
      district = address?['district'] as String?;
      subdistrict = address?['subdistrict'] as String?;
      postalCode = address?['postalCode'] as String?;
      moreinfo = address?['moreinfo'] as String?;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(body: Center(child: Text("ไม่พบผู้ใช้ที่ login")));
    }
    // ตรวจสอบว่า Login ด้วย Google หรือไม่
    bool isGoogleLogin = currentUser.providerData.any((p) => p.providerId == 'google.com');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00377E),
        title: Text("บัญชี (ผู้เช่า)"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      // เพิ่ม Drawer โดยใช้ MyDrawer จาก ProfileLessor
      drawer: MyDrawer(username: username ?? "ไม่มีชื่อ", isGoogleLogin: isGoogleLogin),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text("เกิดข้อผิดพลาด"));
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || !snapshot.data!.exists)
            return Center(child: Text("ไม่พบข้อมูลผู้ใช้งาน"));

          var data = snapshot.data!.data() as Map<String, dynamic>;
          _initializeLocalData(data);

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header: Avatar, Username, Edit button
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
                        child: Text(username ?? "ไม่มีชื่อ", style: TextStyle(fontSize: 24, color: Colors.black)),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          String? newVal = await _editDialog("ชื่อผู้ใช้", username);
                          if (newVal != null && newVal.isNotEmpty) {
                            setState(() {
                              username = newVal;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                // Switch for switching to ProfileLessor
                SwitchListTile(
                  title: Text("ผู้เช่า / ผู้ปล่อยเช่า (ผู้เช่า)"),
                  value: true,
                  onChanged: (val) {
                    if (!val) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileLessor()));
                    }
                  },
                  secondary: Icon(Icons.swap_horiz),
                ),
                // Main container for personal info
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
                      _buildWhiteBox(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ที่อยู่:", style: TextStyle(fontSize: 18)),
                            SizedBox(height: 8),
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
                                          if (newVal != null && newVal.isNotEmpty) {
                                            setState(() {
                                              province = newVal;
                                            });
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
                                          if (newVal != null && newVal.isNotEmpty) {
                                            setState(() {
                                              district = newVal;
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                                          if (newVal != null && newVal.isNotEmpty) {
                                            setState(() {
                                              subdistrict = newVal;
                                            });
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
                                          if (newVal != null && newVal.isNotEmpty) {
                                            setState(() {
                                              postalCode = newVal;
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                                          if (newVal != null && newVal.isNotEmpty) {
                                            setState(() {
                                              moreinfo = newVal;
                                            });
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
                      _buildWhiteBox(
                        Row(
                          children: [
                            Expanded(child: Text("เบอร์โทรศัพท์: ${phone ?? "ไม่มีข้อมูล"}", style: TextStyle(fontSize: 16))),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                String? newVal = await _editDialog("เบอร์โทรศัพท์", phone);
                                if (newVal != null && newVal.isNotEmpty) {
                                  setState(() {
                                    phone = newVal;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      _buildWhiteBox(
                        Row(
                          children: [
                            Expanded(child: Text("อีเมล: ${email}", style: TextStyle(fontSize: 16))),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildWhiteBox(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('รูปใบขับขี่', style: TextStyle(fontSize: 18)),
                            SizedBox(height: 5),
                            ElevatedButton.icon(
                              onPressed: () {
                                // implement upload action
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
                            await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).update({
                              'username': username,
                              'email': email,
                              'phone': phone,
                              'address': {
                                'province': province,
                                'district': district,
                                'subdistrict': subdistrict,
                                'postalCode': postalCode,
                                'moreinfo': moreinfo,
                              }
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("บันทึกข้อมูลเรียบร้อย")));
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
