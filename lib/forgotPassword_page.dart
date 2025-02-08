import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false; // สำหรับแสดงสถานะการส่งคำขอรีเซ็ตรหัสผ่าน

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
        backgroundColor: Color(0xFF00377E),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ข้อความแนะนำ
                Text(
                  'กรุณากรอกอีเมลของคุณเพื่อรีเซ็ตรหัสผ่าน',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                
                // ช่องกรอกอีเมล
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
                    // ตรวจสอบรูปแบบอีเมล
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกอีเมล';
                    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                      return 'อีเมลไม่ถูกต้อง';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // ปุ่มส่งคำขอรีเซ็ตรหัสผ่าน
                _isProcessing
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _resetPassword,
                        style: ElevatedButton.styleFrom(
                          shadowColor: Color(0xFF00377E),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          'Reset Password',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                SizedBox(height: 20),

                // ลิงก์กลับไปที่หน้าล็อกอิน
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // กลับไปหน้าล็อกอิน
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
    );
  }

  // ฟังก์ชันที่ใช้ในการรีเซ็ตรหัสผ่าน
  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true; // แสดง progress indicator
      });

      String email = _emailController.text;
      // แสดงข้อความบอกว่าอีเมลจะถูกส่งให้ผู้ใช้เพื่อรีเซ็ตรหัสผ่าน
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ส่งคำขอรีเซ็ตรหัสผ่านไปที่อีเมล $email แล้ว'),
          backgroundColor: Colors.green,
        ),
      );

      // เพิ่มการทำงานเพิ่มเติม เช่น ส่งคำขอไปยังเซิร์ฟเวอร์ที่สามารถรีเซ็ตรหัสผ่านให้ผู้ใช้

      // จำลองการรอคอยจากเซิร์ฟเวอร์
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isProcessing = false; // ซ่อน progress indicator
        });
      });
    }
  }
}
