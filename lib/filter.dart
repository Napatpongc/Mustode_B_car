import 'package:flutter/material.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({Key? key}) : super(key: key);

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  // ตัวแปรสำหรับ Price Range Slider (0 ถึง 100,000,000)
  double _selectedPrice = 100000000;

  // เก็บจำนวนดาวที่ผู้ใช้เลือก (0-5 ดาว)
  int selectedStars = 0;

  // ตัวเลือกสำหรับประเภทยานพาหนะ
  final Map<String, bool> _vehicleTypes = {
    'รถยนต์ส่วนบุคคล': false,
    'รถอเนกประสงค์': false,
    'รถกระบะ': false,
    'รถตู้': false,
    'รถสปอร์ต': false,
    'รถจักรยานยนต์': false,
    'รถไฟฟ้า': false,
    'รถไฮบริด': false,
    'รถมอเตอร์ไซค์ไฟฟ้า': false,
    'รถบ้าน': false,
    'รถจักรยาน': false,
    'สกู๊ตเตอร์ไฟฟ้า': false,
  };

  // ตัวเลือกสำหรับประเภทระบบเกียร์
  final Map<String, bool> _gearTypes = {
    'เกียร์ธรรมดา': false,
    'เกียร์อัตโนมัติ': false,
  };

  // ตัวเลือกสำหรับจำนวนสัมภาระ
  final Map<String, bool> _baggageOptions = {
    'น้อย': false,
    'ปานกลาง': false,
    'มาก': false,
  };

  // ฟังก์ชันรีเซ็ทตัวกรองทั้งหมด
  void _resetFilters() {
    setState(() {
      _selectedPrice = 100000000;
      selectedStars = 0;
      _vehicleTypes.updateAll((key, value) => false);
      _gearTypes.updateAll((key, value) => false);
      _baggageOptions.updateAll((key, value) => false);
    });
  }

  // ฟังก์ชันตกลงเพื่อส่งตัวกรองกลับไปยังหน้า home_page.dart
  void _applyFilters() {
    // เก็บรายการตัวเลือกที่ถูกเลือกไว้
    List<String> selectedVehicleTypes = _vehicleTypes.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    List<String> selectedGearTypes = _gearTypes.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    List<String> selectedBaggageOptions = _baggageOptions.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    final filters = {
      'maxPrice': _selectedPrice,
      'rating': selectedStars,
      'vehicleTypes': selectedVehicleTypes,
      'gearTypes': selectedGearTypes,
      'baggageOptions': selectedBaggageOptions,
    };

    // ส่งข้อมูลตัวกรองกลับไปยัง home_page.dart
    Navigator.pop(context, filters);
  }

  // สร้าง Widget สำหรับแสดงดาว (Star Rating)
  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        // index: 0..4
        // ถ้า index < selectedStars => เป็นดาวเต็ม
        final isSelected = index < selectedStars;
        return IconButton(
          onPressed: () {
            setState(() {
              // ถ้ากดดาวดวงที่ index => เลือก index+1 ดาว
              selectedStars = index + 1;
            });
          },
          icon: Icon(
            isSelected ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 30,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
      appBar: AppBar(
        title: const Text(
          "ตัวกรอง",
          style: TextStyle(
            fontFamily: 'Kanit',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF00377E),
        centerTitle: true,
      ),
      // พื้นหลัง Gradient
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEBF6FF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // การ์ดส่วนของ Price Range
              Card(
                color: const Color(0xFFD8EEFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ช่วงราคา (฿0 - 100,000,000)",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Slider(
                        value: _selectedPrice,
                        min: 0,
                        max: 100000000,
                        divisions: 100, // ปรับตามต้องการ
                        label: _selectedPrice.toStringAsFixed(0),
                        onChanged: (value) {
                          setState(() {
                            _selectedPrice = value;
                          });
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "≤ ฿${_selectedPrice.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // การ์ดส่วนของ Star Rating
              Card(
                color: const Color(0xFFD8EEFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        "ดาว",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildStarRating(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // การ์ดส่วนของประเภทยานพาหนะ
              Card(
                color: const Color(0xFFD8EEFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ประเภทรถ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: _vehicleTypes.keys.map((type) {
                          return CheckboxListTile(
                            title: Text(
                              type,
                              style: const TextStyle(fontSize: 14),
                            ),
                            activeColor: const Color(0xFF00377E),
                            value: _vehicleTypes[type],
                            onChanged: (value) {
                              setState(() {
                                _vehicleTypes[type] = value ?? false;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // การ์ดส่วนของประเภทระบบเกียร์
              Card(
                color: const Color(0xFFD8EEFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ระบบเกียร์",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: _gearTypes.keys.map((gear) {
                          return CheckboxListTile(
                            title: Text(
                              gear,
                              style: const TextStyle(fontSize: 14),
                            ),
                            activeColor: const Color(0xFF00377E),
                            value: _gearTypes[gear],
                            onChanged: (value) {
                              setState(() {
                                _gearTypes[gear] = value ?? false;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // การ์ดส่วนของจำนวนสัมภาระ
              Card(
                color: const Color(0xFFD8EEFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "จำนวนสัมภาระ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: _baggageOptions.keys.map((option) {
                          return CheckboxListTile(
                            title: Text(
                              option,
                              style: const TextStyle(fontSize: 14),
                            ),
                            activeColor: const Color(0xFF00377E),
                            value: _baggageOptions[option],
                            onChanged: (value) {
                              setState(() {
                                _baggageOptions[option] = value ?? false;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ปุ่มรีเซ็ทและตกลง
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _resetFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("รีเซ็ท"),
                  ),
                  ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00377E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("ตกลง"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
