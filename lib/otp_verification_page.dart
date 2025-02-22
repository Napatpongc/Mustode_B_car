import 'package:flutter/material.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final String generatedOtp;

  OtpVerificationPage({
    required this.email,
    required this.generatedOtp,
  });

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isVerifying = false;

  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isVerifying = true;
      });

      // ตรวจสอบว่า OTP ที่ผู้ใช้กรอก ตรงกับที่ส่งไปหรือไม่
      if (_otpController.text.trim() == widget.generatedOtp) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ยืนยัน OTP สำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
        // นำทางไปยังหน้าตั้งรหัสผ่านใหม่
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChangePasswordPage(email: widget.email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP ไม่ถูกต้อง'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isVerifying = false;
      });
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ยืนยัน OTP'),
        backgroundColor: Color(0xFF00377E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'กรุณากรอก OTP ที่ส่งไปที่ ${widget.email}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "รหัส OTP",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกรหัส OTP';
                    } else if (value.trim().length != 6) {
                      return 'กรุณากรอกรหัส OTP 6 หลัก';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _isVerifying
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                          backgroundColor: Color(0xFF00377E),
                        ),
                        child: Text(
                          'ยืนยัน OTP',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // TODO: Implement resend OTP functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('ฟังก์ชันส่ง OTP ใหม่ยังไม่พร้อมใช้งาน'),
                      ),
                    );
                  },
                  child: Text('ส่ง OTP ใหม่'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Stub สำหรับ ChangePasswordPage (หน้าตั้งรหัสผ่านใหม่)
class ChangePasswordPage extends StatelessWidget {
  final String email;
  ChangePasswordPage({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เปลี่ยนรหัสผ่าน'),
        backgroundColor: Color(0xFF00377E),
      ),
      body: Center(
        child: Text('หน้าตั้งรหัสผ่านใหม่สำหรับ $email'),
      ),
    );
  }
}
