import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myproject/ProfileRenter.dart';
import 'phone_auth_page.dart';
import 'signup_page.dart';
import 'home_page.dart';

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

  // ตัวแปรควบคุมการซ่อน/แสดงรหัสผ่าน
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // เมื่อช่อง Email/Password ถูกโฟกัส จะซ่อนปุ่ม “ข้าม” และข้อความเงื่อนไข
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

  // ฟังก์ชันล็อกอินด้วย Email/Password
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
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("เกิดข้อผิดพลาด"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ฟังก์ชันล็อกอินด้วย Google
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
        final DocumentReference userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
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
          await FirebaseFirestore.instance
              .collection("payments")
              .doc(user.uid)
              .set({"mypayment": 0});
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
          backgroundColor: Colors.redAccent,
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
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // ส่วน SafeArea + SingleChildScrollView
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                // เพิ่ม margin bottom เพื่อไม่ชนปุ่ม “ข้าม”
                child: Container(
                  margin: EdgeInsets.fromLTRB(30, 30, 30, 100),
                  child: Card(
                    color: Colors.white.withOpacity(0.8),
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 30,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // โลโก้
                          Image.asset(
                            "assets/icon/app_icon.png",
                            height: screenHeight * 0.15,
                          ),
                          SizedBox(height: 20),
                          // ช่อง Email
                          TextField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.7),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: 15),
                          // ช่อง Password
                          TextField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PhoneAuthCustomPage()),
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

                          // ปุ่ม Sign In (เต็มความกว้าง)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF00377E),
                                padding: EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
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

                          // "or continue with"
                          Text(
                            "or continue with",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 15),

                          // ปุ่ม Google (เต็มความกว้าง)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _signInWithGoogle,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side:
                                      BorderSide(color: Colors.grey.shade300),
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
                                      color: Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 30),

                          // Sign up link
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
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
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
                    UserCredential guestUser =
                        await FirebaseAuth.instance.signInAnonymously();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfileRenter()),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Guest Sign-In error: ${e.toString()}"),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  "ข้าม",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),

          // ข้อความเงื่อนไขการใช้งาน
          Visibility(
            visible: _isSkipButtonVisible,
            child: Positioned(
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
          ),
        ],
      ),
    );
  }
}
