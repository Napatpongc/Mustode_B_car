import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CarReviewPage extends StatefulWidget {
  final String carDocumentId;
  final String rentalDocId;

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
  int rating = 0;
  int cleanliness = 0;
  TextEditingController commentController = TextEditingController();
  String? userId;

  @override
  void initState() {
    super.initState();
    fetchCarData();
    getCurrentUser();
  }

  /// ดึงข้อมูลรถจาก Firestore
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

  /// ดึงข้อมูล user ID ของผู้ที่กำลังรีวิว
  void getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }

  /// ฟังก์ชันบันทึกรีวิวลง Firestore และอัปเดต rentals เป็น "done"
  void submitReview() async {
    if (rating == 0 || cleanliness == 0 || commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("โปรดให้คะแนนและเขียนคอมเมนต์ก่อนส่ง")),
      );
      return;
    }

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: ไม่พบข้อมูลผู้ใช้")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("cars")
          .doc(widget.carDocumentId)
          .collection("carComments")
          .add({
        'userId': userId, // ✅ เก็บ userId ของผู้ที่ให้คอมเมนต์
        'rating': rating,
        'cleanliness': cleanliness,
        'comment': commentController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection("rentals")
          .doc(widget.rentalDocId)
          .update({'status': 'done'});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("รีวิวถูกส่งเรียบร้อย!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาดในการส่งรีวิว: $e")),
      );
    }
  }

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
      resizeToAvoidBottomInset: false,
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
                        : Container(height: 200, color: Colors.grey),
                    SizedBox(height: 20),
                    Text("ให้คะแนนรีวิว", style: TextStyle(fontSize: 18)),
                    buildStarRating(),
                    SizedBox(height: 20),
                    Text("ความสะอาด", style: TextStyle(fontSize: 18)),
                    buildCleanlinessIcons(),
                    SizedBox(height: 20),
                    TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: "ข้อเสนอแนะ...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      maxLines: null,
                    ),
                    SizedBox(height: 20),
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
