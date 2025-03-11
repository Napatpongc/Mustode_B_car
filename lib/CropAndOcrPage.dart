import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart'; // ✅ ใช้ GetX สำหรับ Navigation & Snackbar

class CropAndOcrPage extends StatefulWidget {
  final File imageFile;
  const CropAndOcrPage({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<CropAndOcrPage> createState() => _CropAndOcrPageState();
}

class _CropAndOcrPageState extends State<CropAndOcrPage> {
  final GlobalKey<ExtendedImageEditorState> editorKey = GlobalKey<ExtendedImageEditorState>();

  final String _imgurClientId = "ed6895b5f1bf3d7"; // 🔥 ใส่ Client ID ของคุณ

  bool _isProcessing = false; // ✅ สถานะโหลด
  String _extractedText = ""; // ✅ เก็บข้อความ OCR

  /// ✅ **Crop + OCR + Upload ID Card ไปที่ Firestore**
  Future<void> _cropAndUploadIdCard() async {
    setState(() => _isProcessing = true); // ✅ เริ่มโหลด (แสดง overlay)

    final state = editorKey.currentState;
    if (state == null) {
      setState(() => _isProcessing = false);
      return;
    }

    // **ดึงข้อมูลภาพที่ถูก Crop**
    final Uint8List? croppedData = state.rawImageData;
    if (croppedData == null) {
      setState(() => _isProcessing = false);
      return;
    }

    // **สร้างไฟล์ชั่วคราวจาก croppedData**
    final tempDir = await getTemporaryDirectory();
    final tempFile = await File('${tempDir.path}/cropped_id_card.jpg')
        .writeAsBytes(croppedData);

    // **OCR ด้วย ML Kit**
    final inputImage = InputImage.fromFilePath(tempFile.path);
    final textRecognizer = TextRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    _extractedText = recognizedText.text; // ✅ บันทึกข้อความ OCR

    // **อัปโหลดรูปไป Imgur**
    try {
      final imgurResult = await _uploadImageToImgur(tempFile);
      final downloadUrl = imgurResult['link'];
      final deleteHash = imgurResult['deletehash'];

      // **อัปเดต Firestore**
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
              'image': {
                'id_card': downloadUrl, // ✅ บันทึก URL ของ ID Card
                'deletehash_id_card': deleteHash, // ✅ บันทึก hash สำหรับลบรูป
              },
              'address': {
                'moreinfo': _extractedText, // ✅ เพิ่มข้อความ OCR ลงไปในรายละเอียดเพิ่มเติม
              }
            }, SetOptions(merge: true)); // ✅ merge: true ไม่ลบข้อมูลอื่น
      }
      
      // ✅ แสดงข้อความสำเร็จ
      if (!mounted) return;
      Get.snackbar(
        "สำเร็จ", 
        "ทำการ crop รูปภาพสำเร็จ และเพิ่มข้อมูลที่อยู่",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // ✅ ไปหน้า ProfileLessor
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Get.offNamed('/profileLessor');
      });

    } catch (e) {
      debugPrint("เกิดข้อผิดพลาดในการอัปโหลดรูปหรือบันทึกข้อมูล: $e");
    }

    setState(() => _isProcessing = false); // ✅ จบโหลด
  }

  /// 📌 **อัปโหลดรูปไป Imgur**
  Future<Map<String, dynamic>> _uploadImageToImgur(File file) async {
    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(
      Uri.parse('https://api.imgur.com/3/image'),
      headers: {'Authorization': 'Client-ID $_imgurClientId'},
      body: {'image': base64Image, 'type': 'base64'},
    );

    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      return {'link': data['data']['link'], 'deletehash': data['data']['deletehash']};
    } else {
      throw Exception("อัปโหลดรูปไป Imgur ไม่สำเร็จ: ${data['data']['error']}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crop & Upload ID Card"),
        backgroundColor: const Color(0xFF00377E),
      ),
      body: Stack(
        children: [
          ExtendedImage.file(
            widget.imageFile,
            fit: BoxFit.contain,
            mode: ExtendedImageMode.editor,
            extendedImageEditorKey: editorKey,
            cacheRawData: true, // ✅ ต้องเพิ่มเพื่อให้ Crop ได้
            initEditorConfigHandler: (state) {
              return EditorConfig(
                maxScale: 8.0,
                cropRectPadding: const EdgeInsets.all(20.0),
                hitTestSize: 20.0,
              );
            },
          ),
          if (_isProcessing) // ✅ Overlay Loading
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _cropAndUploadIdCard, // ✅ Crop & Upload ID Card
        child: const Icon(Icons.upload),
        tooltip: "Crop & Upload ID Card",
      ),
    );
  }
}
