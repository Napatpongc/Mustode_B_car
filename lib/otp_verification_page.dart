import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'reset_password_custom_page.dart';
import 'utils.dart';

class OtpVerificationCustomPage extends StatefulWidget {
  final String phoneNumber; // เบอร์โทรในรูปแบบ E.164 เช่น "+66956453648"
  const OtpVerificationCustomPage({Key? key, required this.phoneNumber})
      : super(key: key);

  @override
  _OtpVerificationCustomPageState createState() =>
      _OtpVerificationCustomPageState();
}

class _OtpVerificationCustomPageState extends State<OtpVerificationCustomPage> {
  // เก็บ TextEditingController และ FocusNode สำหรับ 6 ช่อง
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (index) => FocusNode());

  Timer? _resendTimer;
  int _secondsRemaining = 300; // 5 นาที = 300 วินาที

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  // เริ่มนับถอยหลัง 5 นาที
  void _startTimer() {
    _resendTimer?.cancel();
    setState(() {
      _secondsRemaining = 300;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  // แปลงเวลานับถอยหลังให้อยู่ในรูปแบบ mm.ss
  String get formattedTime {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return "${minutes.toString().padLeft(2, '0')}.${seconds.toString().padLeft(2, '0')}";
  }

  // ฟังก์ชันสำหรับสร้าง TextField ช่องละ 1 หลัก
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
          counterText: "", // ซ่อนตัวนับ
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.7),
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            // เมื่อกรอก 1 ตัวอักษร ให้เลื่อนโฟกัสไปช่องถัดไป
            if (index < 5) {
              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
            } else {
              // ถ้าถึงช่องสุดท้ายแล้ว ซ่อนคีย์บอร์ด
              FocusScope.of(context).unfocus();
            }
          } else {
            // ถ้าลบตัวอักษร ให้โฟกัสย้อนกลับไปช่องก่อนหน้า
            if (index > 0) {
              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
            }
          }
        },
      ),
    );
  }

  // รวมค่าจาก 6 ช่องเป็นสตริงเดียว
  String get _enteredOtp =>
      _controllers.map((controller) => controller.text).join();

  // ฟังก์ชันตรวจสอบ OTP
  Future<void> _verifyOTP() async {
    String enteredOtp = _enteredOtp.trim(); // รวบรวม 6 หลักจากแต่ละช่อง
    if (enteredOtp.length < 6) {
      Get.snackbar("Error", "กรุณากรอก OTP ให้ครบ 6 หลัก");
      return;
    }

    DocumentSnapshot otpDoc = await FirebaseFirestore.instance
        .collection('otp_codes')
        .doc(widget.phoneNumber)
        .get();

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
      // ทำเครื่องหมายว่า OTP นี้ถูกใช้แล้ว
      await FirebaseFirestore.instance
          .collection('otp_codes')
          .doc(widget.phoneNumber)
          .update({'used': true});

      Get.snackbar("Success", "OTP ถูกต้อง");
      // ไปหน้า Reset Password
      Get.to(() => ResetPasswordCustomPage(phoneNumber: widget.phoneNumber));
    } else {
      Get.snackbar("Error", "OTP ไม่ถูกต้อง กรุณาลองใหม่");
    }
  }

  // ฟังก์ชันส่ง OTP ใหม่
  Future<void> _resendOTP() async {
    // สุ่ม OTP ใหม่
    String newOtp = generateOTP();
    DateTime now = DateTime.now();
    DateTime expireAt = now.add(const Duration(minutes: 5));

    // อัปเดตข้อมูล OTP ใน Firestore
    await FirebaseFirestore.instance
        .collection('otp_codes')
        .doc(widget.phoneNumber)
        .set({
      'otp': newOtp,
      'createdAt': now,
      'expireAt': expireAt,
      'used': false,
    });

    // ส่ง SMS จริง (จำลอง)
    await sendSms(widget.phoneNumber, newOtp);

    Get.snackbar("OTP Sent", "OTP ถูกส่งไปที่ ${widget.phoneNumber}");
    _startTimer();
  }

  // ฟังก์ชันส่ง SMS จริง (ผสานกับ SMS Gateway API เช่น Twilio)
  Future<void> sendSms(String phone, String otp) async {
    print('Sending SMS to $phone: Your new OTP is $otp');
    // TODO: Implement SMS Gateway API integration here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify OTP"),
        centerTitle: true,
        backgroundColor: const Color(0xFF00377E),
      ),
      // พื้นหลังสีฟ้าอ่อน
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.blue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "OTP ถูกส่งไปที่ ${widget.phoneNumber}\n(ใช้ได้ 5 นาที)",
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Row ของ 6 ช่อง TextField
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) => _buildOtpBox(index)),
              ),
              const SizedBox(height: 16),
              // ปุ่ม Verify OTP
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00377E),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Verify OTP",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // แสดงเวลานับถอยหลังหรือปุ่ม Resend
              _secondsRemaining > 0
                  ? Text(
                      "ขอรหัสใหม่ได้ในอีก ${formattedTime} นาที",
                      style: const TextStyle(fontSize: 14),
                    )
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
                          style: TextStyle(
                            color: Colors.black87,
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
    );
  }
}
