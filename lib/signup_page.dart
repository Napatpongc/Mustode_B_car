import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myproject/RegisterData.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final formkey = GlobalKey<FormState>();

  RegisterData registerData = RegisterData();
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

  Widget _buildTextField(String label, {TextEditingController? controller, bool obscureText = false, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters, int maxLines = 1}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8),
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
              child: Form(
                key: formkey,
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
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.close, size: 30, color: Colors.black),
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
                          SizedBox(height: 20),
                          _buildTextField("Username", controller: _usernameController),
                          _buildTextField("Password", controller: _passwordController, obscureText: true),
                          _buildTextField("Confirm password", controller: _confirmPasswordController, obscureText: true),
                          //_buildUploadDrivingLicenseField(),
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
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (formkey.currentState!.validate()) {
          registerData.username = _usernameController.text;
          registerData.password = _passwordController.text;
          registerData.confirmPassword = _confirmPasswordController.text;
          registerData.phone = _phoneController.text;
          registerData.email = _emailController.text;
          registerData.confirmEmail = _confirmEmailController.text;
          registerData.province = _provinceController.text;
          registerData.district = _districtController.text;
          registerData.moreInfo = _additionalAddressController.text;

          print("===== ข้อมูลที่บันทึก =====");
          print("Username: ${registerData.username}");
          print("Password: ${registerData.password}");
          print("Confirm Password: ${registerData.confirmPassword}");
          print("Phone: ${registerData.phone}");
          print("Email: ${registerData.email}");
          print("Confirm Email: ${registerData.confirmEmail}");
          print("Province: ${registerData.province}");
          print("District: ${registerData.district}");
          print("More Info: ${registerData.moreInfo}");
          print("========================");

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("สมัครสมาชิกสำเร็จ!")));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("โปรดกรอกข้อความให้ครบทุกช่อง")));
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF00377E),
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
      ),
      child: Text("ยืนยัน", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
