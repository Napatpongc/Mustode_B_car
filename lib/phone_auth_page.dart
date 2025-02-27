import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'otp_verification_page.dart';
import 'utils.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({Key? key}) : super(key: key);

  @override
  _PhoneAuthPageState createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isSendingOtp = false;
  String verificationId = "";

  void _sendOTP() async {
    setState(() {
      isSendingOtp = true;
    });

    String inputPhone = _phoneController.text.trim();
    String phoneNumber = formatThaiPhone(inputPhone);

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // ระบบบางครั้ง verify อัตโนมัติ (Android)
        await _auth.signInWithCredential(credential);
        Get.snackbar("Success", "Phone number automatically verified");
      },
      verificationFailed: (FirebaseAuthException e) {
        Get.snackbar("Error", e.message ?? "OTP verification failed");
        setState(() {
          isSendingOtp = false;
        });
      },
      codeSent: (String verId, int? resendToken) {
        verificationId = verId;
        setState(() {
          isSendingOtp = false;
        });
        // นำทางไปยังหน้าตรวจสอบ OTP พร้อมส่งเบอร์และ verificationId
        Get.to(() => OtpVerificationPage(
              phoneNumber: phoneNumber,
              verificationId: verificationId,
            ));
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Phone Authentication")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Enter Phone Number",
                hintText: "0956453648",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            isSendingOtp
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _sendOTP,
                    child: const Text("Send OTP"),
                  ),
          ],
        ),
      ),
    );
  }
}
