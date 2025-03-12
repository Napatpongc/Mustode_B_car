import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'list.dart'; // เพิ่ม import ไฟล์ list.dart

class CarReviewPage extends StatefulWidget {
  final String carDocumentId; // document ID ของ Firestore ที่เก็บรถ
  final String rentalDocId; // document ID ของ Firestore ที่เก็บ rental

  CarReviewPage({
    required this.carDocumentId,
    required this.rentalDocId,
  });

  @override
  _CarReviewPageState createState() => _CarReviewPageState();
}

class _CarReviewPageState extends State<CarReviewPage> {
  String carName = "";
  String carImageUrl = "";
  bool isLoading = true;
  int rating = 0; // ⭐ คะแนนรีวิว
  int cleanliness = 0; // ✨ ความสะอาด
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCarData();
  }

  /// ดึงข้อมูลรถจาก Firestore เพื่อแสดงรูป/ชื่อรถ
  void fetchCarData() async {
    try {
      DocumentSnapshot carDoc = await FirebaseFirestore.instance
          .collection("cars")
          .doc(widget.carDocumentId)
          .get();

      if (carDoc.exists) {
        setState(() {
          carName = "${carDoc["brand"]} ${carDoc["model"]}";
          carImageUrl = carDoc["image"]["carfront"] ?? "";
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ไม่พบข้อมูลรถในระบบ")),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาดในการดึงข้อมูลรถ")),
      );
    }
  }

  /// ฟังก์ชันบันทึกรีวิวลง Firestore (รองรับภาษาไทย) และอัปเดต rentals เป็น "done"
  void submitReview() async {
    if (rating == 0 || cleanliness == 0 || commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("โปรดให้คะแนนและเขียนคอมเมนต์ก่อนส่ง")),
      );
      return;
    }

    // บังคับใช้ UTF-8 กับข้อความ
    String commentText = commentController.text.trim();
    List<int> utf8Bytes = commentText.runes.toList();
    String utf8String = String.fromCharCodes(utf8Bytes);

    try {
      // 1) เพิ่มข้อมูลคอมเมนต์ลงใน cars/{carDocumentId}/carComments
      await FirebaseFirestore.instance
          .collection("cars")
          .doc(widget.carDocumentId)
          .collection("carComments")
          .add({
        'rating': rating, // คะแนนดาว
        'cleanliness': cleanliness, // คะแนนความสะอาด
        'comment': utf8String, // ข้อความรีวิว
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2) อัปเดต status ของ rentalDocId ให้เป็น "done"
      await FirebaseFirestore.instance
          .collection("rentals")
          .doc(widget.rentalDocId)
          .update({'status': 'done'});

      // 3) แจ้งเตือนแล้วนำทางกลับไปยัง ListPage
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("รีวิวถูกส่งเรียบร้อย!")),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => ListPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาดในการส่งรีวิว: $e")),
      );
    }
  }

  /// Widget สร้างแถบให้คะแนน (ดาว)
  Widget buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.yellow,
            size: 40,
          ),
          onPressed: () {
            setState(() {
              rating = index + 1;
            });
          },
        );
      }),
    );
  }

  /// Widget สร้างแถบให้คะแนนความสะอาด
  Widget buildCleanlinessIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < cleanliness
                ? Icons.emoji_emotions
                : Icons.emoji_emotions_outlined,
            color: Colors.blue,
            size: 40,
          ),
          onPressed: () {
            setState(() {
              cleanliness = index + 1;
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // ป้องกัน Bottom Overflow
      appBar: AppBar(
        title: Text("รีวิวรถ"),
        backgroundColor: Color(0xFF00377E),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      carName,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    carImageUrl.isNotEmpty
                        ? Image.network(carImageUrl,
                            height: 200, fit: BoxFit.cover)
                        : Container(
                            height: 200, color: Colors.grey), // กรณีไม่มีรูป
                    SizedBox(height: 20),

                    // ให้คะแนนรีวิว
                    Text("ให้คะแนนรีวิว", style: TextStyle(fontSize: 18)),
                    buildStarRating(),

                    SizedBox(height: 20),

                    // ให้คะแนนความสะอาด
                    Text("ความสะอาด", style: TextStyle(fontSize: 18)),
                    buildCleanlinessIcons(),

                    SizedBox(height: 20),

                    // กล่องป้อนคอมเมนต์ (รองรับภาษาไทย)
                    TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: "ข้อเสนอแนะ...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      keyboardType: TextInputType.multiline, // รองรับหลายบรรทัด
                      textInputAction: TextInputAction.newline, // รองรับ Enter
                      maxLines: null, // ให้พิมพ์ได้ไม่จำกัดบรรทัด
                    ),

                    SizedBox(height: 20),

                    // ปุ่มส่งรีวิว
                    ElevatedButton(
                      onPressed: submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00377E),
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      ),
                      child: Text(
                        "ส่งรีวิว",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
