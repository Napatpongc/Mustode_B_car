import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ดึงขนาดหน้าจอจาก MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight,
              decoration: BoxDecoration(color: Color(0xFFFFF6E3)),
              child: Stack(
                children: [
                  // พื้นหลัง
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: screenWidth,
                      height: screenHeight ,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/image/background.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // ปุ่มย้อนกลับ และปิด
                  Positioned(
                    top: screenHeight * 0.05,
                    left: screenWidth * 0.05,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, size: 30, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    top: screenHeight * 0.05,
                    right: screenWidth * 0.05,
                    child: IconButton(
                      icon: Icon(Icons.close, size: 30, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  // ฟอร์มสมัครสมาชิก
                  Positioned(
                    left: screenWidth * 0.05,
                    top: screenHeight * 0.1,
                    child: Container(
                      width: screenWidth * 0.9,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(31),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: screenWidth * 0.07,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          _buildTextField("Username"),
                          SizedBox(height: screenHeight * 0.015),
                          _buildTextField("Email"),
                          SizedBox(height: screenHeight * 0.015),
                          _buildTextField("Confirm Email"),
                          SizedBox(height: screenHeight * 0.015),
                          _buildTextField("Password", obscureText: true),
                          SizedBox(height: screenHeight * 0.015),
                          _buildTextField("Confirm Password", obscureText: true),
                          SizedBox(height: screenHeight * 0.015),
                          _buildTextField("Phone Number"),
                          SizedBox(height: screenHeight * 0.015),
                          _buildTextField("Address"),
                          SizedBox(height: screenHeight * 0.03),
                          Center(child: _buildSignUpButton(context)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget สำหรับสร้าง TextField
  Widget _buildTextField(String label, {bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  // ปุ่มสมัครสมาชิก
  Widget _buildSignUpButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("สมัครสมาชิกสำเร็จ!")),
        );
        Navigator.pop(context); // กลับไปหน้า Login
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF00377E),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        "Sign Up",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
