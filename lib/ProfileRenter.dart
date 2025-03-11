import 'dart:io';
import 'dart:convert'; // สำหรับ base64Encode
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'ProfileLessor.dart';
import 'list.dart';

// import AddressPicker (รองรับค่าตั้งต้น 4 พารามิเตอร์)
import 'address_picker.dart';

class ProfileRenter extends StatefulWidget {
  @override
  _ProfileRenterState createState() => _ProfileRenterState();
}

class _ProfileRenterState extends State<ProfileRenter> {
  // ------------------ ตัวแปรเก็บข้อมูลโปรไฟล์ ------------------
  String? username;
  String? email;
  String? phone;

  // ------------------ ตัวแปร Address ------------------
  String? province;
  String? district;
  String? subdistrict;
  String? postalCode;

  // ------------------ ช่องกรอกข้อมูลเพิ่มเติม (TextField แยก) ------------------
  String? moreinfo;

  // ------------------ ตัวแปรรูปภาพ ------------------
  File? _drivingLicenseFile;
  File? _profileFile;
  final ImagePicker _picker = ImagePicker();

  // Client ID ของ Imgur
  final String _imgurClientId = "ed6895b5f1bf3d7";

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("ไม่พบผู้ใช้ที่ login")),
      );
    }
    bool isGoogleLogin = currentUser.providerData.any((p) => p.providerId == 'google.com');

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(body: Center(child: Text("เกิดข้อผิดพลาด")));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text("ไม่พบข้อมูลผู้ใช้งาน")));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        _initializeLocalData(data);

        final imageData = data['image'] ?? {};
        final oldProfileUrl = imageData['profile'];
        final oldProfileDeleteHash = imageData['deletehashprofil'];
        final oldDrivingUrl = imageData['driving_license'];
        final oldDrivingDeleteHash = imageData['deletehash_driving_license'];

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
          drawer: MyDrawerRenter(
            username: username ?? "ไม่มีชื่อ",
            isGoogleLogin: isGoogleLogin,
            profileUrl: oldProfileUrl,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(oldProfileUrl),
                _buildProfileSwitch(),
                _buildMainForm(
                  currentUser.uid,
                  oldProfileUrl,
                  oldProfileDeleteHash,
                  oldDrivingUrl,
                  oldDrivingDeleteHash,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// โหลดข้อมูลจาก Firestore -> State ครั้งแรก (กรณี State ยังไม่ถูกเซ็ต)
  void _initializeLocalData(Map<String, dynamic> data) {
    username ??= data['username'] as String?;
    email ??= data['email'] as String?;
    phone ??= data['phone'] as String?;

    final address = data['address'] as Map<String, dynamic>?;
    if (address != null) {
      province ??= address['province'];
      district ??= address['district'];
      subdistrict ??= address['subdistrict'];
      postalCode ??= address['postalCode'];
      moreinfo ??= address['moreinfo']; 
    }
  }

  // ------------------ UI หลัก ------------------

  Widget _buildHeader(String? oldProfileUrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB3E5FC), Color(0xFFE1F5FE)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey[300],
                backgroundImage: _profileFile != null
                    ? FileImage(_profileFile!)
                    : (oldProfileUrl != null && oldProfileUrl != 'null'
                        ? NetworkImage(oldProfileUrl)
                        : null) as ImageProvider<Object>?,
                child: (_profileFile == null &&
                        (oldProfileUrl == null || oldProfileUrl == 'null'))
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: _pickProfileImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
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
          Expanded(
            child: Text(
              username ?? "ไม่มีชื่อ",
              style: const TextStyle(fontSize: 28, color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () async {
              final newVal = await _showEditDialog("ชื่อผู้ใช้", username);
              if (newVal != null && newVal.isNotEmpty) {
                setState(() => username = newVal);
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
            // ปุ่มผู้เช่า (selected)
            GestureDetector(
              onTap: () {},
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

 

 

  /// ส่วนฟอร์มหลัก
  Widget _buildMainForm(
    String userId,
    String? oldProfileUrl,
    String? oldProfileDeleteHash,
    String? oldDrivingUrl,
    String? oldDrivingDeleteHash,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFB3E5FC),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ข้อมูลส่วนตัว", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // AddressPicker (ส่งค่าเริ่มต้นที่ดึงจาก Firestore)
          AddressPicker(
            initialProvince: province,
            initialDistrict: district,
            initialSubdistrict: subdistrict,
            initialPostalCode: postalCode,
            onAddressSelected: (p, d, s, pc) {
              setState(() {
                province = p;
                district = d;
                subdistrict = s;
                postalCode = pc;
              });
            },
          ),
          const SizedBox(height: 16),

          // ช่องกรอกรายละเอียดเพิ่มเติม
          _buildWhiteBox(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ข้อมูลเพิ่มเติม", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 5),
                TextFormField(
                  initialValue: moreinfo ?? "",
                  decoration: const InputDecoration(labelText: "รายละเอียดเพิ่มเติม"),
                  onChanged: (val) {
                    setState(() => moreinfo = val);
                  },
                ),
              ],
            ),
          ),

          // กล่องแสดงเบอร์โทร
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
                    final newVal = await _showEditDialog("เบอร์โทรศัพท์", phone);
                    if (newVal != null && newVal.isNotEmpty) {
                      setState(() => phone = newVal);
                    }
                  },
                ),
              ],
            ),
          ),

          // อีเมล
          _buildWhiteBox(
            Row(
              children: [
                Expanded(
                  child: Text("อีเมล: $email", style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ส่วนอัปโหลดรูปใบขับขี่
          _buildWhiteBox(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('รูปใบขับขี่', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _pickDrivingLicenseImage,
                  icon: const Icon(Icons.upload),
                  label: const Text('เลือกรูป'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                if (_drivingLicenseFile != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _drivingLicenseFile!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ปุ่มบันทึก
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance.collection('users').doc(userId).update({
                    'username': username,
                    'email': email,
                    'phone': phone,
                    'address': {
                      'province': province,
                      'district': district,
                      'subdistrict': subdistrict,
                      'postalCode': postalCode,
                      'moreinfo': moreinfo, // บันทึกช่องกรอกเพิ่มเติม
                    },
                  });

                  // อัปโหลดรูปโปรไฟล์
                  if (_profileFile != null) {
                    await _deleteAndUploadImage(
                      userId: userId,
                      newFile: _profileFile!,
                      oldDeleteHash: oldProfileDeleteHash,
                      firestoreField: 'image.profile',
                      firestoreDeleteHashField: 'image.deletehashprofil',
                    );
                  }

                  // อัปโหลดรูปใบขับขี่
                  if (_drivingLicenseFile != null) {
                    await _deleteAndUploadImage(
                      userId: userId,
                      newFile: _drivingLicenseFile!,
                      oldDeleteHash: oldDrivingDeleteHash,
                      firestoreField: 'image.driving_license',
                      firestoreDeleteHashField: 'image.deletehash_driving_license',
                    );
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
    );
  }

  // ------------------ โค้ดส่วนอัปโหลดรูป / ลบรูป / Dialog ฯลฯ ------------------

  Future<String?> _showEditDialog(String fieldLabel, String? currentValue) {
    final controller = TextEditingController(text: currentValue ?? "");
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("แก้ไข $fieldLabel"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "กรอก $fieldLabel"),
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

  Future<void> _deleteAndUploadImage({
    required String userId,
    required File newFile,
    required String? oldDeleteHash,
    required String firestoreField,
    required String firestoreDeleteHashField,
  }) async {
    if (oldDeleteHash != null && oldDeleteHash != 'null') {
      await _deleteImageFromImgur(oldDeleteHash);
    }
    final uploadResult = await _uploadImageToImgur(newFile);
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      firestoreField: uploadResult['link'],
      firestoreDeleteHashField: uploadResult['deletehash'],
    });
  }

  Future<void> _pickDrivingLicenseImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _drivingLicenseFile = File(pickedFile.path));
    }
  }

  Future<void> _pickProfileImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profileFile = File(pickedFile.path));
    }
  }

  Future<Map<String, dynamic>> _uploadImageToImgur(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse('https://api.imgur.com/3/image'),
      headers: {'Authorization': 'Client-ID $_imgurClientId'},
      body: {'image': base64Image, 'type': 'base64'},
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
  }

  Future<void> _deleteImageFromImgur(String deleteHash) async {
    await http.delete(
      Uri.parse('https://api.imgur.com/3/image/$deleteHash'),
      headers: {'Authorization': 'Client-ID $_imgurClientId'},
    );
  }

  Widget _buildWhiteBox(Widget child) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ------------------- Drawer สำหรับ ProfileRenter ------------------- //
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('แผนที่'),
            onTap: () {
              Navigator.pop(context);
              
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('รายการเช่าทั้งหมด'),
            onTap: () {
              Navigator.pop(context);
               Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ListPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('การตั้งค่าบัญชี'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => ProfileRenter()),
              );
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('ออกจากระบบ', style: TextStyle(color: Colors.red)),
            onTap: () async {
              if (isGoogleLogin) {
                await GoogleSignIn().disconnect();
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
