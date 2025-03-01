import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'utils.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final Future<FirebaseApp> _firebaseInitialization = Firebase.initializeApp();
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(); 
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ฟังก์ชันสร้าง TextField พร้อมไอคอน
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.black54)
              : null, // เพิ่มไอคอนซ้าย
          labelText: label,
          labelStyle: TextStyle(color: Colors.black87),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.7),
        ),
        validator: (val) =>
            (val == null || val.trim().isEmpty) ? 'กรุณากรอก $label' : null,
      ),
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("โปรดกรอกข้อมูลให้ครบถ้วน")),
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password กับ Confirm Password ไม่ตรงกัน")),
      );
      return;
    }
    try {
      // สร้างผู้ใช้งานด้วย Firebase Auth
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (cred.user != null) {
        // แปลงเบอร์โทรเป็น E.164
        String formattedPhone = formatThaiPhone(_phoneController.text.trim());

        // สร้างเอกสารใน collection "users"
        await FirebaseFirestore.instance
            .collection("users")
            .doc(cred.user!.uid)
            .set({
          "username": _usernameController.text.trim(),
          "email": _emailController.text.trim(),
          "password": _passwordController.text,
          "phone": formattedPhone,
          "address": {
            "province": null,
            "district": null,
            "subdistrict": null,
            "postalCode": null,
            "moreinfo": null,
          },
          "image": {},
          "rentedCars": [],
          "ownedCars": [],
        });

        // เพิ่มเอกสารใน collection "payments"
        await FirebaseFirestore.instance
            .collection("payments")
            .doc(cred.user!.uid)
            .set({"mypayment": 0});

        // สร้างเอกสารใน collection "otp_codes"
        await FirebaseFirestore.instance
            .collection("otp_codes")
            .doc(formattedPhone)
            .set({
          'otp': "",
          'createdAt': FieldValue.serverTimestamp(),
          'expireAt': null,
          'used': false,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("สมัครสมาชิกสำเร็จ!")),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String msg = "เกิดข้อผิดพลาด";
      if (e.code == 'email-already-in-use') {
        msg = "อีเมลนี้ถูกใช้ไปแล้ว";
      } else if (e.code == 'weak-password') {
        msg = "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร";
      } else if (e.code == 'invalid-email') {
        msg = "อีเมลไม่ถูกต้อง";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: _firebaseInitialization,
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: Center(child: Text("${snapshot.error}")),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          body: Stack(
            children: [
              // พื้นหลังแบบเต็มหน้าจอ
              Positioned.fill(
                child: Image.asset(
                  "assets/image/background.png",
                  fit: BoxFit.cover,
                ),
              ),
              // Center + SingleChildScrollView
              Center(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 40,
                    ),
                    width: screenWidth * 0.9,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ปุ่มปิด (X) ที่มุมขวาบน
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 30,
                                  color: Colors.black,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),

                          // หัวข้อ "สร้างบัญชี"
                          Center(
                            child: Text(
                              "สร้างบัญชี",
                              style: TextStyle(
                                fontSize: screenWidth * 0.07,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ช่องกรอก Username
                          _buildTextField(
                            label: "Username",
                            controller: _usernameController,
                            icon: Icons.person,
                          ),

                          // ช่องกรอก Email
                          _buildTextField(
                            label: "Gmail",
                            controller: _emailController,
                            keyboard: TextInputType.emailAddress,
                            icon: Icons.email,
                          ),

                          // ช่องกรอก Phone
                          _buildTextField(
                            label: "Phone",
                            controller: _phoneController,
                            keyboard: TextInputType.phone,
                            icon: Icons.phone,
                          ),

                          // ช่องกรอก Password
                          _buildTextField(
                            label: "Password",
                            controller: _passwordController,
                            obscure: true,
                            icon: Icons.lock,
                          ),

                          // ช่องกรอก Confirm Password
                          _buildTextField(
                            label: "Confirm Password",
                            controller: _confirmPasswordController,
                            obscure: true,
                            icon: Icons.lock_outline,
                          ),

                          const SizedBox(height: 20),

                          // ปุ่มยืนยัน (เต็มความกว้าง)
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _signUp,
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
