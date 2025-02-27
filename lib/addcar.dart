import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'mycar.dart';

class AddCar extends StatefulWidget {
  const AddCar({Key? key}) : super(key: key);
  @override
  State<AddCar> createState() => _AddCarState();
}

class _AddCarState extends State<AddCar> {
  int _currentStep = 1;
  final _formKeyStep1 = GlobalKey<FormState>();

  // Controllers สำหรับข้อมูลรถ (Step 1)
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _doorCtrl = TextEditingController();
  final _seatCtrl = TextEditingController();
  final _gearCtrl = TextEditingController();
  final _engineCtrl = TextEditingController();
  final _baggageCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  // ตัวแปรเก็บ URL รูปจาก Imgur
  String? _carImage;
  String? _vehicleRegImage;
  String? _motorVehicleImage;
  String? _checkVehicleImage;

  // ตัวแปรเก็บ deletehash ของแต่ละรูป
  String? _deletehashCar;
  String? _deletehashVehicleReg;
  String? _deletehashMotorVehicle;
  String? _deletehashCheckVehicle;

  // Imgur Client ID สำหรับ Anonymous Upload
  final String _imgurClientId = 'ed6895b5f1bf3d7';

  // ฟังก์ชันอัปโหลดรูปไป Imgur แล้วส่งกลับ Map ที่มี "link" และ "deletehash"
  Future<Map<String, String>?> _uploadToImgur(File imageFile) async {
    final uri = Uri.parse('https://api.imgur.com/3/image');
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Client-ID $_imgurClientId'
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    var response = await request.send();
    if (response.statusCode == 200) {
      var res = await response.stream.bytesToString();
      var data = json.decode(res)['data'];
      return {
        "link": data['link'],
        "deletehash": data['deletehash'],
      };
    }
    return null;
  }

