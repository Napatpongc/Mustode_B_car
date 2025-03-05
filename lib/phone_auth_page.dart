import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'utils.dart'; // ใช้สำหรับ formatThaiPhone และ generateOTP
import 'otp_verification_page.dart';

class PhoneAuthCustomPage extends StatefulWidget {
  const PhoneAuthCustomPage({Key? key}) : super(key: key);

  @override
  _PhoneAuthCustomPageState createState() => _PhoneAuthCustomPageState();
}

class _PhoneAuthCustomPageState extends State<PhoneAuthCustomPage> {
  final TextEditingController _phoneController = TextEditingController();
  bool isProcessing = false;

  Future<void> _sendOTP() async {
    setState(() => isProcessing = true);
    String phoneNumber = formatThaiPhone(_phoneController.text);
    debugPrint("Phone Number (E.164): $phoneNumber");

    // ตรวจสอบว่ามีเบอร์นี้ใน Firestore (ใน collection 'users')
    QuerySnapshot userQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phoneNumber)
        .get();
    if (userQuery.docs.isEmpty) {
      Get.snackbar("Error", "เบอร์นี้ยังไม่ถูกลงทะเบียนในระบบ");
      setState(() => isProcessing = false);
      return;
    }

    String otp = generateOTP();
    DateTime now = DateTime.now();
    DateTime expireAt = now.add(const Duration(minutes: 5));

    // บันทึก OTP ลง Firestore (ใช้เบอร์โทรเป็น document ID)
    await FirebaseFirestore.instance
        .collection('otp_codes')
        .doc(phoneNumber)
        .set({
      'otp': otp,
      'createdAt': now,
      'expireAt': expireAt,
      'used': false,
    });

    // ส่ง OTP ไปที่โทรศัพท์จริง (จำลองด้วย print)
    print("Sending SMS to $phoneNumber: Your OTP is $otp");
    Get.snackbar("OTP Sent", "OTP has been sent to $phoneNumber");

    // นำทางไปหน้า OTP Verification
    Get.to(() => OtpVerificationPage(
          verificationId: '', // ไม่ใช้สำหรับ OTP จาก Firestore
          phoneNumber: phoneNumber,
        ));
    setState(() => isProcessing = false);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("กรุณาใส่เบอร์โทรศัพท์"),
        centerTitle: true,
        backgroundColor: const Color(0xFF00377E),
      ),
      // พื้นหลังสีฟ้าอ่อน
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.blue.shade50,
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
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // หัวข้อ
                      Text(
                        "Enter phone number",
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ช่องกรอกเบอร์โทร
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.phone,
                            color: Colors.black54,
                          ),
                          labelText: "Phone Number",
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

                      // ปุ่ม "ยืนยัน"
                      isProcessing
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _sendOTP,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00377E),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
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
