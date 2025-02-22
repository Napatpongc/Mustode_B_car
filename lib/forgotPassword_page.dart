import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'otp_verification_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  // ฟังก์ชันสร้าง OTP แบบสุ่ม 6 หลัก
  String generateOTP() {
    final random = Random();
    int otp = random.nextInt(900000) + 100000; // สุ่ม 6 หลัก
    return otp.toString();
  }

  // ฟังก์ชันส่ง OTP ผ่าน Cloud Function ที่เรา deploy ไป
  Future<bool> sendOtpViaCloudFunction(String email, String otp) async {
    // เปลี่ยน URL ให้ตรงกับ URL ของ Cloud Function ที่ deploy แล้ว
    final url = Uri.parse('http://10.0.2.2:5001/mustodebcar-ac28a/us-central1/sendOtpEmail');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'otp': otp}),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Cloud Function error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception in Cloud Function call: $e');
      return false;
    }
  }

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
      });

      String email = _emailController.text;
      String otp = generateOTP();

      // ส่ง OTP ผ่าน Cloud Function
      bool emailSent = await sendOtpViaCloudFunction(email, otp);

      setState(() {
        _isProcessing = false;
      });

      if (emailSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ส่ง OTP ไปที่ $email แล้ว'),
            backgroundColor: Colors.green,
          ),
        );
        // นำทางไปหน้ายืนยัน OTP พร้อมส่งค่า email และ otp
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(
              email: email,
              generatedOtp: otp,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไม่สามารถส่ง OTP ได้ในขณะนี้'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ลืมรหัสผ่าน'),
        backgroundColor: Color(0xFF00377E),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'กรุณากรอกอีเมลของคุณเพื่อรับ OTP สำหรับรีเซ็ตรหัสผ่าน',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                      hintText: "example@mail.com",
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกอีเมล';
                      } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                          .hasMatch(value)) {
                        return 'อีเมลไม่ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  _isProcessing
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _resetPassword,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                            backgroundColor: Color(0xFF00377E),
                          ),
                          child: Text(
                            'รีเซ็ตรหัสผ่าน',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'ย้อนกลับไปหน้าล็อกอิน',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
