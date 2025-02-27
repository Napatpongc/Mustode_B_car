import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'ProfileRenter.dart';
import 'login_page.dart';
import 'mycar.dart';

/// Sidebar (Drawer) ที่ใช้ใน ProfileLessor
class MyDrawer extends StatelessWidget {
  final String username;
  final bool isGoogleLogin;
  const MyDrawer(
      {Key? key, required this.username, required this.isGoogleLogin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF00377E)),
            accountName: Text(username, style: const TextStyle(fontSize: 16)),
            accountEmail: null,
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.grey),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: const Text('รถฉัน'),
            onTap: () {
              Navigator.push(
                context, // ต้องใส่ context
                MaterialPageRoute(
                    builder: (context) => MyCar()), // ใช้ MaterialPageRoute
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
                context, // ต้องใส่ context
                MaterialPageRoute(
                    builder: (context) => ProfileLessor()), // ใช้ MaterialPageRoute
              );
              // เพิ่ม Navigator.push(...) ไปหน้าการตั้งค่าบัญชีที่นี่
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title:
                const Text('ออกจากระบบ', style: TextStyle(color: Colors.red)),
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null)
      return const Scaffold(body: Center(child: Text("ไม่พบผู้ใช้ที่ login")));
    bool isGoogleLogin =
        user.providerData.any((p) => p.providerId == 'google.com');

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (_, snap) {
        if (snap.hasError)
          return const Scaffold(body: Center(child: Text("เกิดข้อผิดพลาด")));
        if (snap.connectionState == ConnectionState.waiting)
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        if (!snap.hasData || !snap.data!.exists)
          return const Scaffold(
              body: Center(child: Text("ไม่พบข้อมูลผู้ใช้งาน")));

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
              username: username ?? "ไม่มีชื่อ", isGoogleLogin: isGoogleLogin),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person, size: 40),
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
                SwitchListTile(
                  title: const Text("ผู้เช่า / ผู้ปล่อยเช่า (ผู้ปล่อยเช่า)"),
                  value: false,
                  onChanged: (val) {
                    if (val)
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => ProfileRenter()));
                  },
                ),
                // รายได้วันนี้
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('payments')
                      .doc(user.uid)
                      .snapshots(),
                  builder: (_, paySnap) {
                    if (paySnap.hasError)
                      return const Center(
                          child: Text("เกิดข้อผิดพลาดในการโหลดรายได้"));
                    if (paySnap.connectionState == ConnectionState.waiting)
                      return const Center(child: CircularProgressIndicator());
                    if (!paySnap.hasData || !paySnap.data!.exists)
                      return _incomeBox(0);
                    var payData = paySnap.data!.data() as Map<String, dynamic>;
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
                              fontSize: 20, fontWeight: FontWeight.bold)),
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
                                    Flexible(
                                        child: Text(
                                            "จังหวัด : ${province ?? "ไม่มีข้อมูล"}")),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () async {
                                        String? newVal = await _editDialog(
                                            "จังหวัด", province);
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
                                    Flexible(
                                        child: Text(
                                            "อำเภอ : ${district ?? "ไม่มีข้อมูล"}")),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () async {
                                        String? newVal = await _editDialog(
                                            "อำเภอ", district);
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
                                    Flexible(
                                        child: Text(
                                            "ตำบล : ${subdistrict ?? "ไม่มีข้อมูล"}")),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () async {
                                        String? newVal = await _editDialog(
                                            "ตำบล", subdistrict);
                                        if (newVal != null) {
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user.uid)
                                              .update({
                                            'address.subdistrict': newVal
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
                                        child: Text(
                                            "รหัสไปรษณีย์ : ${postal ?? "ไม่มีข้อมูล"}")),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () async {
                                        String? newVal = await _editDialog(
                                            "รหัสไปรษณีย์", postal);
                                        if (newVal != null) {
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user.uid)
                                              .update({
                                            'address.postalCode': newVal
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
                                        child: Text(
                                            "เพิ่มเติม : ${more ?? "ไม่มีข้อมูล"}")),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () async {
                                        String? newVal = await _editDialog(
                                            "เพิ่มเติม", more);
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
                              child: Text(
                                  "เบอร์โทรศัพท์: ${phone ?? "ไม่มีข้อมูล"}",
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
                      _whiteBox(Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('รูปใบขับขี่',
                              style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 5),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.upload),
                            label: const Text('เลือกรูป'),
                          ),
                          const SizedBox(height: 20),
                          const Text('รูปใบประชาชน',
                              style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 5),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.upload),
                            label: const Text('เลือกรูป'),
                          ),
                          const SizedBox(height: 20),
                          const Text('สัญญาปล่อยเช่า (จำเป็น)',
                              style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 5),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.upload),
                            label: const Text('เลือกรูป'),
                          ),
                        ],
                      )),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("บันทึกข้อมูลเรียบร้อย")),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                            child: Text("บันทึก",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
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
