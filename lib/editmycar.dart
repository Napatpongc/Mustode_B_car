import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class EditVehicleRegistration extends StatefulWidget {
  final String carId;
  final String currentImageUrl;
  final String currentDeleteHash;
  const EditVehicleRegistration({
    Key? key,
    required this.carId,
    required this.currentImageUrl,
    required this.currentDeleteHash,
  }) : super(key: key);

  @override
  _EditVehicleRegistrationState createState() => _EditVehicleRegistrationState();
}

class _EditVehicleRegistrationState extends State<EditVehicleRegistration> {
  File? _newImageFile;
  bool _isLoading = false;
  final String _imgurClientId = 'ed6895b5f1bf3d7';

  // ฟังก์ชันเลือกรูปใหม่
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newImageFile = File(pickedFile.path);
      });
    }
  }

  // ฟังก์ชันลบรูปเก่าจาก Imgur โดยใช้ deletehash
  Future<bool> _deleteOldImage() async {
    final uri = Uri.parse('https://api.imgur.com/3/image/${widget.currentDeleteHash}');
    final response = await http.delete(
      uri,
      headers: {'Authorization': 'Client-ID $_imgurClientId'},
    );
    return response.statusCode == 200;
  }

  // ฟังก์ชันอัปโหลดรูปใหม่ไป Imgur
  Future<Map<String, String>?> _uploadNewImage(File imageFile) async {
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

  // ฟังก์ชันอัปเดตรูปใน Firestore
  Future<void> _updateFirestore(String newLink, String newDeleteHash) async {
    await FirebaseFirestore.instance.collection("cars").doc(widget.carId).update({
      "image.vehicle registration": newLink,
      "deletehash.deletehashvehicle_registration": newDeleteHash,
    });
  }

  // ฟังก์ชันบันทึกการเปลี่ยนแปลง
  Future<void> _saveChanges() async {
    if (_newImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณาเลือกรูปใหม่ก่อนบันทึก")),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });

    // ลบรูปเก่า
    bool deleteSuccess = await _deleteOldImage();
    if (!deleteSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("การลบรูปเก่าไม่สำเร็จ")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // อัปโหลดรูปใหม่
    var uploadResult = await _uploadNewImage(_newImageFile!);
    if (uploadResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("อัปโหลดรูปใหม่ไม่สำเร็จ")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // อัปเดตรายการใน Firestore
    await _updateFirestore(uploadResult["link"]!, uploadResult["deletehash"]!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("อัปเดตรูปสำเร็จ")),
    );
    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("แก้ไขรูปสำเนาทะเบียนรถ"),
        backgroundColor: const Color(0xFF00377E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // แสดงรูปปัจจุบัน
            const Text("รูปปัจจุบัน:"),
            const SizedBox(height: 10),
            widget.currentImageUrl.isNotEmpty
                ? Image.network(
                    widget.currentImageUrl,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 120,
                    height: 120,
                    color: Colors.grey,
                  ),
            const SizedBox(height: 20),
            // ปุ่มเลือกรูปใหม่ พร้อม preview รูปที่เลือก
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("เลือกรูปใหม่"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
                const SizedBox(width: 10),
                if (_newImageFile != null)
                  Image.file(
                    _newImageFile!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
              ],
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _saveChanges,
                    icon: const Icon(Icons.save),
                    label: const Text("บันทึก"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
