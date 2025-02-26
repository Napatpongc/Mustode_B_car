import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myproject/ProfileRenter.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'forgotPassword_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FocusNode _emailFocusNode = FocusNode();
  FocusNode _passwordFocusNode = FocusNode();
  bool _isSkipButtonVisible = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _emailFocusNode.removeListener(_onFocusChange);
    _passwordFocusNode.removeListener(_onFocusChange);
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isSkipButtonVisible =
          !(_emailFocusNode.hasFocus || _passwordFocusNode.hasFocus);
    });
  }

  // ฟังก์ชันสำหรับล็อกอินด้วย Email/Password
  void _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileRenter()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "เกิดข้อผิดพลาด";
      if (e.code == 'user-not-found') {
        errorMessage = "ไม่พบผู้ใช้งาน";
      } else if (e.code == 'wrong-password') {
        errorMessage = "รหัสผ่านไม่ถูกต้อง";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("เกิดข้อผิดพลาด"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ฟังก์ชันสำหรับล็อกอินด้วย Google
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // ผู้ใช้ยกเลิกการล็อกอิน

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user != null) {
        // ตรวจสอบว่าใน Firestore มี document สำหรับผู้ใช้นี้หรือยัง
        final DocumentReference userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          // ถ้ายังไม่มี ให้สร้าง document ด้วยข้อมูลเริ่มต้น
          await userDoc.set({
            "username": googleUser.displayName ?? "",
            "email": googleUser.email,
            "phone": null,
            "address": {
              "province": null,
              "district": null,
              "subdistrict": null,
              "postalCode": null,
              "moreinfo": null,
            },
            "image": {
              "imagesidcard": [],
              "imagesidcar": [],
            },
            "rentedCars": [],
            "ownedCars": [],
          });
          // สร้างเอกสารใน collection "payments" โดยใช้ uid ของผู้ใช้เป็น payment_id
          await FirebaseFirestore.instance.collection("payments").doc(user.uid).set({
            "mypayment": 0, // กำหนดค่าเริ่มต้นของ mypayment เป็น 0
          });
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileRenter()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Google Sign-In error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // ภาพพื้นหลัง
          Container(
            width: screenWidth,
            height: screenHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/image/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // กล่องข้อมูลล็อกอินตรงกลาง (ปรับขนาดกล่องให้รองรับเนื้อหาเพิ่มเติม)
          Center(
            child: Container(
              width: screenWidth * 0.85,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // โลโก้ด้านบน
                    Image.asset(
                      "assets/icon/app_icon.png",
                      height: screenHeight * 0.15,
                    ),
                    SizedBox(height: 20),
                    // ช่องกรอก Email
                    TextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 10),
                    // ช่องกรอก Password
                    TextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    // ลิงก์ Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage()),
                          );
                        },
                        child: Text(
                          "Forgot password?",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // ปุ่ม Sign In
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00377E),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Sign in",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    // ข้อความ "or continue with"
                    Text(
                      "or continue with",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 15),
                    // ปุ่ม Login ด้วย Google
                    ElevatedButton(
                      onPressed: _signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/icon/google_logo.png",
                            height: 24,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Login with Google",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    // ลิงก์ Sign Up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don’t have an account? "),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpPage()),
                            );
                          },
                          child: Text(
                            "Sign up",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ปุ่ม "ข้าม" - Guest Sign-In
          Visibility(
            visible: _isSkipButtonVisible,
            child: Positioned(
              bottom: 50,
              right: 20,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    // ล็อกอินแบบ Anonymous
                    UserCredential guestUser =
                        await FirebaseAuth.instance.signInAnonymously();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileRenter()),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Guest Sign-In error: ${e.toString()}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  "ข้าม",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          // ข้อความเงื่อนไขการใช้งาน
          Positioned(
            bottom: 10,
            left: 20,
            right: 20,
            child: Text(
              "ฉันยอมรับข้อกำหนดการใช้งาน และ นโยบายความเป็นส่วนตัวของมัสโตด บี คาร์",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.indigoAccent,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
