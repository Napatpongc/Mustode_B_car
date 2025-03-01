import 'dart:io';
import 'dart:convert'; // สำหรับ base64Encode
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart'; // ใช้กรณี Google Sign Out
import 'login_page.dart'; // เพื่อไปหน้า login
import 'ProfileLessor.dart'; // เพื่อสลับไปหน้าผู้ปล่อยเช่า (Segmented control)

class ProfileRenter extends StatefulWidget {
  @override
  _ProfileRenterState createState() => _ProfileRenterState();
}

class _ProfileRenterState extends State<ProfileRenter> {
  // ------------------ ตัวแปรเก็บข้อมูลโปรไฟล์ ------------------
  String? username;
  String? email;
  String? phone;
  String? province;
  String? district;
  String? subdistrict;
  String? postalCode;
  String? moreinfo;

  // ------------------ ตัวแปรรูปภาพ (โปรไฟล์ + ใบขับขี่) ------------------
  File? _drivingLicenseFile; // เก็บไฟล์รูปใบขับขี่
  File? _profileFile;        // เก็บไฟล์รูปโปรไฟล์
  final ImagePicker _picker = ImagePicker();

  // ใส่ Client ID ของ Imgur ที่นี่ (ตัวอย่าง)
  final String _imgurClientId = "ed6895b5f1bf3d7";

