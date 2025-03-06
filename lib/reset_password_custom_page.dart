import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'ProfileRenter.dart';

class ResetPasswordCustomPage extends StatefulWidget {
  final String phoneNumber;
  const ResetPasswordCustomPage({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _ResetPasswordCustomPageState createState() => _ResetPasswordCustomPageState();
}

class _ResetPasswordCustomPageState extends State<ResetPasswordCustomPage> {
  // เพิ่มช่องกรอกรหัสผ่านปัจจุบันสำหรับ re-authenticate
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isUpdating = false;

  Future<void> _updatePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    if (currentPassword.isEmpty || newPassword.isEmpty) {
      Get.snackbar("Error", "กรุณากรอกรหัสผ่านปัจจุบันและรหัสผ่านใหม่");
      return;
    }
    setState(() => _isUpdating = true);
    try {
      // Query Firestore เพื่อดึงข้อมูลผู้ใช้ตามเบอร์โทร
      final QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: widget.phoneNumber)
          .get();
      if (userQuery.docs.isEmpty) {
        Get.snackbar("Error", "ไม่พบผู้ใช้งานสำหรับเบอร์นี้");
        return;
      }
      final String userId = userQuery.docs.first.id;
      final Map<String, dynamic> userData = userQuery.docs.first.data() as Map<String, dynamic>;
      final String email = (userData['email'] ?? "").toString().trim();
      if (email.isEmpty) {
        Get.snackbar("Error", "ไม่พบอีเมลของผู้ใช้ในระบบ");
        return;
      }

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        Get.snackbar("Error", "ไม่พบผู้ใช้งานล็อกอินอยู่ กรุณาล็อกอินใหม่");
        return;
      }

      // re-authenticate ด้วย EmailAuthProvider credential
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await currentUser.reauthenticateWithCredential(credential);

      // updatePassword ใน FirebaseAuth
      await currentUser.updatePassword(newPassword);

      // อัปเดตรหัสผ่านใน Firestore ให้สอดคล้องกัน
      await FirebaseFirestore.instance.collection('users').doc(userId).update({'password': newPassword});

      Get.snackbar("Success", "รหัสผ่านถูกเปลี่ยนเรียบร้อยแล้ว");

      // sign out และ sign in ใหม่ด้วยรหัสผ่านใหม่
      await FirebaseAuth.instance.signOut();
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: newPassword);

      // นำทางไปยัง ProfileRenter
      Get.offAll(() => ProfileRenter());
    } on FirebaseAuthException catch (e) {
      String errorMessage = "ไม่สามารถเปลี่ยนรหัสผ่านได้: ${e.message}";
      if (e.code == 'wrong-password') {
        errorMessage = "รหัสผ่านปัจจุบันไม่ถูกต้อง";
      }
      Get.snackbar("Error", errorMessage);
    } catch (e) {
      Get.snackbar("Error", "ไม่สามารถเปลี่ยนรหัสผ่านได้: $e");
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Widget _buildContent(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        width: screenWidth * 0.9,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "เปลี่ยนรหัสผ่าน",
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            // ช่องกรอกรหัสผ่านปัจจุบัน
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock, color: Colors.black54),
                labelText: "Current Password",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            // ช่องกรอกรหัสผ่านใหม่
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock, color: Colors.black54),
                labelText: "New Password",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            _isUpdating
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updatePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00377E),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text(
                        "Update Password",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset Password"),
        centerTitle: true,
        backgroundColor: const Color(0xFF00377E),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.blue.shade50,
        child: SafeArea(child: SingleChildScrollView(child: _buildContent(context))),
      ),
    );
  }
}
