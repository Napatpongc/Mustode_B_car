import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'otp_verification_page.dart';
import 'utils.dart';

class PhoneAuthCustomPage extends StatefulWidget {
  const PhoneAuthCustomPage({Key? key}) : super(key: key);

  @override
  _PhoneAuthCustomPageState createState() => _PhoneAuthCustomPageState();
}

class _PhoneAuthCustomPageState extends State<PhoneAuthCustomPage> {
  final TextEditingController _phoneController = TextEditingController();
  bool isProcessing = false;

  // ฟังก์ชันส่ง SMS จริง (ต้องผสานกับ API ของ SMS Gateway)
  Future<void> sendSms(String phone, String otp) async {
    // ตัวอย่างจำลองส่ง SMS
    print('Sending SMS to $phone: Your OTP code is $otp');
    // TODO: Implement SMS API call here (e.g., Twilio)
  }

  Future<void> _sendOTP() async {
    setState(() => isProcessing = true);

    // แปลงเบอร์เป็น E.164
    String phoneNumber = formatThaiPhone(_phoneController.text.trim());

    // ตรวจสอบว่ามีเบอร์นี้ใน Collection "users"
    QuerySnapshot userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phoneNumber)
        .get();

    if (userQuery.docs.isEmpty) {
      Get.snackbar("Error", "เบอร์นี้ยังไม่ถูกลงทะเบียนในระบบ");
      setState(() => isProcessing = false);
      return;
    }

    // สุ่ม OTP 6 หลัก
    String otp = generateOTP();

    // กำหนดเวลา expire 5 นาที
    DateTime now = DateTime.now();
    DateTime expireAt = now.add(const Duration(minutes: 5));

    // เก็บ OTP ลงใน Collection "otp_codes"
    await FirebaseFirestore.instance
        .collection('otp_codes')
        .doc(phoneNumber)
        .set({
      'otp': otp,
      'createdAt': now,
      'expireAt': expireAt,
      'used': false,
    });

    // ส่ง SMS จริง
    await sendSms(phoneNumber, otp);

    Get.snackbar("OTP Sent", "OTP ถูกส่งไปที่ $phoneNumber");

    // ไปหน้า OTP Verification
    Get.to(() => OtpVerificationCustomPage(phoneNumber: phoneNumber));

    setState(() => isProcessing = false);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("กรุณาใส่เบอร์โทรศัพท์"),
        centerTitle: true,
        backgroundColor: const Color(0xFF00377E),
      ),
      // พื้นหลังฟ้าอ่อนเต็มหน้าจอ
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.blue.shade50, // พื้นหลังฟ้าอ่อน
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 40,
                ),
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
                      Text(
                        "Enter phone number",
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.phone, color: Colors.black54),
                          labelText: "Enter Phone Number",
                          labelStyle: const TextStyle(color: Colors.black87),
                          hintText: "08XXXXXXXX",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 20),
                      isProcessing
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _sendOTP,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00377E),
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  "ยืนยัน",
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