  // เลือกรูปจากเครื่องและอัปโหลด (ระบุประเภท: car, vehicle_registration, motor_vehicle, check_vehicle)
  Future<void> _pickAndUploadImage(String imageType) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    File imageFile = File(pickedFile.path);
    var result = await _uploadToImgur(imageFile);
    if (result != null) {
      setState(() {
        if (imageType == "car") {
          _carImage = result["link"];
          _deletehashCar = result["deletehash"];
        } else if (imageType == "vehicle_registration") {
          _vehicleRegImage = result["link"];
          _deletehashVehicleReg = result["deletehash"];
        } else if (imageType == "motor_vehicle") {
          _motorVehicleImage = result["link"];
          _deletehashMotorVehicle = result["deletehash"];
        } else if (imageType == "check_vehicle") {
          _checkVehicleImage = result["link"];
          _deletehashCheckVehicle = result["deletehash"];
        }
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("อัปโหลดรูป $imageType สำเร็จ!")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("อัปโหลดรูป $imageType ไม่สำเร็จ")));
    }
  }

  // สร้าง TextField โดยมี title (ด้านบน) และ hint ในช่อง
  Widget _buildTextField({
    required String title,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }

  // สร้างปุ่มสีขาว ตัวอักษรสีดำ
  Widget _buildWhiteButton(String text, IconData icon, VoidCallback onTap, {bool isPrimary = true}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.black),
      label: Text(text, style: const TextStyle(color: Colors.black)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: isPrimary ? Colors.black : Colors.grey),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  // สร้างส่วน Label + ปุ่มเลือกรูป พร้อม preview รูป (ถ้ามี)
  Widget _buildLabelWithButton(String label, String imageType) {
    String? preview;
    if (imageType == "car") preview = _carImage;
    else if (imageType == "vehicle_registration") preview = _vehicleRegImage;
    else if (imageType == "motor_vehicle") preview = _motorVehicleImage;
    else if (imageType == "check_vehicle") preview = _checkVehicleImage;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          Row(
            children: [
              _buildWhiteButton("เลือกรูป", Icons.image, () => _pickAndUploadImage(imageType)),
              const SizedBox(width: 10),
              if (preview != null)
                Image.network(preview, width: 60, height: 60, fit: BoxFit.cover),
            ],
          ),
        ],
      ),
    );
  }

  // Header แสดงขั้นตอน 1/2 พร้อมขีดเชื่อม
  Widget _buildStepHeader(int current) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepCircle(1, "ข้อมูลรถ", current == 1),
        const SizedBox(width: 10),
        Expanded(
          child: Divider(color: Colors.blue, thickness: 2, indent: 5, endIndent: 5),
        ),
        const SizedBox(width: 10),
        _stepCircle(2, "ส่งเอกสาร", current == 2),
      ],
    );
  }

  // วงกลมพร้อมข้อความสำหรับขั้นตอน
  Widget _stepCircle(int number, String label, bool active) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: active ? Colors.blue : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(child: Text("$number", style: TextStyle(color: active ? Colors.white : Colors.black))),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // Step control functions
  void _nextStep() {
    if (_currentStep == 1 && (_formKeyStep1.currentState?.validate() ?? false))
      setState(() => _currentStep = 2);
  }
  void _previousStep() {
    if (_currentStep == 2) setState(() => _currentStep = 1);
  }

  // บันทึกข้อมูลลง Firestore พร้อมเพิ่ม field availability และ statuscar
  Future<void> _submitCarData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("ไม่พบผู้ใช้ที่ล็อกอิน")));
      return;
    }
    // กำหนดวันที่บันทึกและคำนวณวันที่หลังจาก 3 เดือน
    DateTime now = DateTime.now();
    DateTime availableTo = now.add(const Duration(days: 90));
    final carData = {
      "ownerId": user.uid,
      "brand": _brandCtrl.text.trim(),
      "model": _modelCtrl.text.trim(),
      "detail": {
        "door": int.tryParse(_doorCtrl.text) ?? 0,
        "seat": int.tryParse(_seatCtrl.text) ?? 0,
        "gear": _gearCtrl.text.trim(),
        "engine": _engineCtrl.text.trim(),
        "baggage": int.tryParse(_baggageCtrl.text) ?? 0,
      },
      "price": double.tryParse(_priceCtrl.text) ?? 0.0,
      "image": {
        "car": _carImage ?? "",
        "deletehash_car": _deletehashCar ?? "",
        "vehicle_registration": _vehicleRegImage ?? "",
        "deletehash_vehicle_registration": _deletehashVehicleReg ?? "",
        "motor_vehicle": _motorVehicleImage ?? "",
        "deletehash_motor_vehicle": _deletehashMotorVehicle ?? "",
        "check_vehicle": _checkVehicleImage ?? "",
        "deletehash_check_vehicle": _deletehashCheckVehicle ?? "",
      },
      "location": {"latitude": null, "longitude": null},
      "availability": {
        "availableFrom": Timestamp.fromDate(now),
        "availableTo": Timestamp.fromDate(availableTo)
      },
      "statuscar": "yes"
    };
    try {
      await FirebaseFirestore.instance.collection("cars").add(carData);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("บันทึกข้อมูลเรียบร้อย!")));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyCar()));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    }
  }

  void _goBackToMyCar() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyCar()));
  }

  @override
  Widget build(BuildContext context) {
    return _currentStep == 1 ? _buildStep1() : _buildStep2();
  }

  // STEP 1: ข้อมูลรถ
  Widget _buildStep1() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("เพิ่มรถ"),
        backgroundColor: const Color(0xFF00377E),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: _goBackToMyCar),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKeyStep1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepHeader(1),
                const SizedBox(height: 20),
                _buildLabelWithButton("รูปภาพรถ", "car"),
                _buildTextField(
                  title: "ชื่อยี่ห้อรถ", hint: "Name", controller: _brandCtrl,
                  validator: (val) => (val == null || val.trim().isEmpty) ? "กรุณากรอกชื่อยี่ห้อรถ" : null,
                ),
                _buildTextField(
                  title: "ชื่อรุ่นรถ", hint: "Name", controller: _modelCtrl,
                  validator: (val) => (val == null || val.trim().isEmpty) ? "กรุณากรอกชื่อรุ่นรถ" : null,
                ),
                _buildTextField(title: "จำนวนประตู", hint: "Number", controller: _doorCtrl, keyboardType: TextInputType.number),
                _buildTextField(title: "จำนวนที่นั่ง", hint: "Number", controller: _seatCtrl, keyboardType: TextInputType.number),
                _buildTextField(title: "ระบบเกียร์", hint: "Gear", controller: _gearCtrl),
                _buildTextField(title: "ระบบเครื่องยนต์", hint: "Engine", controller: _engineCtrl),
                _buildTextField(title: "จำนวนสัมภาระ", hint: "Number", controller: _baggageCtrl, keyboardType: TextInputType.number),
                _buildTextField(title: "ราคาเช่าต่อวัน", hint: "Price", controller: _priceCtrl, keyboardType: TextInputType.number),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildWhiteButton("ถัดไป", Icons.arrow_forward, _nextStep),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // STEP 2: ส่งเอกสาร
  Widget _buildStep2() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("เพิ่มรถ"),
        backgroundColor: const Color(0xFF00377E),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: _goBackToMyCar),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepHeader(2),
              const SizedBox(height: 20),
              _buildLabelWithButton("สำเนาทะเบียนรถ", "vehicle_registration"),
              _buildLabelWithButton("พ.ร.บ. รถยนต์", "motor_vehicle"),
              _buildLabelWithButton("สัญญาตรวจเช็คสภาพรถ", "check_vehicle"),
              const Text("เงื่อนไขการส่งเอกสาร:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text("- กรุณาอัปโหลดเอกสารที่ถูกต้อง\n- เอกสารต้องยังไม่หมดอายุ\n- ฯลฯ"),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildWhiteButton("ย้อนกลับ", Icons.arrow_back, _previousStep, isPrimary: false),
                  _buildWhiteButton("ยืนยัน", Icons.check, _submitCarData),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
