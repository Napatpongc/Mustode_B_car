import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Mycar.dart';

class AddCar extends StatefulWidget {
  const AddCar({Key? key}) : super(key: key);

  @override
  State<AddCar> createState() => _AddCarState();
}

class _AddCarState extends State<AddCar> {
  int _currentStep = 1;
  final _formKeyStep1 = GlobalKey<FormState>();

  // TextEditingController สำหรับข้อมูลพื้นฐาน
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _carRegistrationCtrl = TextEditingController(); // ป้ายทะเบียนรถ

  // ตัวแปร Dropdown สำหรับจำนวนประตูและจำนวนที่นั่ง
  String? _selectedDoor;
  String? _selectedSeat;

  // รูปถ่ายรถ (Step 1)
  String? _carFrontImage;
  String? _carSideImage;
  String? _carBackImage;
  String? _carInsideImage;

  // รูปเอกสาร (Step 2)
  String? _vehicleRegImage;
  String? _motorVehicleImage;
  String? _checkVehicleImage;

  // deletehash แต่ละรูป
  String? _deletehashCarFront;
  String? _deletehashCarSide;
  String? _deletehashCarBack;
  String? _deletehashCarInside;
  String? _deletehashVehicleReg;
  String? _deletehashMotorVehicle;
  String? _deletehashCheckVehicle;

  // ประเภทยานพาหนะ (Dropdown)
  String? _selectedVehicleType;
  final List<String> _vehicleTypes = [
    'รถยนต์ส่วนบุคคล (Sedan)',
    'รถอเนกประสงค์ (SUV)',
    'รถกระบะ (Pickup Truck)',
    'รถตู้ (Van/Minivan)',
    'รถสปอร์ต (Sports Car)',
    'รถจักรยานยนต์ (Motorcycle)',
    'รถไฟฟ้า (Electric Vehicle - EV)',
    'รถไฮบริด (Hybrid Car)',
    'รถมอเตอร์ไซค์ไฟฟ้า (Electric Motorcycle)',
    'รถบ้าน (Camper Van / RV)',
    'รถจักรยาน (Bicycle)',
    'สกู๊ตเตอร์ไฟฟ้า (Electric Scooter)',
  ];

  // Map จำนวนที่นั่งสูงสุดตามประเภท (ภาษาไทย)
  final Map<String, int> _maxSeatMap = {
    'รถยนต์ส่วนบุคคล': 5,
    'รถอเนกประสงค์': 7,
    'รถกระบะ': 5,
    'รถตู้': 8,
    'รถสปอร์ต': 2,
    'รถจักรยานยนต์': 2,
    'รถไฟฟ้า': 5,
    'รถไฮบริด': 5,
    'รถมอเตอร์ไซค์ไฟฟ้า': 2,
    'รถบ้าน': 4,
    'รถจักรยาน': 1,
    'สกู๊ตเตอร์ไฟฟ้า': 1,
  };

  // Map จำนวนประตูสูงสุดตามประเภท (ภาษาไทย)
  final Map<String, int> _maxDoorMap = {
    'รถยนต์ส่วนบุคคล': 4,
    'รถอเนกประสงค์': 5,
    'รถกระบะ': 4,
    'รถตู้': 5,
    'รถสปอร์ต': 2,
    'รถจักรยานยนต์': 0,
    'รถไฟฟ้า': 4,
    'รถไฮบริด': 4,
    'รถมอเตอร์ไซค์ไฟฟ้า': 0,
    'รถบ้าน': 4,
    'รถจักรยาน': 0,
    'สกู๊ตเตอร์ไฟฟ้า': 0,
  };

  // ตัวแปร dropdown สำหรับระบบเกียร์, เครื่องยนต์, จำนวนสัมภาระ, ระบบเชื้อเพลิง
  String? _selectedGear;
  String? _selectedEngine;
  String? _selectedBaggage;
  String? _selectedFuel;

  // ฟังก์ชันดึงเฉพาะภาษาไทยจาก string เช่น "เบนซิน (Gasoline)" -> "เบนซิน"
  String _getThai(String value) {
    int index = value.indexOf(" (");
    return index != -1 ? value.substring(0, index) : value;
  }