  // ------------------ ฟังก์ชันแก้ไขข้อความ (Dialog) ------------------
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text("บันทึก"),
          ),
        ],
      ),
    );
  }

  // ------------------ Widget กล่องสีขาว ------------------
  Widget _buildWhiteBox(Widget child) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  // ------------------ กำหนดค่าเริ่มต้นจาก Firestore ------------------
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

  // ------------------ ฟังก์ชันเลือกรูปใบขับขี่จาก Gallery ------------------
  Future<void> _pickDrivingLicenseImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _drivingLicenseFile = File(pickedFile.path);
      });
    }
  }

  // ------------------ ฟังก์ชันเลือกรูปโปรไฟล์จาก Gallery ------------------
  Future<void> _pickProfileImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileFile = File(pickedFile.path);
      });
    }
  }

  // ------------------ ฟังก์ชันอัปโหลดรูปไปยัง Imgur ------------------
  Future<Map<String, dynamic>> _uploadImageToImgur(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://api.imgur.com/3/image'),
        headers: {
          'Authorization': 'Client-ID $_imgurClientId',
        },
        body: {
          'image': base64Image,
          'type': 'base64',
        },
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] == true) {
        return {
          'link': data['data']['link'],
          'deletehash': data['data']['deletehash'],
        };
      } else {
        throw Exception('อัปโหลดรูปไป Imgur ไม่สำเร็จ: ${data['data']['error']}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ------------------ ฟังก์ชันลบรูปใน Imgur โดยใช้ deletehash ------------------
  Future<void> _deleteImageFromImgur(String deleteHash) async {
    try {
      await http.delete(
        Uri.parse('https://api.imgur.com/3/image/$deleteHash'),
        headers: {
          'Authorization': 'Client-ID $_imgurClientId',
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // ------------------ Segmented control สำหรับสลับหน้า ------------------
  // ในหน้า ProfileRenter ให้ "ผู้เช่า" อยู่ฝั่งซ้าย (selected)
  // และ "ผู้ปล่อยเช่า" อยู่ฝั่งขวา (non-selected)
  Widget _buildProfileSwitch() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 1.5),
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ปุ่มผู้เช่า (selected)
            GestureDetector(
              onTap: () {
                // อยู่ในหน้าเดียวกัน ไม่ต้อง navigate
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "ผู้เช่า",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // ปุ่มผู้ปล่อยเช่า (non-selected)
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileLessor()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "ผู้ปล่อยเช่า",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------ ส่วน build หลัก ------------------
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("ไม่พบผู้ใช้ที่ login")),
      );
    }

    // ตรวจสอบว่า Login ด้วย Google หรือไม่
    bool isGoogleLogin = currentUser.providerData.any((p) => p.providerId == 'google.com');

    // ใช้ StreamBuilder ดึงข้อมูลผู้ใช้จาก Firestore
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("เกิดข้อผิดพลาด")),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("ไม่พบข้อมูลผู้ใช้งาน")),
          );
        }

        // ได้ data จาก Firestore
        var data = snapshot.data!.data() as Map<String, dynamic>;
        // กำหนดค่าเริ่มต้นให้ตัวแปรใน State (username, phone ฯลฯ)
        _initializeLocalData(data);

        // ข้อมูลรูปจาก Firestore
        final imageData = data['image'] ?? {};
        final oldProfileUrl = imageData['profile'];
        final oldProfileDeleteHash = imageData['deletehashprofil'];
        final oldDrivingUrl = imageData['driving_license'];
        final oldDrivingDeleteHash = imageData['deletehash_driving_license'];

        // ---- สร้าง Scaffold ตัวเดียว ----
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF00377E),
            title: const Text("บัญชี (ผู้เช่า)"),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          // ประกาศ Drawer ของเรา (MyDrawerRenter)
          drawer: MyDrawerRenter(
            username: username ?? "ไม่มีชื่อ",
            isGoogleLogin: isGoogleLogin,
            profileUrl: oldProfileUrl,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header: รูปโปรไฟล์, ชื่อ, ปุ่มแก้ไขโปรไฟล์
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _profileFile != null
                                ? FileImage(_profileFile!)
                                : (oldProfileUrl != null && oldProfileUrl != 'null'
                                    ? NetworkImage(oldProfileUrl)
                                    : null) as ImageProvider<Object>?,
                            child: (_profileFile == null &&
                                    (oldProfileUrl == null || oldProfileUrl == 'null'))
                                ? const Icon(Icons.person, size: 40, color: Colors.blue)
                                : null,
                          ),
                          // ปุ่มแก้ไขเล็กๆ ที่มุมล่างขวาของรูปโปรไฟล์
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _pickProfileImage,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          username ?? "ไม่มีชื่อ",
                          style: const TextStyle(fontSize: 24, color: Colors.black),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
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

                // Segmented control สำหรับสลับไปหน้า ProfileLessor
                _buildProfileSwitch(),

                // ข้อมูลส่วนตัว
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0x9ED6EFFF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ข้อมูลส่วนตัว",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      _buildWhiteBox(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("ที่อยู่:", style: TextStyle(fontSize: 18)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text("จังหวัด : ${province ?? "ไม่มีข้อมูล"}"),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () async {
                                          String? newVal =
                                              await _editDialog("จังหวัด", province);
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
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text("อำเภอ : ${district ?? "ไม่มีข้อมูล"}"),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () async {
                                          String? newVal =
                                              await _editDialog("อำเภอ", district);
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
                                      Flexible(
                                        child: Text("ตำบล : ${subdistrict ?? "ไม่มีข้อมูล"}"),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () async {
                                          String? newVal =
                                              await _editDialog("ตำบล", subdistrict);
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
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child:
                                            Text("รหัสไปรษณีย์ : ${postalCode ?? "ไม่มีข้อมูล"}"),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () async {
                                          String? newVal = await _editDialog(
                                              "รหัสไปรษณีย์", postalCode);
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
                                      Flexible(
                                        child: Text("เพิ่มเติม : ${moreinfo ?? "ไม่มีข้อมูล"}"),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () async {
                                          String? newVal =
                                              await _editDialog("เพิ่มเติม", moreinfo);
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
                            Expanded(
                              child: Text(
                                "เบอร์โทรศัพท์: ${phone ?? "ไม่มีข้อมูล"}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                String? newVal =
                                    await _editDialog("เบอร์โทรศัพท์", phone);
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
                            Expanded(
                              child: Text(
                                "อีเมล: $email",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ส่วนรูปใบขับขี่
                      _buildWhiteBox(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('รูปใบขับขี่', style: TextStyle(fontSize: 18)),
                            const SizedBox(height: 5),
                            ElevatedButton.icon(
                              onPressed: _pickDrivingLicenseImage,
                              icon: const Icon(Icons.upload),
                              label: const Text('เลือกรูป'),
                            ),
                            if (_drivingLicenseFile != null) ...[
                              const SizedBox(height: 10),
                              Image.file(
                                _drivingLicenseFile!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              // ------------------ อัปเดตข้อมูลส่วนบุคคล ------------------
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(currentUser.uid)
                                  .update({
                                'username': username,
                                'email': email,
                                'phone': phone,
                                'address': {
                                  'province': province,
                                  'district': district,
                                  'subdistrict': subdistrict,
                                  'postalCode': postalCode,
                                  'moreinfo': moreinfo,
                                },
                              });

                              // ------------------ อัปเดตรูปโปรไฟล์ (ถ้ามี) ------------------
                              if (_profileFile != null) {
                                // ถ้ามีรูปเก่าใน Firestore และ deleteHash เก่า
                                if (oldProfileUrl != null &&
                                    oldProfileUrl != 'null' &&
                                    oldProfileDeleteHash != null &&
                                    oldProfileDeleteHash != 'null') {
                                  await _deleteImageFromImgur(oldProfileDeleteHash);
                                }
                                final uploadResult = await _uploadImageToImgur(_profileFile!);
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(currentUser.uid)
                                    .update({
                                  'image.profile': uploadResult['link'],
                                  'image.deletehashprofil': uploadResult['deletehash'],
                                });
                              }

                              // ------------------ อัปเดตรูปใบขับขี่ (ถ้ามี) ------------------
                              if (_drivingLicenseFile != null) {
                                if (oldDrivingUrl != null &&
                                    oldDrivingUrl != 'null' &&
                                    oldDrivingDeleteHash != null &&
                                    oldDrivingDeleteHash != 'null') {
                                  await _deleteImageFromImgur(oldDrivingDeleteHash);
                                }
                                final uploadResult =
                                    await _uploadImageToImgur(_drivingLicenseFile!);
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(currentUser.uid)
                                    .update({
                                  'image.driving_license': uploadResult['link'],
                                  'image.deletehash_driving_license':
                                      uploadResult['deletehash'],
                                });
                              }

                              // แจ้งเตือนว่าอัปเดตเสร็จ
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("บันทึกข้อมูลเรียบร้อย")),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Padding(
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
          ),
        );
      },
    );
  }
}

// ------------------- Drawer ใหม่สำหรับ ProfileRenter ------------------- //
class MyDrawerRenter extends StatelessWidget {
  final String username;
  final bool isGoogleLogin;
  final String? profileUrl;

  const MyDrawerRenter({
    Key? key,
    required this.username,
    required this.isGoogleLogin,
    this.profileUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF00377E)),
            accountName: Text(username, style: const TextStyle(fontSize: 16)),
            accountEmail: null,
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: (profileUrl != null && profileUrl != 'null')
                  ? NetworkImage(profileUrl!)
                  : null,
              child: (profileUrl == null || profileUrl == 'null')
                  ? const Icon(Icons.person, size: 40, color: Colors.grey)
                  : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('หน้าหลัก'),
            onTap: () {
              Navigator.pop(context);
              // TODO: ใส่โค้ดนำทางไปหน้าหลัก (Home) ตามต้องการ
            },
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('แผนที่'),
            onTap: () {
              Navigator.pop(context);
              // TODO: ใส่โค้ดนำทางไปหน้าแผนที่
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('รายการเช่าทั้งหมด'),
            onTap: () {
              Navigator.pop(context);
              // TODO: ใส่โค้ดนำทางไปหน้ารายการเช่าทั้งหมด
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('การตั้งค่าบัญชี'),
            onTap: () {
              Navigator.pop(context);
              // TODO: ใส่โค้ดนำทางไปหน้าการตั้งค่าบัญชี
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('ออกจากระบบ', style: TextStyle(color: Colors.red)),
            onTap: () async {
              if (isGoogleLogin) {
                await GoogleSignIn().signOut();
              }
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
