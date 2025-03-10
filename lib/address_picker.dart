import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class AddressPicker extends StatefulWidget {
  final Function(String province, String district, String subdistrict, String postalCode)
      onAddressSelected;

  // เพิ่ม props สำหรับรับค่าเริ่มต้น
  final String? initialProvince;
  final String? initialDistrict;
  final String? initialSubdistrict;
  final String? initialPostalCode;

  const AddressPicker({
    Key? key,
    required this.onAddressSelected,
    this.initialProvince,
    this.initialDistrict,
    this.initialSubdistrict,
    this.initialPostalCode,
  }) : super(key: key);

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
    final jsonStr = await rootBundle.loadString('assets/geography.json');
    final List<dynamic> data = jsonDecode(jsonStr);
    setState(() {
      _geoData = data;
    });

    // เมื่อโหลดเสร็จแล้ว set ค่าเริ่มต้น
    _initializeDefaults();
  }

  void _initializeDefaults() {
    if (widget.initialProvince != null && widget.initialProvince!.isNotEmpty) {
      _selectedProvince = widget.initialProvince;
    }
    if (widget.initialDistrict != null && widget.initialDistrict!.isNotEmpty) {
      _selectedDistrict = widget.initialDistrict;
    }
    if (widget.initialSubdistrict != null && widget.initialSubdistrict!.isNotEmpty) {
      _selectedSubdistrict = widget.initialSubdistrict;
    }
    if (widget.initialPostalCode != null && widget.initialPostalCode!.isNotEmpty) {
      _postalCode = widget.initialPostalCode;
    }
    setState(() {});
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
        // จังหวัด
        DropdownButtonFormField<String>(
          value: _selectedProvince,
          decoration: const InputDecoration(labelText: "เลือกจังหวัด"),
          items: provinces
              .map<DropdownMenuItem<String>>((p) => DropdownMenuItem<String>(
                    value: p,
                    child: Text(p),
                  ))
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

        // อำเภอ
        DropdownButtonFormField<String>(
          value: _selectedDistrict,
          decoration: const InputDecoration(labelText: "เลือกอำเภอ"),
          items: _selectedProvince == null
              ? []
              : _getDistricts(_selectedProvince!)
                  .map<DropdownMenuItem<String>>((d) => DropdownMenuItem<String>(
                        value: d,
                        child: Text(d),
                      ))
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

        // ตำบล
        DropdownButtonFormField<String>(
          value: _selectedSubdistrict,
          decoration: const InputDecoration(labelText: "เลือกตำบล"),
          items: (_selectedProvince == null || _selectedDistrict == null)
              ? []
              : _getSubdistricts(_selectedProvince!, _selectedDistrict!)
                  .map<DropdownMenuItem<String>>((s) => DropdownMenuItem<String>(
                        value: s,
                        child: Text(s),
                      ))
                  .toList(),
          onChanged: (val) {
            setState(() {
              _selectedSubdistrict = val;
              if (val != null) {
                _postalCode = _getPostalCode(_selectedProvince!, _selectedDistrict!, val);
              } else {
                _postalCode = null;
              }
            });
          },
        ),
        const SizedBox(height: 8),

        // รหัสไปรษณีย์ (readOnly)
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
