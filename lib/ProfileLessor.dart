import 'dart:io';
import 'dart:convert'; // สำหรับ base64Encode
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'ProfileRenter.dart';
import 'login_page.dart';
import 'Mycar.dart';

/// Sidebar (Drawer) ที่ใช้ใน ProfileLessor
class MyDrawer extends StatelessWidget {
  final String username;
  final bool isGoogleLogin;
  final String? profileUrl; // << เพิ่มตัวแปรรับรูปโปรไฟล์เข้ามา

  const MyDrawer({
    Key? key,
    required this.username,
    required this.isGoogleLogin,
    this.profileUrl, // << รับค่ามาใน constructor
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
            leading: const Icon(Icons.directions_car),
            title: const Text('รถฉัน'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyCar()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('รายการปล่อยเช่ารถ'),
            onTap: () {
              Navigator.pop(context);
              // เพิ่ม Navigator.push(...) ไปหน้ารายการปล่อยเช่ารถที่นี่
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('การตั้งค่าบัญชี'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileLessor()),
              );
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('ออกจากระบบ', style: TextStyle(color: Colors.red)),
            onTap: () async {
              if (isGoogleLogin) await GoogleSignIn().signOut();
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

class ProfileLessor extends StatefulWidget {
  @override
  _ProfileLessorState createState() => _ProfileLessorState();
}

class _ProfileLessorState extends State<ProfileLessor> {
  // ตัวแปรสำหรับจัดการรูปบัตรประชาชน, สัญญาปล่อยเช่า และรูปโปรไฟล์
  File? _idCardFile;            // เก็บไฟล์รูปบัตรประชาชน
  File? _rentalContractFile;    // เก็บไฟล์รูปสัญญาปล่อยเช่า
  File? _profileFile;           // เก็บไฟล์รูปโปรไฟล์
  final ImagePicker _picker = ImagePicker();

  // ใส่ Client ID ของ Imgur ที่นี่
  final String _imgurClientId = "ed6895b5f1bf3d7";

  // ฟังก์ชันเลือกรูปโปรไฟล์จาก Gallery
  Future<void> _pickProfileImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileFile = File(pickedFile.path);
      });
    }
  }

  // ฟังก์ชันเลือกรูปบัตรประชาชนจาก Gallery
  Future<void> _pickIdCardImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _idCardFile = File(pickedFile.path);
      });
    }
  }

  // ฟังก์ชันเลือกรูปสัญญาปล่อยเช่าจาก Gallery
  Future<void> _pickRentalContractImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _rentalContractFile = File(pickedFile.path);
      });
    }
  }

  // ฟังก์ชันอัปโหลดรูปไปที่ Imgur
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
        // คืนค่า link และ deletehash
        return {
          'link': data['data']['link'],
          'deletehash': data['data']['deletehash'],
        };
      } else {
        throw Exception(
            'อัปโหลดรูปไป Imgur ไม่สำเร็จ: ${data['data']['error']}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ฟังก์ชันลบรูปเก่าจาก Imgur ด้วย deletehash
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

  Future<String?> _editDialog(String label, String? value) async {
    final ctrl = TextEditingController(text: value ?? "");
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("แก้ไข$label"),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("ยกเลิก")),
          TextButton(
              onPressed: () => Navigator.pop(context, ctrl.text),
              child: const Text("บันทึก")),
        ],
      ),
    );
  }

  Widget _whiteBox(Widget child) => Container(
        width: MediaQuery.of(context).size.width * 0.9,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: child,
      );

  Widget _incomeBox(num myPayment) {
    final String incomeText = myPayment.toStringAsFixed(2);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("รายได้วันนี้",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text("฿ $incomeText",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700])),
        ],
      ),
    );
  }

  // Segmented control สำหรับสลับหน้า
  // ในหน้า ProfileLessor ให้ "ผู้เช่า" อยู่ฝั่งซ้าย (non-selected)
  // และ "ผู้ปล่อยเช่า" อยู่ฝั่งขวา (selected)
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
            // ปุ่มผู้เช่า (non-selected)
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileRenter()),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "ผู้เช่า",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // ปุ่มผู้ปล่อยเช่า (selected)
            GestureDetector(
              onTap: () {
                // อยู่ในหน้าเดียวกัน ไม่ต้อง navigate
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "ผู้ปล่อยเช่า",
                  style: TextStyle(
                    color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
          body: Center(child: Text("ไม่พบผู้ใช้ที่ login")));
    }
    bool isGoogleLogin =
        user.providerData.any((p) => p.providerId == 'google.com');

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (_, snap) {
        if (snap.hasError) {
          return const Scaffold(
              body: Center(child: Text("เกิดข้อผิดพลาด")));
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (!snap.hasData || !snap.data!.exists) {
          return const Scaffold(
              body: Center(child: Text("ไม่พบข้อมูลผู้ใช้งาน")));
        }

        var data = snap.data!.data() as Map<String, dynamic>;
        String? username = data['username'];
        String? email = data['email'];
        String? phone = data['phone'];
        var addr = data['address'] as Map<String, dynamic>?;
        String? province = addr?['province'];
        String? district = addr?['district'];
        String? subdistrict = addr?['subdistrict'];
        String? postal = addr?['postalCode'];
        String? more = addr?['moreinfo'];

        // ดึงข้อมูลภาพใน object image (ถ้าไม่มีให้เป็น {})
        final imageData = data['image'] ?? {};
        final oldIdCardUrl = imageData['id_card'];
        final oldIdCardDeleteHash = imageData['deletehash_id_card'];
        final oldRentalUrl = imageData['rental_contract'];
        final oldRentalDeleteHash = imageData['deletehash_rental_contract'];
        // สำหรับโปรไฟล์
        final oldProfileUrl = imageData['profile'];
        final oldProfileDeleteHash = imageData['deletehashprofil'];

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF00377E),
            title: const Text("บัญชี (ผู้ปล่อยเช่า)"),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          drawer: MyDrawer(
            username: username ?? "ไม่มีชื่อ",
            isGoogleLogin: isGoogleLogin,
            profileUrl: oldProfileUrl, // << ส่งรูปโปรไฟล์ไปที่ Drawer
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header พร้อมโปรไฟล์ (ใช้ Stack ซ้อน CircleAvatar กับปุ่มแก้ไข)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _profileFile != null
                                ? FileImage(_profileFile!)
                                : (oldProfileUrl != null &&
                                        oldProfileUrl != 'null'
                                    ? NetworkImage(oldProfileUrl)
                                    : null) as ImageProvider<Object>?,
                            child: (_profileFile == null &&
                                    (oldProfileUrl == null ||
                                        oldProfileUrl == 'null'))
                                ? const Icon(Icons.person,
                                    size: 40, color: Colors.grey)
                                : null,
                          ),
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
                                  border: Border.all(
                                      color: Colors.white, width: 1),
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
                        child: Text(username ?? "ไม่มีชื่อ",
                            style: const TextStyle(fontSize: 24)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          String? newVal =
                              await _editDialog("ชื่อผู้ใช้", username);
                          if (newVal != null) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .update({'username': newVal});
                          }
                        },
                      ),
                    ],
                  ),
                ),
                // Segmented control สำหรับสลับไปหน้า ProfileRenter
                _buildProfileSwitch(),
                // รายได้วันนี้
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('payments')
                      .doc(user.uid)
                      .snapshots(),
                  builder: (_, paySnap) {
                    if (paySnap.hasError) {
                      return const Center(
                          child: Text("เกิดข้อผิดพลาดในการโหลดรายได้"));
                    }
                    if (paySnap.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    if (!paySnap.hasData || !paySnap.data!.exists) {
                      return _incomeBox(0);
                    }
                    var payData =
                        paySnap.data!.data() as Map<String, dynamic>;
                    num income = payData['mypayment'] ?? 0;
                    return _incomeBox(income);
                  },
                ),
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
                      const Text("ข้อมูลส่วนตัว",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _whiteBox(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("ที่อยู่:",
                              style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(child: Text("จังหวัด : ${province ?? "ไม่มีข้อมูล"}")),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () async {
                                        String? newVal =
                                            await _editDialog("จังหวัด", province);
                                        if (newVal != null) {
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user.uid)
                                              .update(
                                                  {'address.province': newVal});
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
                                    Flexible(child: Text("อำเภอ : ${district ?? "ไม่มีข้อมูล"}")),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () async {
                                        String? newVal =
                                            await _editDialog("อำเภอ", district);
                                        if (newVal != null) {
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user.uid)
                                              .update(
                                                  {'address.district': newVal});
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
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () async {
                                        String? newVal =
                                            await _editDialog("ตำบล", subdistrict);
                                        if (newVal != null) {
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user.uid)
                                              .update(
                                                  {'address.subdistrict': newVal});
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
                                    Flexible(child: Text("รหัสไปรษณีย์ : ${postal ?? "ไม่มีข้อมูล"}")),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () async {
                                        String? newVal =
                                            await _editDialog("รหัสไปรษณีย์", postal);
                                        if (newVal != null) {
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user.uid)
                                              .update(
                                                  {'address.postalCode': newVal});
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
                                    Flexible(child: Text("เพิ่มเติม : ${more ?? "ไม่มีข้อมูล"}")),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () async {
                                        String? newVal =
                                            await _editDialog("เพิ่มเติม", more);
                                        if (newVal != null) {
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user.uid)
                                              .update(
                                                  {'address.moreinfo': newVal});
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                      _whiteBox(Row(
                        children: [
                          Expanded(
                              child: Text("เบอร์โทรศัพท์: ${phone ?? "ไม่มีข้อมูล"}",
                                  style: const TextStyle(fontSize: 16))),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              String? newVal =
                                  await _editDialog("เบอร์โทรศัพท์", phone);
                              if (newVal != null) {
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .update({'phone': newVal});
                              }
                            },
                          ),
                        ],
                      )),
                      _whiteBox(Row(
                        children: [
                          Expanded(
                              child: Text("อีเมล: $email",
                                  style: const TextStyle(fontSize: 16))),
                        ],
                      )),
                      // ส่วนรูปบัตรประชาชน, รูปสัญญาปล่อยเช่า และปุ่มเพิ่มตำแหน่งที่ตั้ง
                      _whiteBox(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('รูปบัตรประชาชน',
                              style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 5),
                          ElevatedButton.icon(
                            onPressed: _pickIdCardImage,
                            icon: const Icon(Icons.upload),
                            label: const Text('เลือกรูป'),
                          ),
                          if (_idCardFile != null) ...[
                            const SizedBox(height: 10),
                            Image.file(
                              _idCardFile!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ],
                          const SizedBox(height: 20),
                          const Text('สัญญาปล่อยเช่า (จำเป็น)',
                              style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 5),
                          ElevatedButton.icon(
                            onPressed: _pickRentalContractImage,
                            icon: const Icon(Icons.upload),
                            label: const Text('เลือกรูป'),
                          ),
                          if (_rentalContractFile != null) ...[
                            const SizedBox(height: 10),
                            Image.file(
                              _rentalContractFile!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ],
                          const SizedBox(height: 20),
                          // ปุ่มเพิ่มตำแหน่งที่ตั้ง
                          ElevatedButton.icon(
                            onPressed: () {
                              // Event ยังไม่ navigate ไปที่หน้าแผนที่
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "เลือกตำแหน่งที่ตั้ง (ยังไม่ได้ implement)")),
                              );
                            },
                            icon: const Icon(Icons.location_on),
                            label: const Text("เพิ่มตำแหน่งที่ตั้ง"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      )),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              // 1) อัปเดตรูปโปรไฟล์ (เพิ่มหรือต้องการอัปเดต)
                              if (_profileFile != null) {
                                if (oldProfileUrl != null &&
                                    oldProfileUrl != 'null' &&
                                    oldProfileDeleteHash != null &&
                                    oldProfileDeleteHash != 'null') {
                                  await _deleteImageFromImgur(oldProfileDeleteHash);
                                }
                                final uploadResult =
                                    await _uploadImageToImgur(_profileFile!);
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .update({
                                  'image.profile': uploadResult['link'],
                                  'image.deletehashprofil': uploadResult['deletehash'],
                                });
                              }
                              // 2) รูปบัตรประชาชน
                              if (_idCardFile != null) {
                                if (oldIdCardUrl != null &&
                                    oldIdCardUrl != 'null' &&
                                    oldIdCardDeleteHash != null &&
                                    oldIdCardDeleteHash != 'null') {
                                  await _deleteImageFromImgur(oldIdCardDeleteHash);
                                }
                                final uploadResult =
                                    await _uploadImageToImgur(_idCardFile!);
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .update({
                                  'image.id_card': uploadResult['link'],
                                  'image.deletehash_id_card': uploadResult['deletehash'],
                                });
                              }
                              // 3) รูปสัญญาปล่อยเช่า
                              if (_rentalContractFile != null) {
                                if (oldRentalUrl != null &&
                                    oldRentalUrl != 'null' &&
                                    oldRentalDeleteHash != null &&
                                    oldRentalDeleteHash != 'null') {
                                  await _deleteImageFromImgur(oldRentalDeleteHash);
                                }
                                final uploadResult =
                                    await _uploadImageToImgur(_rentalContractFile!);
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .update({
                                  'image.rental_contract': uploadResult['link'],
                                  'image.deletehash_rental_contract': uploadResult['deletehash'],
                                });
                              }
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
