import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:myproject/RegisterData.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formkey = GlobalKey<FormState>();
  // ใช้งาน RegisterData แบบ singleton
  RegisterData registerData = RegisterData();

  String? selectedFilePath;
  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _subDistrictController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _additionalAddressController = TextEditingController();

  Widget _buildTextField(String label,
      {TextEditingController? controller,
      bool obscureText = false,
      TextInputType? keyboardType,
      List<TextInputFormatter>? inputFormatters,
      int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'กรุณากรอก $label';
          }
          return null;
        },
      ),
    );
  }

  // ฟังก์ชันสำหรับบันทึกข้อมูลลงใน RegisterData singleton
  void _saveFormData() {
    registerData.username = _usernameController.text;
    registerData.password = _passwordController.text;
    registerData.confirmPassword = _confirmPasswordController.text;
    registerData.phone = _phoneController.text;
    registerData.email = _emailController.text;
    registerData.confirmEmail = _confirmEmailController.text;
    registerData.province = _provinceController.text;
    registerData.district = _districtController.text;
    registerData.subdistrict = _subDistrictController.text;
    registerData.postCode = _postalCodeController.text;
    registerData.moreInfo = _additionalAddressController.text;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return FutureBuilder(
      future: firebase,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text("Error")),
            body: Center(child: Text("${snapshot.error}")),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Widget buildSignUpButton(BuildContext context) {
            return ElevatedButton(
              onPressed: () async {
                if (formkey.currentState!.validate()) {
                  // บันทึกข้อมูลจากฟอร์มลงใน RegisterData singleton
                  _saveFormData();

                  try {
                    // สมัครสมาชิกด้วยอีเมลและรหัสผ่าน
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );

                    // ล้างข้อมูลในฟอร์มหลังสมัครเสร็จ
                    formkey.currentState!.reset();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("สมัครสมาชิกสำเร็จ!")),
                    );

                    // กลับไปหน้าก่อนหน้า
                    Navigator.pop(context);
                  } on FirebaseAuthException catch (e) {
                    String errorMessage = "เกิดข้อผิดพลาด";

                    if (e.code == 'email-already-in-use') {
                      errorMessage = "อีเมลนี้ถูกใช้ไปแล้ว";
                    } else if (e.code == 'weak-password') {
                      errorMessage = "รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร";
                    } else if (e.code == 'invalid-email') {
                      errorMessage = "อีเมลไม่ถูกต้อง";
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorMessage)),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("โปรดกรอกข้อมูลให้ครบถ้วน")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00377E),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text(
                "ยืนยัน",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          }

          return Scaffold(
            body: Stack(
              children: [
                Container(
                  width: screenWidth,
                  height: screenHeight,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/image/background.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.only(top: screenHeight * 0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                      key: formkey,
                      child: Column(
                        children: [
                          Container(
                            width: screenWidth * 0.9,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.close, size: 30, color: Colors.black),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                                Center(
                                  child: Text(
                                    "สร้างบัญชี",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.07,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildTextField("Username", controller: _usernameController),
                                _buildTextField("Password", controller: _passwordController, obscureText: true),
                                _buildTextField("Confirm password", controller: _confirmPasswordController, obscureText: true),
                                _buildTextField("เบอร์โทร", controller: _phoneController, keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                                _buildTextField("Email", controller: _emailController, keyboardType: TextInputType.emailAddress),
                                _buildTextField("Confirm Email", controller: _confirmEmailController, keyboardType: TextInputType.emailAddress),
                                _buildTextField("จังหวัด", controller: _provinceController),
                                _buildTextField("อำเภอ", controller: _districtController),
                                _buildTextField("ตำบล", controller: _subDistrictController),
                                _buildTextField("เลขไปรษณีย์", controller: _postalCodeController, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                                _buildTextField("รายละเอียดที่อยู่เพิ่มเติม", controller: _additionalAddressController, maxLines: 3),
                                const SizedBox(height: 20),
                                Center(child: buildSignUpButton(context)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}