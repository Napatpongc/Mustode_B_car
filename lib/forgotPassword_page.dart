/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:get/get.dart';
import 'otp_verification_page.dart';
import 'thaibulksms_service.dart';


class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _phoneController = TextEditingController();
  final ThaiBulkSMSService smsService = ThaiBulkSMSService();
  final RxBool isProcessing = false.obs;

  // ฟังก์ชันสุ่ม OTP 6 หลัก
  String generateOTP() => (Random().nextInt(900000) + 100000).toString();

  Future<void> _sendOTP() async {
    isProcessing.value = true;
    // แปลงเบอร์ที่ผู้ใช้กรอก เช่น "0812345678" ให้เป็น "+66812345678"
    String phoneNumber = "66" + _phoneController.text.substring(1);
    String otp = generateOTP();
    try {
      // ส่ง SMS ผ่าน ThaiBulkSMS
      bool sent = await smsService.sendSms(phoneNumber, "Your OTP code is: $otp");
      if (!sent) {
        Get.snackbar("Error", "Failed to send OTP via ThaiBulkSMS");
        isProcessing.value = false;
        return;
      }
      // บันทึก OTP ลง Firestore พร้อม expireTime 5 นาที
      DateTime now = DateTime.now();
      DateTime expireTime = now.add(Duration(minutes: 5));
      await FirebaseFirestore.instance.collection('otp_codes').doc(phoneNumber).set({
        'otp': otp,
        'createdAt': FieldValue.serverTimestamp(),
        'expireAt': expireTime,
        'isUsed': false,
      });
      Get.to(() => OtpVerificationPage(phoneNumber: phoneNumber));
    } catch (e) {
      Get.snackbar("Error", "Failed to send OTP: $e");
    } finally {
      isProcessing.value = false;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Enter Phone Number",
                border: OutlineInputBorder(),
                hintText: "08XXXXXXXX",
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => isProcessing.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _sendOTP,
                    child: const Text("Send OTP"),
                  )),
          ],
        ),
      ),
    );
  }
}*/