  // ฟังก์ชันอัปโหลดรูปไป Imgur (return link/deletehash)
  Future<Map<String, String>?> _uploadToImgur(File imageFile) async {
    final uri = Uri.parse('https://api.imgur.com/3/image');
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Client-ID ed6895b5f1bf3d7'
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

  // เลือกรูปจากเครื่องและอัปโหลด
  Future<void> _pickAndUploadImage(String imageType) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    File imageFile = File(pickedFile.path);
    var result = await _uploadToImgur(imageFile);
    if (result != null) {
      setState(() {
        switch (imageType) {
          case "carfront":
            _carFrontImage = result["link"];
            _deletehashCarFront = result["deletehash"];
            break;
          case "carside":
            _carSideImage = result["link"];
            _deletehashCarSide = result["deletehash"];
            break;
          case "carback":
            _carBackImage = result["link"];
            _deletehashCarBack = result["deletehash"];
            break;
          case "carinside":
            _carInsideImage = result["link"];
            _deletehashCarInside = result["deletehash"];
            break;
          case "vehicle_registration":
            _vehicleRegImage = result["link"];
            _deletehashVehicleReg = result["deletehash"];
            break;
          case "motor_vehicle":
            _motorVehicleImage = result["link"];
            _deletehashMotorVehicle = result["deletehash"];
            break;
          case "check_vehicle":
            _checkVehicleImage = result["link"];
            _deletehashCheckVehicle = result["deletehash"];
            break;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("อัปโหลดรูป $imageType สำเร็จ!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("อัปโหลดรูป $imageType ไม่สำเร็จ")),
      );
    }
  }

  // TextField ทั่วไป
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

  // ********** DROPDOWN สำหรับจำนวนประตู / จำนวนที่นั่ง **********

  List<String> _getDoorOptions() {
    int max = 5; // fallback
    if (_selectedVehicleType != null) {
      String thaiType = _getThai(_selectedVehicleType!);
      if (_maxDoorMap.containsKey(thaiType)) {
        max = _maxDoorMap[thaiType]!;
      }
    }
    List<String> options = ["ไม่มี"];
    for (int i = 1; i <= max; i++) {
      options.add(i.toString());
    }
    return options;
  }

  Widget _buildDoorDropdown() {
    List<String> doorOptions = _getDoorOptions();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("จำนวนประตู", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _selectedDoor,
            decoration: InputDecoration(
              hintText: "เลือกจำนวนประตู",
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            ),
            items: doorOptions.map((door) {
              return DropdownMenuItem<String>(
                value: door,
                child: Text(door),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDoor = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "กรุณาเลือกจำนวนประตู";
              }
              return null;
            },
          )
        ],
      ),
    );
  }

  List<String> _getSeatOptions() {
    int max = 5; // fallback
    if (_selectedVehicleType != null) {
      String thaiType = _getThai(_selectedVehicleType!);
      if (_maxSeatMap.containsKey(thaiType)) {
        max = _maxSeatMap[thaiType]!;
      }
    }
    List<String> options = ["ไม่มี"];
    for (int i = 1; i <= max; i++) {
      options.add(i.toString());
    }
    return options;
  }

  Widget _buildSeatDropdown() {
    List<String> seatOptions = _getSeatOptions();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("จำนวนที่นั่ง", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _selectedSeat,
            decoration: InputDecoration(
              hintText: "เลือกจำนวนที่นั่ง",
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            ),
            items: seatOptions.map((seat) {
              return DropdownMenuItem<String>(
                value: seat,
                child: Text(seat),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSeat = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "กรุณาเลือกจำนวนที่นั่ง";
              }
              return null;
            },
          )
        ],
      ),
    );
  }

  // ********** DYNAMIC DROPDOWN: ระบบเกียร์, ระบบเครื่องยนต์, จำนวนสัมภาระ, ระบบเชื้อเพลิง **********

  // ระบบเกียร์
  List<String> _getGearOptions() {
    const none = "ไม่มี";
    if (_selectedVehicleType == null) return [none];
    String thaiType = _getThai(_selectedVehicleType!);

    // แมปประเภท -> ตัวเลือกเกียร์
    Map<String, List<String>> gearOptionsMap = {
      "รถยนต์ส่วนบุคคล": [
        'เกียร์ธรรมดา (Manual Transmission)',
        'เกียร์อัตโนมัติ (Automatic Transmission)'
      ],
      "รถอเนกประสงค์": [
        'เกียร์ธรรมดา (Manual Transmission)',
        'เกียร์อัตโนมัติ (Automatic Transmission)'
      ],
      "รถกระบะ": [
        'เกียร์ธรรมดา (Manual Transmission)',
        'เกียร์อัตโนมัติ (Automatic Transmission)'
      ],
      "รถตู้": [
        'เกียร์ธรรมดา (Manual Transmission)',
        'เกียร์อัตโนมัติ (Automatic Transmission)'
      ],
      "รถสปอร์ต": [
        'เกียร์ธรรมดา (Manual Transmission)',
        'เกียร์อัตโนมัติ (Automatic Transmission)'
      ],
      "รถจักรยานยนต์": [
        'เกียร์ธรรมดา (Manual Transmission)',
        'เกียร์อัตโนมัติ (Automatic Transmission)'
      ],
      "รถไฟฟ้า": [
        'เกียร์ธรรมดา (Manual Transmission)',
        'เกียร์อัตโนมัติ (Automatic Transmission)'
      ],
      "รถไฮบริด": [
        'เกียร์ธรรมดา (Manual Transmission)',
        'เกียร์อัตโนมัติ (Automatic Transmission)'
      ],
      "รถบ้าน": [
        'เกียร์ธรรมดา (Manual Transmission)',
        'เกียร์อัตโนมัติ (Automatic Transmission)'
      ],
    };

    return gearOptionsMap.containsKey(thaiType)
        ? gearOptionsMap[thaiType]!
        : [none];
  }

  Widget _buildGearDropdown() {
    List<String> gearOptions = _getGearOptions();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ระบบเกียร์", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _selectedGear,
            decoration: InputDecoration(
              hintText: "เลือกระบบเกียร์",
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            ),
            items: gearOptions.map((gear) {
              return DropdownMenuItem<String>(
                value: gear,
                child: Text(gear),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGear = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "กรุณาเลือกระบบเกียร์";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ระบบเครื่องยนต์
  List<String> _getEngineOptions() {
    const none = "ไม่มี";
    if (_selectedVehicleType == null) return [none];
    String thaiType = _getThai(_selectedVehicleType!);

    Map<String, List<String>> engineOptionsMap = {
      "รถยนต์ส่วนบุคคล": [
        'เครื่องยนต์เบนซิน (Gasoline Engine)',
        'เครื่องยนต์ดีเซล (Diesel Engine)',
        'เครื่องยนต์ไฮบริด (Hybrid Engine)',
        'เครื่องยนต์ไฟฟ้า (Electric Engine)'
      ],
      "รถอเนกประสงค์": [
        'เครื่องยนต์เบนซิน (Gasoline Engine)',
        'เครื่องยนต์ดีเซล (Diesel Engine)',
        'เครื่องยนต์ไฮบริด (Hybrid Engine)',
        'เครื่องยนต์ไฟฟ้า (Electric Engine)'
      ],
      "รถกระบะ": [
        'เครื่องยนต์เบนซิน (Gasoline Engine)',
        'เครื่องยนต์ดีเซล (Diesel Engine)',
        'เครื่องยนต์ไฮบริด (Hybrid Engine)',
        'เครื่องยนต์ไฟฟ้า (Electric Engine)'
      ],
      "รถตู้": [
        'เครื่องยนต์เบนซิน (Gasoline Engine)',
        'เครื่องยนต์ดีเซล (Diesel Engine)',
        'เครื่องยนต์ไฮบริด (Hybrid Engine)',
        'เครื่องยนต์ไฟฟ้า (Electric Engine)'
      ],
      "รถสปอร์ต": [
        'เครื่องยนต์เบนซิน (Gasoline Engine)',
        'เครื่องยนต์ไฟฟ้า (Electric Engine)'
      ],
      "รถจักรยานยนต์": [
        'เครื่องยนต์เบนซิน (Gasoline Engine)'
      ],
      "รถไฟฟ้า": [
        'เครื่องยนต์ไฟฟ้า (Electric Engine)'
      ],
      "รถไฮบริด": [
        'เครื่องยนต์ไฮบริด (Hybrid Engine)',
        'เครื่องยนต์ไฟฟ้า (Electric Engine)'
      ],
      "รถบ้าน": [
        'เครื่องยนต์เบนซิน (Gasoline Engine)',
        'เครื่องยนต์ดีเซล (Diesel Engine)'
      ],
      "รถมอเตอร์ไซค์ไฟฟ้า": [
        'เครื่องยนต์ไฟฟ้า (Electric Engine)'
      ],
      "รถจักรยาน": [none],
      "สกู๊ตเตอร์ไฟฟ้า": [
        'เครื่องยนต์ไฟฟ้า (Electric Engine)'
      ],
    };

    return engineOptionsMap.containsKey(thaiType)
        ? engineOptionsMap[thaiType]!
        : [none];
  }

  Widget _buildEngineDropdown() {
    List<String> engineOptions = _getEngineOptions();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ระบบเครื่องยนต์", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _selectedEngine,
            decoration: InputDecoration(
              hintText: "เลือกระบบเครื่องยนต์",
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            ),
            items: engineOptions.map((engine) {
              return DropdownMenuItem<String>(
                value: engine,
                child: Text(engine),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedEngine = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "กรุณาเลือกระบบเครื่องยนต์";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // จำนวนสัมภาระ
  List<String> _getBaggageOptions() {
    const none = "ไม่มี";
    if (_selectedVehicleType == null) return [none];
    String thaiType = _getThai(_selectedVehicleType!);

    Map<String, List<String>> baggageOptionsMap = {
      "รถยนต์ส่วนบุคคล": ['น้อย (Small)', 'ปานกลาง (Medium)', 'มาก (Large)'],
      "รถอเนกประสงค์": ['น้อย (Small)', 'ปานกลาง (Medium)', 'มาก (Large)'],
      "รถกระบะ": ['น้อย (Small)', 'มาก (Large)'],
      "รถตู้": ['น้อย (Small)', 'ปานกลาง (Medium)', 'มาก (Large)'],
      "รถสปอร์ต": [none],
      "รถจักรยานยนต์": [none],
      "รถไฟฟ้า": ['น้อย (Small)', 'ปานกลาง (Medium)', 'มาก (Large)'],
      "รถไฮบริด": ['น้อย (Small)', 'ปานกลาง (Medium)'],
      "รถมอเตอร์ไซค์ไฟฟ้า": [none],
      "รถบ้าน": ['น้อย (Small)', 'ปานกลาง (Medium)', 'มาก (Large)'],
      "รถจักรยาน": [none],
      "สกู๊ตเตอร์ไฟฟ้า": [none],
    };

    return baggageOptionsMap.containsKey(thaiType)
        ? baggageOptionsMap[thaiType]!
        : [none];
  }

  Widget _buildBaggageDropdown() {
    List<String> baggageOptions = _getBaggageOptions();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("จำนวนสัมภาระ", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _selectedBaggage,
            decoration: InputDecoration(
              hintText: "เลือกจำนวนสัมภาระ",
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            ),
            items: baggageOptions.map((baggage) {
              return DropdownMenuItem<String>(
                value: baggage,
                child: Text(baggage),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBaggage = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "กรุณาเลือกจำนวนสัมภาระ";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ระบบเชื้อเพลิง
  List<String> _getFuelOptions() {
    const none = "ไม่มี";
    if (_selectedVehicleType == null) return [none];
    String thaiType = _getThai(_selectedVehicleType!);

    Map<String, List<String>> fuelOptionsMap = {
      "รถยนต์ส่วนบุคคล": [
        'เบนซิน (Gasoline)',
        'ดีเซล (Diesel)',
        'ไฮบริด (Hybrid)',
        'ไฟฟ้า (Electric)',
        'ก๊าซธรรมชาติ (Natural Gas)'
      ],
      "รถอเนกประสงค์": [
        'เบนซิน (Gasoline)',
        'ดีเซล (Diesel)',
        'ไฮบริด (Hybrid)',
        'ไฟฟ้า (Electric)'
      ],
      "รถกระบะ": ['เบนซิน (Gasoline)', 'ดีเซล (Diesel)'],
      "รถตู้": ['เบนซิน (Gasoline)', 'ดีเซล (Diesel)', 'ไฮบริด (Hybrid)'],
      "รถสปอร์ต": ['เบนซิน (Gasoline)', 'ไฟฟ้า (Electric)'],
      "รถจักรยานยนต์": ['เบนซิน (Gasoline)'],
      "รถไฟฟ้า": ['ไฟฟ้า (Electric)'],
      "รถไฮบริด": ['ไฮบริด (Hybrid)', 'ไฟฟ้า (Electric)'],
      "รถบ้าน": ['เบนซิน (Gasoline)', 'ดีเซล (Diesel)'],
      "รถมอเตอร์ไซค์ไฟฟ้า": ['ไฟฟ้า (Electric)'],
      "รถจักรยาน": [none],
      "สกู๊ตเตอร์ไฟฟ้า": ['ไฟฟ้า (Electric)'],
    };

    return fuelOptionsMap.containsKey(thaiType)
        ? fuelOptionsMap[thaiType]!
        : [none];
  }

  Widget _buildFuelDropdown() {
    List<String> fuelOptions = _getFuelOptions();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ระบบเชื้อเพลิง", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _selectedFuel,
            decoration: InputDecoration(
              hintText: "เลือกระบบเชื้อเพลิง",
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            ),
            items: fuelOptions.map((fuel) {
              return DropdownMenuItem<String>(
                value: fuel,
                child: Text(fuel),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedFuel = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "กรุณาเลือกระบบเชื้อเพลิง";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // สร้างปุ่มสีขาว
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

  // ส่วน Label + ปุ่มเลือกรูป + Preview
  Widget _buildLabelWithButton(String label, String imageType) {
    String? preview;
    switch (imageType) {
      case "carfront":
        preview = _carFrontImage;
        break;
      case "carside":
        preview = _carSideImage;
        break;
      case "carback":
        preview = _carBackImage;
        break;
      case "carinside":
        preview = _carInsideImage;
        break;
      case "vehicle_registration":
        preview = _vehicleRegImage;
        break;
      case "motor_vehicle":
        preview = _motorVehicleImage;
        break;
      case "check_vehicle":
        preview = _checkVehicleImage;
        break;
    }

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

  // Dropdown ประเภทยานพาหนะ
  Widget _buildVehicleDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("ประเภทยานพาหนะ", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _selectedVehicleType,
            decoration: InputDecoration(
              hintText: "เลือกประเภทยานพาหนะ",
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            ),
            items: _vehicleTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedVehicleType = value;
                // รีเซ็ต dropdown อื่น ๆ เมื่อเลือกประเภทใหม่
                _selectedSeat = null;
                _selectedDoor = null;
                _selectedGear = null;
                _selectedEngine = null;
                _selectedBaggage = null;
                _selectedFuel = null;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "กรุณาเลือกประเภทยานพาหนะ";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Header แสดงขั้นตอน 1/2
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

  // วงกลมแสดงขั้นตอน
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
          child: Center(
            child: Text(
              "$number",
              style: TextStyle(color: active ? Colors.white : Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // Step control
  void _nextStep() {
    if (_currentStep == 1 && (_formKeyStep1.currentState?.validate() ?? false)) {
      setState(() => _currentStep = 2);
    }
  }

  void _previousStep() {
    if (_currentStep == 2) {
      setState(() => _currentStep = 1);
    }
  }

  // บันทึกข้อมูลลง Firestore
  Future<void> _submitCarData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("ไม่พบผู้ใช้ที่ล็อกอิน")));
      return;
    }
    // ดึง location ของ user
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();
    double latitude = 0;
    double longitude = 0;
    if (userDoc.exists && userDoc.data() != null) {
      var userData = userDoc.data() as Map<String, dynamic>;
      if (userData["location"] != null) {
        latitude = (userData["location"]["latitude"] ?? 0).toDouble();
        longitude = (userData["location"]["longitude"] ?? 0).toDouble();
      }
    }

    DateTime now = DateTime.now();
    DateTime availableTo = now.add(const Duration(days: 90));

    final carData = {
      "ownerId": user.uid,
      "brand": _brandCtrl.text.trim(),
      "model": _modelCtrl.text.trim(),
      "detail": {
        "door": _selectedDoor == null || _selectedDoor == "ไม่มี"
            ? 0
            : int.tryParse(_selectedDoor!) ?? 0,
        "seat": _selectedSeat == null || _selectedSeat == "ไม่มี"
            ? 0
            : int.tryParse(_selectedSeat!) ?? 0,
        "gear": _selectedGear != null ? _getThai(_selectedGear!) : "",
        "engine": _selectedEngine != null ? _getThai(_selectedEngine!) : "",
        "baggage": _selectedBaggage != null ? _getThai(_selectedBaggage!) : "",
        "Vehicle": _selectedVehicleType != null ? _getThai(_selectedVehicleType!) : "",
        "fuel": _selectedFuel != null ? _getThai(_selectedFuel!) : "",
      },
      "price": double.tryParse(_priceCtrl.text) ?? 0.0,
      "image": {
        "carfront": _carFrontImage ?? "",
        "carside": _carSideImage ?? "",
        "carback": _carBackImage ?? "",
        "carinside": _carInsideImage ?? "",
        "vehicle registration": _vehicleRegImage ?? "",
        "motor_vehicle": _motorVehicleImage ?? "",
        "check_vehicle": _checkVehicleImage ?? "",
      },
      "location": {
        "latitude": latitude,
        "longitude": longitude,
      },
      "availability": {
        "availableFrom": Timestamp.fromDate(now),
        "availableTo": Timestamp.fromDate(availableTo),
      },
      "deletehash": {
        "deletehashcarfront": _deletehashCarFront ?? "",
        "deletehashcarside": _deletehashCarSide ?? "",
        "deletehashcarback": _deletehashCarBack ?? "",
        "deletehashcarinside": _deletehashCarInside ?? "",
        "deletehashvehicle_registration": _deletehashVehicleReg ?? "",
        "deletehashmotor_vehicle": _deletehashMotorVehicle ?? "",
        "deletehashcheck_vehicle": _deletehashCheckVehicle ?? "",
      },
      "Car registration": _carRegistrationCtrl.text.trim(),
      "statuscar": "yes",
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
    // หาก _currentStep == 1 ให้แสดงหน้าฟอร์มรถ
    // หาก == 2 ให้แสดงหน้าส่งเอกสาร
    return _currentStep == 1 ? _buildStep1() : _buildStep2();
  }

  // STEP 1: ข้อมูลรถ
  Widget _buildStep1() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("เพิ่มรถ"),
        backgroundColor: const Color(0xFF00377E),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _goBackToMyCar,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue[50],
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
                // รูปถ่ายรถ
                _buildLabelWithButton("รูปด้านหน้า", "carfront"),
                _buildLabelWithButton("รูปด้านข้าง", "carside"),
                _buildLabelWithButton("รูปด้านหลัง", "carback"),
                _buildLabelWithButton("รูปด้านใน", "carinside"),

                // ข้อมูลพื้นฐาน
                _buildTextField(
                  title: "ป้ายทะเบียนรถ",
                  hint: "กรอกป้ายทะเบียนรถ",
                  controller: _carRegistrationCtrl,
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? "กรุณากรอกป้ายทะเบียนรถ"
                      : null,
                ),
                _buildTextField(
                  title: "ชื่อยี่ห้อรถ",
                  hint: "Name",
                  controller: _brandCtrl,
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? "กรุณากรอกชื่อยี่ห้อรถ"
                      : null,
                ),
                _buildTextField(
                  title: "ชื่อรุ่นรถ",
                  hint: "Name",
                  controller: _modelCtrl,
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? "กรุณากรอกชื่อรุ่นรถ"
                      : null,
                ),

                // Dropdown ประเภทยานพาหนะ
                _buildVehicleDropdown(),

                // Dropdown จำนวนประตู / จำนวนที่นั่ง
                _buildDoorDropdown(),
                _buildSeatDropdown(),

                // Dropdown ระบบเกียร์ / ระบบเครื่องยนต์ / จำนวนสัมภาระ / ระบบเชื้อเพลิง
                _buildGearDropdown(),
                _buildEngineDropdown(),
                _buildBaggageDropdown(),
                _buildFuelDropdown(),

                _buildTextField(
                  title: "ราคาเช่าต่อวัน",
                  hint: "Price",
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                ),

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
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _goBackToMyCar,
        ),
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
