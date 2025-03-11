import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class IDCardScannerPage extends StatefulWidget {
  const IDCardScannerPage({Key? key}) : super(key: key);

  @override
  State<IDCardScannerPage> createState() => _IDCardScannerPageState();
}

class _IDCardScannerPageState extends State<IDCardScannerPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) return;
    final backCamera = _cameras!.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras!.first,
    );
    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    try {
      await _cameraController!.initialize();
      setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint("Initialize camera error: $e");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _capturePicture() async {
    if (!_isCameraInitialized || _cameraController == null) return;
    try {
      final xFile = await _cameraController!.takePicture();
      final file = File(xFile.path);
      Navigator.pop(context, file);
    } catch (e) {
      debugPrint("ถ่ายภาพไม่สำเร็จ: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("สแกนบัตรประชาชน"),
        backgroundColor: const Color(0xFF00377E),
      ),
      body: _isCameraInitialized
          ? Stack(
              children: [
                CameraPreview(_cameraController!),
                Positioned.fill(
                  child: CustomPaint(painter: _IDCardOverlayPainter()),
                ),
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "กรุณาวางบัตรประชาชน\nให้อยู่ในกรอบ",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        shadows: [
                          Shadow(blurRadius: 4, color: Colors.black, offset: Offset(2, 2))
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: _capturePicture,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                      child: const Text("ถ่ายภาพ"),
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class _IDCardOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = Colors.black.withOpacity(0.5);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    final cardWidth = size.width * 0.8;
    final cardHeight = cardWidth * 0.6;
    final left = (size.width - cardWidth) / 2;
    final top = (size.height - cardHeight) / 2;
    final scanRect = Rect.fromLTWH(left, top, cardWidth, cardHeight);

    // Clear the center area to show the camera preview
    canvas.saveLayer(Rect.largest, Paint());
    canvas.drawRect(scanRect, Paint()..blendMode = BlendMode.clear);
    canvas.restore();

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(scanRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
