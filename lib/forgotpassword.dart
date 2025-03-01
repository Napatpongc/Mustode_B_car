import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  String? _verificationId;
  bool _codeSent = false;

  // ตรวจสอบว่าเบอร์โทรศัพท์ที่กรอกมีอยู่ใน Firestore หรือไม่
  Future<bool> _checkPhoneExists(String phone) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  // ส่ง OTP ไปยังเบอร์โทรศัพท์ที่กรอก
  Future<void> _sendOTP(String phone) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // ในกรณีที่ระบบสามารถยืนยัน OTP ได้อัตโนมัติ (บางเครื่องหรือบางสถานการณ์)
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('การส่ง OTP ล้มเหลว: ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? forceResendingToken) {
        setState(() {
          _verificationId = verificationId;
          _codeSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP ถูกส่งไปยัง $phone')),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  // ยืนยัน OTP ที่กรอกและรีเซ็ทพาสเวิร์ด
  Future<void> _verifyOTPAndResetPassword() async {
    if (_verificationId != null) {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );
      try {
        // สำหรับกระบวนการ forgot password ให้ sign in ด้วย OTP credential
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        User? user = userCredential.user;
        if (user != null) {
          // เปลี่ยนพาสเวิร์ดใหม่ (UID ของผู้ใช้จะไม่เปลี่ยน)
          await user.updatePassword(_newPasswordController.text.trim());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('รีเซ็ทพาสเวิร์ดเรียบร้อยแล้ว')),
          );
          Navigator.pop(context);
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.message}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รีเซ็ทพาสเวิร์ด'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (!_codeSent) ...[
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'เบอร์โทรศัพท์',
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String phone = _phoneController.text.trim();
                  if (phone.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('กรุณากรอกเบอร์โทรศัพท์')),
                    );
                    return;
                  }
                  bool exists = await _checkPhoneExists(phone);
                  if (!exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('ไม่พบเบอร์โทรศัพท์นี้ในระบบ')),
                    );
                    return;
                  }
                  await _sendOTP(phone);
                },
                child: Text('ส่ง OTP'),
              ),
            ] else ...[
              TextField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: 'กรอกรหัส OTP',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'พาสเวิร์ดใหม่',
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyOTPAndResetPassword,
                child: Text('รีเซ็ทพาสเวิร์ด'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
