import 'dart:io';
import 'dart:convert'; // สำหรับ base64Encode
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:geolocator/geolocator.dart';

import 'ProfileRenter.dart';
import 'login_page.dart';
import 'Mycar.dart';
import 'address_picker.dart';
import 'listLessor.dart';

class MyDrawer extends StatelessWidget {
  final String username;
  final bool isGoogleLogin;
  final String? profileUrl;

  const MyDrawer({
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
            leading: const Icon(Icons.directions_car),
            title: const Text('รถฉัน'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyCar()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('รายการปล่อยเช่ารถ'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ListPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('การตั้งค่าบัญชี'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileLessor()));
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
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
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
  // ----------------- ตัวแปรรูปภาพ ------------------
  File? _idCardFile;
  File? _rentalContractFile;
  File? _profileFile;
  final ImagePicker _picker = ImagePicker();

  // Imgur Client ID
  final String _imgurClientId = "ed6895b5f1bf3d7";

  // ----------------- ตัวแปร Address ------------------
  String? _province;
  String? _district;
  String? _subdistrict;
  String? _postalCode;

  // ----------------- ตัวแปรสำหรับรายละเอียดเพิ่มเติม ------------------
  String? _moreInfo;

  // ----------------- ตัวแปรทั่วไป ------------------
  String? _username;
  String? _email;
  String? _phone;

  /// กำหนดค่าเริ่มต้นให้ตัวแปรจากข้อมูลใน Firestore
  void _initializeLocalData(Map<String, dynamic> data) {
    _username ??= data['username'];
    _email ??= data['email'];
    _phone ??= data['phone'];

    final addr = data['address'] as Map<String, dynamic>?;
    if (addr != null) {
      _province ??= addr['province'];
      _district ??= addr['district'];
      _subdistrict ??= addr['subdistrict'];
      _postalCode ??= addr['postalCode'];
    }

    // moreinfo ไม่ได้อยู่ใน address => ดึงจาก data['moreinfo']
    _moreInfo ??= data['moreinfo']; 
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("ไม่พบผู้ใช้ที่ login")),
      );
    }
    bool isGoogleLogin = user.providerData.any((p) => p.providerId == 'google.com');

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (_, snap) {
        if (snap.hasError) {
          return const Scaffold(body: Center(child: Text("เกิดข้อผิดพลาด")));
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snap.hasData || !snap.data!.exists) {
          return const Scaffold(body: Center(child: Text("ไม่พบข้อมูลผู้ใช้งาน")));
        }

        final data = snap.data!.data() as Map<String, dynamic>;
        _initializeLocalData(data);

        final oldImageData = data['image'] ?? {};
        final oldIdCardUrl = oldImageData['id_card'];
        final oldIdCardDeleteHash = oldImageData['deletehash_id_card'];
        final oldRentalUrl = oldImageData['rental_contract'];
        final oldRentalDeleteHash = oldImageData['deletehash_rental_contract'];
        final oldProfileUrl = oldImageData['profile'];
        final oldProfileDeleteHash = oldImageData['deletehashprofil'];

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF00377E),
            title: const Text(
              "บัญชี (ผู้ปล่อยเช่า)",
              style: TextStyle(color: Colors.white), // เปลี่ยนสีข้อความเป็นสีขาว
            ),
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          drawer: MyDrawer(
            username: _username ?? "ไม่มีชื่อ",
            isGoogleLogin: isGoogleLogin,
            profileUrl: oldProfileUrl,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(user.uid, oldProfileUrl, oldProfileDeleteHash),
                _buildProfileSwitch(),
                _buildIncomeSection(user.uid),
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("ข้อมูลส่วนตัว", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      // AddressPicker
                      AddressPicker(
                        initialProvince: _province,
                        initialDistrict: _district,
                        initialSubdistrict: _subdistrict,
                        initialPostalCode: _postalCode,
                        onAddressSelected: (p, d, s, pc) {
                          setState(() {
                            _province = p;
                            _district = d;
                            _subdistrict = s;
                            _postalCode = pc;
                          });
                          // ซิงค์ที่อยู่กับ Firestore ทันที
                          FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                            'address': {
                              'province': p,
                              'district': d,
                              'subdistrict': s,
                              'postalCode': pc,
                            },
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // รายละเอียดเพิ่มเติม ที่สามารถแก้ไขได้และซิงค์กับ database
                      _whiteBox(
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("รายละเอียดเพิ่มเติม", style: TextStyle(fontSize: 18)),
                                  const SizedBox(height: 8),
                                  Text(
                                    _moreInfo?.isNotEmpty == true ? _moreInfo! : "ไม่มีข้อมูล",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final newVal = await _showEditDialog("รายละเอียดเพิ่มเติม", _moreInfo);
                                if (newVal != null) {
                                  setState(() => _moreInfo = newVal);
                                  FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                                    'moreinfo': newVal,
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // เบอร์โทร
                      _whiteBox(
                        Row(
                          children: [
                            Expanded(
                              child: Text("เบอร์โทรศัพท์: ${_phone ?? "ไม่มีข้อมูล"}", style: const TextStyle(fontSize: 16)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final newVal = await _showEditDialog("เบอร์โทรศัพท์", _phone);
                                if (newVal != null) {
                                  setState(() => _phone = newVal);
                                  FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                                    'phone': newVal,
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // อีเมล (สำหรับข้อมูลอีเมลมักไม่ให้แก้ไขโดยตรง)
                      _whiteBox(
                        Row(
                          children: [
                            Expanded(
                              child: Text("อีเมล: ${_email ?? "ไม่มีข้อมูล"}", style: const TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // รูปบัตรประชาชน / รูปสัญญาปล่อยเช่า
                      _whiteBox(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('รูปบัตรประชาชน', style: TextStyle(fontSize: 18)),
                            const SizedBox(height: 5),
                            ElevatedButton.icon(
                              onPressed: _pickIdCardImage,
                              icon: const Icon(Icons.upload),
                              label: const Text('เลือกรูป'),
                            ),
                            if (_idCardFile != null) ...[
                              const SizedBox(height: 10),
                              Image.file(_idCardFile!, width: 100, height: 100, fit: BoxFit.cover),
                            ],
                            const SizedBox(height: 20),
                            const Text('สัญญาปล่อยเช่า (จำเป็น)', style: TextStyle(fontSize: 18)),
                            const SizedBox(height: 5),
                            ElevatedButton.icon(
                              onPressed: _pickRentalContractImage,
                              icon: const Icon(Icons.upload),
                              label: const Text('เลือกรูป'),
                            ),
                            if (_rentalContractFile != null) ...[
                              const SizedBox(height: 10),
                              Image.file(_rentalContractFile!, width: 100, height: 100, fit: BoxFit.cover),
                            ],
                            const SizedBox(height: 20),
                            // ปุ่มตำแหน่งที่ตั้ง
                            ElevatedButton.icon(
                              onPressed: () async {
                                await _updateCurrentLocation(user.uid);
                              },
                              icon: const Icon(Icons.location_on),
                              label: const Text("เพิ่มตำแหน่งที่ตั้ง"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // ปุ่มบันทึก สำหรับการอัปโหลดรูปและข้อมูลที่ยังไม่ได้ซิงค์
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              // บันทึกข้อมูลสู่ Firestore (moreinfo, username, phone, address)
                              await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                                'username': _username,
                                'email': _email,
                                'phone': _phone,
                                'moreinfo': _moreInfo,
                                'address': {
                                  'province': _province,
                                  'district': _district,
                                  'subdistrict': _subdistrict,
                                  'postalCode': _postalCode,
                                },
                              });
                              // รูปโปรไฟล์
                              if (_profileFile != null) {
                                if (oldProfileUrl != null &&
                                    oldProfileUrl != 'null' &&
                                    oldProfileDeleteHash != null &&
                                    oldProfileDeleteHash != 'null') {
                                  await _deleteImageFromImgur(oldProfileDeleteHash);
                                }
                                final uploadResult = await _uploadImageToImgur(_profileFile!);
                                await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                                  'image.profile': uploadResult['link'],
                                  'image.deletehashprofil': uploadResult['deletehash'],
                                });
                              }
                              // รูปบัตรประชาชน
                              if (_idCardFile != null) {
                                if (oldIdCardUrl != null &&
                                    oldIdCardUrl != 'null' &&
                                    oldIdCardDeleteHash != null &&
                                    oldIdCardDeleteHash != 'null') {
                                  await _deleteImageFromImgur(oldIdCardDeleteHash);
                                }
                                final uploadResult = await _uploadImageToImgur(_idCardFile!);
                                await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                                  'image.id_card': uploadResult['link'],
                                  'image.deletehash_id_card': uploadResult['deletehash'],
                                });
                              }
                              // รูปสัญญาปล่อยเช่า
                              if (_rentalContractFile != null) {
                                if (oldRentalUrl != null &&
                                    oldRentalUrl != 'null' &&
                                    oldRentalDeleteHash != null &&
                                    oldRentalDeleteHash != 'null') {
                                  await _deleteImageFromImgur(oldRentalDeleteHash);
                                }
                                final uploadResult = await _uploadImageToImgur(_rentalContractFile!);
                                await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
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

  // -------------------- ส่วน UI ย่อย --------------------
  Widget _buildProfileHeader(String userId, String? oldProfileUrl, String? oldProfileDeleteHash) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // รูปโปรไฟล์
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
                child: (_profileFile == null && (oldProfileUrl == null || oldProfileUrl == 'null'))
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
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
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(_username ?? "ไม่มีชื่อ", style: const TextStyle(fontSize: 24))),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () async {
              final newVal = await _showEditDialog("ชื่อผู้ใช้", _username);
              if (newVal != null && newVal.isNotEmpty) {
                setState(() => _username = newVal);
                FirebaseFirestore.instance.collection('users').doc(userId).update({
                  'username': newVal,
                });
              }
            },
          ),
        ],
      ),
    );
  }

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
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfileRenter()));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text("ผู้เช่า", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text("ผู้ปล่อยเช่า", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeSection(String userId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('payments').doc(userId).snapshots(),
      builder: (_, paySnap) {
        if (paySnap.hasError) return const Center(child: Text("เกิดข้อผิดพลาดในการโหลดรายได้"));
        if (paySnap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!paySnap.hasData || !paySnap.data!.exists) return _incomeBox(0);
        final payData = paySnap.data!.data() as Map<String, dynamic>;
        final num income = payData['mypayment'] ?? 0;
        return _incomeBox(income);
      },
    );
  }

  Widget _incomeBox(num myPayment) {
    final incomeText = myPayment.toStringAsFixed(2);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("รายได้วันนี้", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text("฿ $incomeText", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[700])),
        ],
      ),
    );
  }

  Widget _whiteBox(Widget child) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  // -------------------- ฟังก์ชันอัปโหลด/ลบรูป และอัปเดตตำแหน่ง --------------------
  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _profileFile = File(pickedFile.path));
  }

  Future<void> _pickIdCardImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _idCardFile = File(pickedFile.path));
  }

  Future<void> _pickRentalContractImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _rentalContractFile = File(pickedFile.path));
  }

  /// ฟังก์ชันอัปโหลดรูปไป Imgur
  Future<Map<String, dynamic>> _uploadImageToImgur(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final response = await http.post(
      Uri.parse('https://api.imgur.com/3/image'),
      headers: {'Authorization': 'Client-ID $_imgurClientId'},
      body: {'image': base64Image, 'type': 'base64'},
    );
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      return {
        'link': data['data']['link'],
        'deletehash': data['data']['deletehash'],
      };
    } else {
      throw Exception("อัปโหลดรูปไป Imgur ไม่สำเร็จ: ${data['data']['error']}");
    }
  }

  Future<void> _deleteImageFromImgur(String deleteHash) async {
    await http.delete(
      Uri.parse('https://api.imgur.com/3/image/$deleteHash'),
      headers: {'Authorization': 'Client-ID $_imgurClientId'},
    );
  }

  Future<void> _updateCurrentLocation(String userId) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ไม่ได้รับสิทธิ์การเข้าถึงตำแหน่ง")),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("สิทธิ์การเข้าถึงตำแหน่งถูกปฏิเสธอย่างถาวร")),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'location': {
        'latitude': position.latitude,
        'longitude': position.longitude,
      }
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("อัปเดตตำแหน่งที่ตั้งเรียบร้อย")),
    );
  }

  /// Dialog แก้ไขข้อมูล (เช่น ชื่อ, เบอร์โทร, รายละเอียดเพิ่มเติม)
  Future<String?> _showEditDialog(String label, String? currentValue) async {
    final ctrl = TextEditingController(text: currentValue ?? "");
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("แก้ไข $label"),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ยกเลิก")),
          TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text("บันทึก")),
        ],
      ),
    );
  }
}
