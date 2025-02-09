import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String? selectedFilePath;
  
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

  bool _validateForm() {
    return _usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _confirmEmailController.text.isNotEmpty &&
        _provinceController.text.isNotEmpty &&
        _districtController.text.isNotEmpty &&
        _subDistrictController.text.isNotEmpty &&
        _postalCodeController.text.isNotEmpty &&
        _additionalAddressController.text.isNotEmpty;
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
                         IconButton(
                              icon: Icon(Icons.arrow_back,
                                  size: 30, color: Colors.black),
                              onPressed: () => Navigator.pop(context),
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
                        SizedBox(height: 20),
                        _buildTextField("Username", controller: _usernameController),
                        _buildTextField("Password", controller: _passwordController, obscureText: true),
                        _buildTextField("Confirm password", controller: _confirmPasswordController, obscureText: true),
                        _buildUploadDrivingLicenseField(),
                        _buildTextField("เบอร์โทร", controller: _phoneController, keyboardType: TextInputType.phone, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                        _buildTextField("Email", controller: _emailController, keyboardType: TextInputType.emailAddress),
                        _buildTextField("Confirm Email", controller: _confirmEmailController, keyboardType: TextInputType.emailAddress),
                        _buildTextField("จังหวัด", controller: _provinceController),
                        _buildTextField("อำเภอ", controller: _districtController),
                        _buildTextField("ตำบล", controller: _subDistrictController),
                        _buildTextField("เลขไปรษณีย์", controller: _postalCodeController, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                        _buildTextField("รายละเอียดที่อยู่เพิ่มเติม", controller: _additionalAddressController, maxLines: 3),
                        SizedBox(height: 20),
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

  Widget _buildTextField(String label, {bool obscureText = false, int? maxLines, TextEditingController? controller, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        maxLines: maxLines ?? 1,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildUploadDrivingLicenseField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("อัปโหลดรูปใบขับขี่", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        GestureDetector(
          onTap: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
            if (result != null) {
              setState(() { selectedFilePath = result.files.single.path!; });
            }
          },
          child: Container(
            height: 50,
            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
            child: Center(child: Text("เลือกไฟล์", style: TextStyle(fontSize: 14, color: Colors.blueAccent))),
          ),
        ),
        if (selectedFilePath != null) ...[SizedBox(height: 10), Image.file(File(selectedFilePath!), height: 100)],
      ],
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_validateForm()) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("สมัครสมาชิกสำเร็จ!")));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("โปรดกรอกข้อความให้ครบทุกช่อง")));
        }
      },
      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00377E), padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      child: Text("ยืนยัน", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
