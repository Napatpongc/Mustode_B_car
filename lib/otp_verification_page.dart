import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'reset_password_page.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpVerificationPage({
    Key? key,
    required this.phoneNumber,
    required this.verificationId,
  }) : super(key: key);

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  bool isVerifying = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Timer variables for countdown (5 minutes)
  static const int otpValiditySeconds = 300; // 5 minutes = 300 seconds
  late Timer _timer;
  int _remainingSeconds = otpValiditySeconds;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _remainingSeconds = otpValiditySeconds;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  // ฟังก์ชันแสดงเวลานับถอยหลังในรูปแบบ mm:ss
  String get _formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    String mStr = minutes.toString().padLeft(2, '0');
    String sStr = seconds.toString().padLeft(2, '0');
    return "$mStr:$sStr";
  }

  // ฟังก์ชัน Resend OTP
  void _resendOTP() async {
    // หากเวลานับถอยหลังหมดแล้ว สามารถ Resend OTP ได้
    if (_remainingSeconds > 0) {
      Get.snackbar("Wait", "Please wait until OTP expires ($_formattedTime remaining)");
      return;
    }
    // นำกลับไปที่หน้า PhoneAuthPageเพื่อส่ง OTP ใหม่
    Get.back(); // กลับไปยังหน้า PhoneAuthPage
  }

  void _verifyOTP() async {
    setState(() {
      isVerifying = true;
    });

    String smsCode = _otpController.text.trim();

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );
      await _auth.signInWithCredential(credential);
      Get.snackbar("Success", "OTP verified successfully!");
      // นำทางไปยังหน้าต่อไป เช่น ResetPasswordPage
      Get.off(() => ResetPasswordPage(phoneNumber: widget.phoneNumber));
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "OTP verification failed");
    } finally {
      setState(() {
        isVerifying = false;
      });
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Enter the OTP sent to ${widget.phoneNumber}"),
            SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "OTP",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text("Time remaining: $_formattedTime", style: TextStyle(fontSize: 16, color: Colors.red)),
            SizedBox(height: 16),
            isVerifying
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _verifyOTP,
                    child: Text("Verify OTP"),
                  ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _resendOTP,
              child: Text("Resend OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
