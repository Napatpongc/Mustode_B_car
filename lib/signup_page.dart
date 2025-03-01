import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final Future<FirebaseApp> _firebaseInitialization = Firebase.initializeApp();

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Widget _buildTextField(String label, TextEditingController ctrl,
      {bool obscure = false, TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (val) =>
            (val == null || val.trim().isEmpty) ? 'กรุณากรอก $label' : null,
      ),
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("โปรดกรอกข้อมูลให้ครบถ้วน")));
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password กับ Confirm Password ไม่ตรงกัน")));
      return;
    }
    try {
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text);
      if (cred.user != null) {
        // สร้างเอกสารใน collection "users"
        await FirebaseFirestore.instance
            .collection("users")
            .doc(cred.user!.uid)
            .set({
          "username": _usernameController.text.trim(),
          "email": _emailController.text.trim(),
          "phone": null,
          "address": {
            "province": null,
            "district": null,
            "subdistrict": null,
            "postalCode": null,
            "moreinfo": null
          },
          "image": {"imagesidcard": [], "imagesidcar": []},
          "rentedCars": [],
          "ownedCars": [],
        });
        // เพิ่มเอกสารใน collection "payments" โดยใช้ uid ของผู้ใช้เป็น payment_id
        await FirebaseFirestore.instance
            .collection("payments")
            .doc(cred.user!.uid)
            .set({
          "mypayment": 0, // กำหนดค่าเริ่มต้นของ mypayment เป็น 0
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("สมัครสมาชิกสำเร็จ!")));
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String msg = "เกิดข้อผิดพลาด";
      if (e.code == 'email-already-in-use') {
        msg = "อีเมลนี้ถูกใช้ไปแล้ว";
      } else if (e.code == 'weak-password')
        msg = "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร";
      else if (e.code == 'invalid-email') msg = "อีเมลไม่ถูกต้อง";
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
              appBar: AppBar(title: Text("Error")),
              body: Center(child: Text("${snapshot.error}")));
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                  child: Image.asset("assets/image/background.png",
                      fit: BoxFit.cover)),
              Center(
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                    width: screenWidth * 0.9,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                    icon: Icon(Icons.close,
                                        size: 30, color: Colors.black),
                                    onPressed: () => Navigator.pop(context)),
                              ]),
                          Center(
                              child: Text("สร้างบัญชี",
                                  style: TextStyle(
                                      fontSize: screenWidth * 0.07,
                                      fontWeight: FontWeight.bold))),
                          SizedBox(height: 20),
                          _buildTextField("Username", _usernameController),
                          _buildTextField("Gmail", _emailController,
                              keyboard: TextInputType.emailAddress),
                          _buildTextField("Password", _passwordController,
                              obscure: true),
                          _buildTextField(
                              "Confirm Password", _confirmPasswordController,
                              obscure: true),
                          SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: _signUp,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF00377E),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20))),
                              child: Text("ยืนยัน",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
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
