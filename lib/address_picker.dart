// address_picker.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class AddressPicker extends StatefulWidget {
  final Function(String province, String district, String subdistrict, String postalCode) onAddressSelected;

  const AddressPicker({Key? key, required this.onAddressSelected}) : super(key: key);

  @override
  _AddressPickerState createState() => _AddressPickerState();
}

class _AddressPickerState extends State<AddressPicker> {
  List<dynamic> _geoData = [];
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedSubdistrict;
  String? _postalCode;

  @override
  void initState() {
    super.initState();
    _loadGeographyData();
  }

  Future<void> _loadGeographyData() async {
    // โหลดไฟล์ JSON ที่มีข้อมูลจังหวัด/อำเภอ/ตำบล/รหัสไปรษณีย์
    final jsonStr = await rootBundle.loadString('assets/geography.json');
    final List<dynamic> data = jsonDecode(jsonStr);
    setState(() {
      _geoData = data;
    });
  }

  List<String> _getProvinces() {
    final provinces = _geoData
        .map((e) => e["provinceNameTh"] as String)
        .toSet()
        .toList();
    provinces.sort();
    return provinces;
  }

  List<String> _getDistricts(String provinceName) {
    final districts = _geoData
        .where((e) => e["provinceNameTh"] == provinceName)
        .map((e) => e["districtNameTh"] as String)
        .toSet()
        .toList();
    districts.sort();
    return districts;
  }

  List<String> _getSubdistricts(String provinceName, String districtName) {
    final subdistricts = _geoData
        .where((e) =>
            e["provinceNameTh"] == provinceName &&
            e["districtNameTh"] == districtName)
        .map((e) => e["subdistrictNameTh"] as String)
        .toSet()
        .toList();
    subdistricts.sort();
    return subdistricts;
  }

  String _getPostalCode(String provinceName, String districtName, String subdistrictName) {
    final match = _geoData.firstWhere(
      (e) =>
          e["provinceNameTh"] == provinceName &&
          e["districtNameTh"] == districtName &&
          e["subdistrictNameTh"] == subdistrictName,
      orElse: () => null,
    );
    return match != null ? match["postalCode"].toString() : "";
  }

  @override
  Widget build(BuildContext context) {
    final provinces = _getProvinces();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown จังหวัด
        DropdownButtonFormField<String>(
          value: _selectedProvince,
          decoration: const InputDecoration(labelText: "เลือกจังหวัด"),
          items: provinces
              .map<DropdownMenuItem<String>>(
                (p) => DropdownMenuItem<String>(value: p, child: Text(p)),
              )
              .toList(),
          onChanged: (val) {
            setState(() {
              _selectedProvince = val;
              _selectedDistrict = null;
              _selectedSubdistrict = null;
              _postalCode = null;
            });
          },
        ),

        const SizedBox(height: 8),

        // Dropdown อำเภอ
        DropdownButtonFormField<String>(
          value: _selectedDistrict,
          decoration: const InputDecoration(labelText: "เลือกอำเภอ"),
          items: _selectedProvince == null
              ? []
              : _getDistricts(_selectedProvince!)
                  .map<DropdownMenuItem<String>>(
                    (d) => DropdownMenuItem<String>(value: d, child: Text(d)),
                  )
                  .toList(),
          onChanged: (val) {
            setState(() {
              _selectedDistrict = val;
              _selectedSubdistrict = null;
              _postalCode = null;
            });
          },
        ),

        const SizedBox(height: 8),

        // Dropdown ตำบล
        DropdownButtonFormField<String>(
          value: _selectedSubdistrict,
          decoration: const InputDecoration(labelText: "เลือกตำบล"),
          items: (_selectedProvince == null || _selectedDistrict == null)
              ? []
              : _getSubdistricts(_selectedProvince!, _selectedDistrict!)
                  .map<DropdownMenuItem<String>>(
                    (s) => DropdownMenuItem<String>(value: s, child: Text(s)),
                  )
                  .toList(),
          onChanged: (val) {
            setState(() {
              _selectedSubdistrict = val;
              if (val != null) {
                _postalCode = _getPostalCode(
                  _selectedProvince!,
                  _selectedDistrict!,
                  val,
                );
              } else {
                _postalCode = null;
              }
            });
          },
        ),

        const SizedBox(height: 8),

        // แสดงรหัสไปรษณีย์
        TextFormField(
          readOnly: true,
          decoration: const InputDecoration(labelText: "รหัสไปรษณีย์"),
          controller: TextEditingController(text: _postalCode ?? ""),
        ),

        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: () {
            if (_selectedProvince != null &&
                _selectedDistrict != null &&
                _selectedSubdistrict != null &&
                _postalCode != null) {
              // เรียก callback กลับไปที่หน้าหลัก
              widget.onAddressSelected(
                _selectedProvince!,
                _selectedDistrict!,
                _selectedSubdistrict!,
                _postalCode!,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("กรุณาเลือกที่อยู่ให้ครบ")),
              );
            }
          },
          child: const Text("ยืนยันที่อยู่"),
        ),
      ],
    );
  }
}
