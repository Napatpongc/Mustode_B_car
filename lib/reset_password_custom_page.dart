import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_page.dart';

class ResetPasswordCustomPage extends StatefulWidget {
  final String phoneNumber;
  const ResetPasswordCustomPage({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _ResetPasswordCustomPageState createState() => _ResetPasswordCustomPageState();
}

class _ResetPasswordCustomPageState extends State<ResetPasswordCustomPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool isUpdating = false;

  Future<void> _updatePassword() async {
    setState(() => isUpdating = true);
    try {
      // ค้นหา document ของ user โดยใช้เบอร์โทร (ในที่นี้สมมุติว่าเบอร์โทรถูกเก็บใน field 'phone')
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: widget.phoneNumber)
          .get();

      if (userQuery.docs.isEmpty) {
        Get.snackbar("Error", "ไม่พบผู้ใช้งานสำหรับเบอร์นี้");
        return;
      }
      // สมมุติว่ามีแค่ 1 document
      String userId = userQuery.docs.first.id;

      // อัปเดตรหัสผ่านใหม่ (ในโปรเจกต์จริง ควรเข้ารหัสก่อนเก็บ)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'password': _passwordController.text.trim()});

      Get.snackbar("Success", "รหัสผ่านถูกเปลี่ยนเรียบร้อยแล้ว");
      // นำทางไปยังหน้า LoginPage
      Get.offAll(() => LoginPage());
    } catch (e) {
      Get.snackbar("Error", "ไม่สามารถเปลี่ยนรหัสผ่านได้: $e");
    } finally {
      setState(() => isUpdating = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // AppBar ที่ใช้สีเดียวกับโทนหลัก
      appBar: AppBar(
        title: const Text("Reset Password"),
        centerTitle: true,
        backgroundColor: const Color(0xFF00377E),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.blue.shade50, // พื้นหลังฟ้าอ่อน
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                width: screenWidth * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // หัวข้อ
                      Text(
                        "เปลี่ยนรหัสผ่าน",
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // ช่องกรอก New Password
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock, color: Colors.black54),
                          labelText: "New Password",
                          labelStyle: const TextStyle(color: Colors.black87),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // ปุ่ม Update Password
                      isUpdating
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _updatePassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00377E),
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  "Update Password",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
