import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'reset_password_custom_page.dart';
import 'utils.dart';

class OtpVerificationPage extends StatefulWidget {
  final String verificationId; // ไม่ได้ใช้ในที่นี้
  final String phoneNumber; // เบอร์โทรในรูปแบบ E.164
  const OtpVerificationPage({Key? key, required this.verificationId, required this.phoneNumber}) : super(key: key);

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  Timer? _resendTimer;
  int _secondsRemaining = 300;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    for (var controller in _controllers) controller.dispose();
    for (var node in _focusNodes) node.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _resendTimer?.cancel();
    setState(() {
      _secondsRemaining = 300;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) _secondsRemaining--;
        else timer.cancel();
      });
    });
  }

  String get formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return "${minutes.toString().padLeft(2, '0')}.${seconds.toString().padLeft(2, '0')}";
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 40,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.7),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            } else {
              FocusScope.of(context).unfocus();
            }
          } else {
            if (index > 0) {
              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
            }
          }
        },
      ),
    );
  }

  String get _enteredOtp => _controllers.map((c) => c.text).join();

  Future<void> _verifyOTP() async {
    String enteredOtp = _enteredOtp.trim();
    if (enteredOtp.length < 6) {
      Get.snackbar("Error", "กรุณากรอก OTP ให้ครบ 6 หลัก");
      return;
    }
    DocumentSnapshot otpDoc = await FirebaseFirestore.instance.collection('otp_codes').doc(widget.phoneNumber).get();
    if (!otpDoc.exists) {
      Get.snackbar("Error", "ไม่พบ OTP สำหรับเบอร์นี้");
      return;
    }
    Map<String, dynamic> data = otpDoc.data() as Map<String, dynamic>;
    String otp = data['otp'];
    DateTime expireAt = (data['expireAt'] as Timestamp).toDate();
    bool used = data['used'] ?? false;
    if (used) {
      Get.snackbar("Error", "OTP นี้ถูกใช้งานไปแล้ว กรุณาขอใหม่");
      return;
    }
    if (DateTime.now().isAfter(expireAt)) {
      Get.snackbar("Error", "OTP หมดอายุแล้ว กรุณาขอใหม่");
      return;
    }
    if (enteredOtp == otp) {
      await FirebaseFirestore.instance.collection('otp_codes').doc(widget.phoneNumber).update({'used': true});
      Get.snackbar("Success", "OTP ถูกต้อง");
      Get.to(() => ResetPasswordCustomPage(phoneNumber: widget.phoneNumber));
    } else {
      Get.snackbar("Error", "OTP ไม่ถูกต้อง กรุณาลองใหม่");
    }
  }

  Future<void> _resendOTP() async {
    String newOtp = generateOTP();
    DateTime now = DateTime.now();
    DateTime expireAt = now.add(const Duration(minutes: 5));
    await FirebaseFirestore.instance.collection('otp_codes').doc(widget.phoneNumber).set({
      'otp': newOtp,
      'createdAt': now,
      'expireAt': expireAt,
      'used': false,
    });
    print("Resending SMS to ${widget.phoneNumber}: Your new OTP is $newOtp");
    Get.snackbar("OTP Sent", "OTP ถูกส่งไปที่ ${widget.phoneNumber}");
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify OTP"),
        centerTitle: true,
        backgroundColor: const Color(0xFF00377E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "OTP ถูกส่งไปแล้ว\n(ใช้ได้ 5 นาที)",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) => _buildOtpBox(index)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00377E),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
                  "Verify OTP",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _secondsRemaining > 0
                ? Text("ขอรหัสใหม่ได้ในอีก ${formattedTime} นาที", style: const TextStyle(fontSize: 14))
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _resendOTP,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        "Resend OTP",
                        style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
