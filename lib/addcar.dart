import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'mycar.dart';

class AddCar extends StatefulWidget {
  const AddCar({Key? key}) : super(key: key);

  @override
  State<AddCar> createState() => _AddCarState();
}

class _AddCarState extends State<AddCar> {
  int _currentStep = 1;
  final _formKeyStep1 = GlobalKey<FormState>();

  // Step 1
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _doorCtrl = TextEditingController();
  final _seatCtrl = TextEditingController();
  final _gearCtrl = TextEditingController();
  final _engineCtrl = TextEditingController();
  final _baggageCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  // Step 2
  String? _carImage, _vehicleRegImage, _motorVehicleImage, _checkVehicleImage;

  // ===================== UI Helper =====================
  // สร้าง TextField สีขาว + โค้งมน
  // แยก "title" สำหรับข้อความข้างบน และ "hint" เป็น placeholder ใน TextField
  Widget _buildTextField({
    required String title,        // ชื่อฟิลด์ภาษาไทย
    required String hint,         // placeholder (hint) ใน TextField
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)), // ข้อความไทยอยู่ข้างบน
          const SizedBox(height: 5),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint, // placeholder
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20), // โค้งมนมากขึ้น
              ),
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
        backgroundColor: Colors.white, // พื้นหลังปุ่มเป็นสีขาว
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: isPrimary ? Colors.black : Colors.grey),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  // ข้อความ + ปุ่มเลือกรูป
  Widget _buildLabelWithButton(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          _buildWhiteButton("เลือกรูป", Icons.image, () {}),
        ],
      ),
    );
  }

  // Header แสดงขั้นตอน 1/2 + ขีดเชื่อม
  Widget _buildStepHeader(int current) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepWithLabel(stepNumber: 1, label: "ข้อมูลรถ", active: current == 1),
        const SizedBox(width: 10),
        Expanded(
          child: Divider(color: Colors.blue, thickness: 2, indent: 5, endIndent: 5),
        ),
        const SizedBox(width: 10),
        _stepWithLabel(stepNumber: 2, label: "ส่งเอกสาร", active: current == 2),
      ],
    );
  }

  Widget _stepWithLabel({required int stepNumber, required String label, required bool active}) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: active ? Colors.blue : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              "$stepNumber",
              style: TextStyle(color: active ? Colors.white : Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // ===================== Step Functions =====================
  void _nextStep() {
    if (_currentStep == 1) {
      if (_formKeyStep1.currentState?.validate() ?? false) {
        setState(() => _currentStep = 2);
      }
    }
  }

  void _previousStep() {
    if (_currentStep == 2) setState(() => _currentStep = 1);
  }

  Future<void> _submitCarData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ไม่พบผู้ใช้ที่ล็อกอิน")),
        );
        return;
      }
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
          "vehicle_registration": _vehicleRegImage ?? "",
          "motor_vehicle": _motorVehicleImage ?? "",
          "check_vehicle": _checkVehicleImage ?? "",
        },
        "location": {"latitude": null, "longitude": null},
        "availability": {"availableFrom": null, "availableTo": null},
      };
      await FirebaseFirestore.instance.collection("cars").add(carData);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyCar()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: $e")),
      );
    }
  }

  void _goBackToMyCar() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MyCar()));
  }

  // ===================== Build Methods =====================
  @override
  Widget build(BuildContext context) {
    return _currentStep == 1 ? _buildStep1() : _buildStep2();
  }

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
          decoration: BoxDecoration(
            color: Colors.blue[50], // พื้นหลังฟ้าอ่อน
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKeyStep1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepHeader(1),
                const SizedBox(height: 20),
                const Text("รูปภาพ", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 5),
                _buildWhiteButton("เลือกรูป", Icons.image, () {}),
                // ตัวอย่างฟิลด์: ชื่อยี่ห้อรถ
                _buildTextField(
                  title: "ชื่อยี่ห้อรถ",
                  hint: "Name",
                  controller: _brandCtrl,
                  validator: (val) => val == null || val.trim().isEmpty ? "กรุณากรอกชื่อยี่ห้อรถ" : null,
                ),
                // ชื่อรุ่นรถ
                _buildTextField(
                  title: "ชื่อรุ่นรถ",
                  hint: "Name",
                  controller: _modelCtrl,
                  validator: (val) => val == null || val.trim().isEmpty ? "กรุณากรอกชื่อรุ่นรถ" : null,
                ),
                // จำนวนประตู
                _buildTextField(title: "จำนวนประตู", hint: "Number", controller: _doorCtrl, keyboardType: TextInputType.number),
                // จำนวนที่นั่ง
                _buildTextField(title: "จำนวนที่นั่ง", hint: "Number", controller: _seatCtrl, keyboardType: TextInputType.number),
                // ระบบเกียร์
                _buildTextField(title: "ระบบเกียร์", hint: "Gear", controller: _gearCtrl),
                // ระบบเครื่องยนต์
                _buildTextField(title: "ระบบเครื่องยนต์", hint: "Engine", controller: _engineCtrl),
                // จำนวนสัมภาระ
                _buildTextField(title: "จำนวนสัมภาระ", hint: "Number", controller: _baggageCtrl, keyboardType: TextInputType.number),
                // ราคาเช่าต่อวัน
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
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepHeader(2),
              const SizedBox(height: 20),
              _buildLabelWithButton("สำเนาทะเบียนรถ"),
              _buildLabelWithButton("พ.ร.บ. รถยนต์"),
              _buildLabelWithButton("สัญญาตรวจเช็คสภาพรถ"),
              const Text("เงื่อนไขการส่งเอกสาร:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              const Text(
                "- กรุณาอัปโหลดเอกสารที่ถูกต้อง\n"
                "- เอกสารต้องยังไม่หมดอายุ\n"
                "- ฯลฯ",
              ),
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
