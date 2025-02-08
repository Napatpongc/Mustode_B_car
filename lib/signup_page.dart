import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String? selectedFilePath;
  
  // สร้าง TextEditingController สำหรับทุกฟิลด์
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _confirmEmailController = TextEditingController();
  TextEditingController _provinceController = TextEditingController();
  TextEditingController _districtController = TextEditingController();
  TextEditingController _subDistrictController = TextEditingController();
  TextEditingController _postalCodeController = TextEditingController();
  TextEditingController _additionalAddressController = TextEditingController();

  // ฟังก์ชันตรวจสอบว่าได้กรอกข้อมูลครบหรือไม่
  bool _validateForm() {
    if (_usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _confirmEmailController.text.isEmpty ||
        _provinceController.text.isEmpty ||
        _districtController.text.isEmpty ||
        _subDistrictController.text.isEmpty ||
        _postalCodeController.text.isEmpty ||
        _additionalAddressController.text.isEmpty) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
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
          SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(top: screenHeight * 0.1),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Container(
                    width: screenWidth * 0.9,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back,
                                  size: 30, color: Colors.black),
                              onPressed: () => Navigator.pop(context),
                            ),
                            IconButton(
                              icon: Icon(Icons.close,
                                  size: 30, color: Colors.black),
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
                        SizedBox(height: screenHeight * 0.02),
                        // ส่วนของฟอร์ม
                        Text("Username"),
                        SizedBox(height: screenHeight * 0.01),
                        _buildTextField("Username", controller: _usernameController),
                        SizedBox(height: screenHeight * 0.02),
                        Text("Password"),
                        SizedBox(height: screenHeight * 0.01),
                        _buildTextField("Password", controller: _passwordController, obscureText: true),
                        SizedBox(height: screenHeight * 0.02),
                        Text("Confirm password"),
                        SizedBox(height: screenHeight * 0.01),
                        _buildTextField("Confirm password", controller: _confirmPasswordController, obscureText: true),
                        SizedBox(height: screenHeight * 0.02),
                        _buildUploadDrivingLicenseField(),
                        SizedBox(height: screenHeight * 0.02),
                        Text("เบอร์โทร"),
                        SizedBox(height: screenHeight * 0.01),
                        _buildTextField("เบอร์โทร", controller: _phoneController),
                        SizedBox(height: screenHeight * 0.02),
                        Text("Email"),
                        SizedBox(height: screenHeight * 0.01),
                        _buildTextField("Email", controller: _emailController),
                        SizedBox(height: screenHeight * 0.02),
                        Text("Confirm Email"),
                        SizedBox(height: screenHeight * 0.01),
                        _buildTextField("Confirm Email", controller: _confirmEmailController),
                        SizedBox(height: screenHeight * 0.02),
                        // ส่วนของที่อยู่
                        Text(
                          "ที่อยู่ผู้สมัคร",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                        Text("จังหวัด"),
                        SizedBox(height: screenHeight * 0.01),
                        _buildTextField("จังหวัด", controller: _provinceController),
                        SizedBox(height: screenHeight * 0.02),
                        Text("อำเภอ"),
                        SizedBox(height: screenHeight * 0.01),
                        _buildTextField("อำเภอ", controller: _districtController),
                        SizedBox(height: screenHeight * 0.02),
                        Text("ตำบล"),
                        SizedBox(height: screenHeight * 0.01),
                        _buildTextField("ตำบล", controller: _subDistrictController),
                        SizedBox(height: screenHeight * 0.02),
                        Text("เลขไปรษณีย์"),
                        SizedBox(height: screenHeight * 0.01),
                        _buildTextField("เลขไปรษณีย์", controller: _postalCodeController),
                        SizedBox(height: screenHeight * 0.02),
                        Text("รายละเอียดที่อยู่เพิ่มเติม"),
                        SizedBox(height: screenHeight * 0.01),
                        _buildTextField("รายละเอียดที่อยู่เพิ่มเติม", controller: _additionalAddressController, maxLines: 3),
                        SizedBox(height: screenHeight * 0.03),
                        Center(child: _buildSignUpButton(context)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, {bool obscureText = false, int? maxLines, TextEditingController? controller}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildUploadDrivingLicenseField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "อัปโหลดรูปใบขับขี่",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 5),
        GestureDetector(
          onTap: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.image,
            );

            if (result != null) {
              setState(() {
                selectedFilePath = result.files.single.path!;
              });
            }
          },
          child: Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                "เลือกไฟล์",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ),
        ),
        if (selectedFilePath != null) ...[
          SizedBox(height: 10),
          Image.file(File(selectedFilePath!), height: 100),
        ],
      ],
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_validateForm()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("สมัครสมาชิกสำเร็จ!")),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("โปรดกรอกข้อความให้ครบทุกช่อง")),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF00377E),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        "ยืนยัน",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
