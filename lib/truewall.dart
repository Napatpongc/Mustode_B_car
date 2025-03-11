import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:validators/validators.dart';

/// หน้า TrueWall สำหรับรับเงินจากซองของขวัญ TrueMoney
/// truewall นี้จะถูกเรียกใช้ผ่าน StatusRenter โดยส่ง parameter rentalId
class TrueWall extends StatefulWidget {
  final String rentalId;
  const TrueWall({Key? key, required this.rentalId}) : super(key: key);

  @override
  _TrueWallState createState() => _TrueWallState();
}

class _TrueWallState extends State<TrueWall> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // FirebaseAuth ไม่ได้ใช้งานในส่วนนี้ แต่คงไว้เพื่อโครงสร้างเดิม
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TrueWalletService _walletService = TrueWalletService();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLessorPhone();
  }

  // ดึงเบอร์โทรศัพท์ของผู้ให้เช่า (lessor) จากเอกสารการเช่าและ collection users
  Future<void> _fetchLessorPhone() async {
    print("[DEBUG] _fetchLessorPhone: start");
    try {
      DocumentSnapshot rentalDoc =
          await _firestore.collection('rentals').doc(widget.rentalId).get();
      print("[DEBUG] rentalDoc.exists = ${rentalDoc.exists}");
      if (rentalDoc.exists) {
        var rentalData = rentalDoc.data() as Map<String, dynamic>;
        String lessorId = rentalData["lessorId"] ?? "";
        print("[DEBUG] lessorId = $lessorId");
        if (lessorId.isNotEmpty) {
          DocumentSnapshot lessorDoc =
              await _firestore.collection('users').doc(lessorId).get();
          print("[DEBUG] lessorDoc.exists = ${lessorDoc.exists}");
          if (lessorDoc.exists) {
            var lessorData = lessorDoc.data() as Map<String, dynamic>;
            setState(() {
              _phoneController.text = lessorData["phone"] ?? "ไม่มีข้อมูล";
              isLoading = false;
            });
            print("[DEBUG] phone = ${_phoneController.text}");
          } else {
            setState(() {
              _phoneController.text = "ไม่พบข้อมูลผู้ให้เช่า";
              isLoading = false;
            });
          }
        } else {
          setState(() {
            _phoneController.text = "ไม่มี lessorId ในข้อมูลการเช่า";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          _phoneController.text = "ไม่พบข้อมูลการเช่า";
          isLoading = false;
        });
      }
    } catch (e) {
      print("[DEBUG] _fetchLessorPhone ERROR: $e");
      setState(() {
        _phoneController.text = "เกิดข้อผิดพลาด";
        isLoading = false;
      });
    }
  }

  // ฟังก์ชัน Redeem ซองของขวัญ พร้อมตรวจสอบจำนวนเงินและอัปเดตสถานะการเช่า
  void _redeemGift() async {
    print("[DEBUG] _redeemGift: start");
    setState(() {
      isLoading = true;
    });

    try {
      print("[DEBUG] กำลังตรวจสอบ status ใน Firestore...");
      DocumentSnapshot rentalDoc =
          await _firestore.collection('rentals').doc(widget.rentalId).get();
      if (rentalDoc.exists) {
        var rentalData = rentalDoc.data() as Map<String, dynamic>;
        print("[DEBUG] rentalData = $rentalData");
        if (rentalData["status"] == "release") {
          print("[DEBUG] status เป็น release แล้ว => ยกเลิกการ redeem");
          _showSnackBar("เงินถูกโอนแล้ว");
          setState(() {
            isLoading = false;
          });
          return;
        }
      }

      String phoneNumber = _phoneController.text.trim();
      String url = _urlController.text.trim();
      print("[DEBUG] phoneNumber = $phoneNumber, url = $url");
      if (phoneNumber.isEmpty || url.isEmpty) {
        print("[DEBUG] phoneNumber/url ว่าง => return");
        _showSnackBar("❌ กรุณากรอกลิงก์ซองของขวัญ");
        setState(() {
          isLoading = false;
        });
        return;
      }

      print("[DEBUG] กำลังเรียก redeemGift service...");
      final result = await _walletService.redeemGift(url, phoneNumber);
      print("[DEBUG] redeemGift result = $result");
      if (result.containsKey("error")) {
        print("[DEBUG] มี error => ${result["error"]}");
        setState(() {
          isLoading = false;
        });
        _showSnackBar(result["error"]);
      } else {
        double redeemedAmount =
            double.tryParse(result["amount_baht"].toString()) ?? 0.0;
        print("[DEBUG] redeemedAmount = $redeemedAmount");

        print("[DEBUG] กำลังดึงเอกสาร rentalDoc อีกรอบ...");
        DocumentSnapshot rentalDoc2 =
            await _firestore.collection('rentals').doc(widget.rentalId).get();
        if (rentalDoc2.exists) {
          var rentalData2 = rentalDoc2.data() as Map<String, dynamic>;
          double totalCost =
              double.tryParse(rentalData2["totalCost"].toString()) ?? 0.0;
          print("[DEBUG] totalCost = $totalCost");

          if (redeemedAmount == totalCost) {
            print(
                "[DEBUG] redeemedAmount == totalCost => proceed to update Firestore");
            String lessorId = rentalData2["lessorId"];
            print("[DEBUG] ค้นหา lessorId = $lessorId");
            DocumentSnapshot lessorDoc =
                await _firestore.collection('users').doc(lessorId).get();
            String lessorPhone = "";
            if (lessorDoc.exists) {
              var lessorData = lessorDoc.data() as Map<String, dynamic>;
              lessorPhone = lessorData["phone"] ?? "";
            }
            try {
              print("[DEBUG] กำลัง update Firestore => status = release");
              await _firestore
                  .collection('rentals')
                  .doc(widget.rentalId)
                  .update({
                "status": "release",
                "transferPhone": lessorPhone,
              });
              print("[DEBUG] update Firestore สำเร็จ");
              setState(() {
                isLoading = false;
              });
              _showSnackBar("🎉 โอนเงินสำเร็จ: ${redeemedAmount} บาท");
              // หลังจากโอนเงินสำเร็จ ให้กลับไปหน้าก่อนหน้า
              Navigator.pop(context);
            } catch (e) {
              print("[DEBUG] Firestore update error => $e");
              setState(() {
                isLoading = false;
              });
              _showSnackBar("อัปเดตสถานะไม่สำเร็จ: $e");
            }
          } else {
            print("[DEBUG] redeemedAmount != totalCost => show AlertDialog");
            setState(() {
              isLoading = false;
            });
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("แจ้งเตือน"),
                  content: Text(
                      "จำนวนเงินที่ได้รับ ($redeemedAmount บาท) ไม่ตรงกับจำนวนที่ต้องชำระ ($totalCost บาท)"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("ตกลง"),
                    ),
                  ],
                );
              },
            );
          }
        } else {
          print("[DEBUG] rentalDoc2.exists = false => ไม่พบข้อมูลการเช่า");
          setState(() {
            isLoading = false;
          });
          _showSnackBar("❌ ไม่พบข้อมูลการเช่า");
        }
      }
    } catch (e) {
      print("[DEBUG] เกิดข้อยกเว้นใน _redeemGift => $e");
      setState(() {
        isLoading = false;
      });
      _showSnackBar("❌ เกิดข้อผิดพลาด: $e");
    }
  }

  void _showSnackBar(String message) {
    print("[DEBUG] _showSnackBar => $message");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            message.contains("❌") ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("[DEBUG] build => isLoading=$isLoading");
    return Scaffold(
      appBar: AppBar(
        title: const Text("TrueWall"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _phoneController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "เบอร์โทรผู้ให้เช่า",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: "ลิงก์ซองของขวัญ",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _redeemGift,
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text("🎁 รับเงินจากซองของขวัญ"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Service สำหรับทำการ Redeem ซองของขวัญ TrueMoney
class TrueWalletService {
  Future<Map<String, dynamic>> redeemGift(
      String url, String phoneNumber) async {
    print(
        "[DEBUG] TrueWalletService.redeemGift => url=$url, phone=$phoneNumber");
    try {
      if (!isURL(url)) {
        print("[DEBUG] URL ไม่ถูกต้อง => $url");
        return {"error": "❌ URL ไม่ถูกต้อง"};
      }

      const String baseUrl = 'https://gift.truemoney.com/campaign/?v=';
      if (!url.startsWith(baseUrl)) {
        print("[DEBUG] ลิงก์ต้องอยู่ในรูปแบบ $baseUrl");
        return {"error": "❌ ลิงก์ต้องอยู่ในรูปแบบ: $baseUrl"};
      }

      final String voucherCode = url.split(baseUrl)[1];
      print("[DEBUG] voucherCode = $voucherCode");

      final String verifyUrl =
          'https://gift.truemoney.com/campaign/vouchers/$voucherCode/verify?mobile=$phoneNumber';
      print("[DEBUG] verifyUrl = $verifyUrl");
      final response = await http.get(Uri.parse(verifyUrl));
      print("[DEBUG] verify response.statusCode = ${response.statusCode}");

      if (response.statusCode != 200) {
        return {"error": "❌ ซองของขวัญไม่ถูกต้อง หรือหมดอายุ"};
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      print("[DEBUG] verify response.body = $data");
      if (!data.containsKey("data") || !data["data"].containsKey("voucher")) {
        return {"error": "❌ ข้อมูลซองของขวัญไม่ถูกต้อง"};
      }

      final giftAmount = data['data']['voucher']['amount_baht'];
      final available = data['data']['voucher']['available'];
      print("[DEBUG] giftAmount = $giftAmount, available = $available");

      if (available == 0) {
        return {"error": "❌ ซองของขวัญนี้หมดแล้ว"};
      }

      final String redeemUrl =
          'https://gift.truemoney.com/campaign/vouchers/$voucherCode/redeem';
      print("[DEBUG] redeemUrl = $redeemUrl");
      final Map<String, dynamic> body = {
        "mobile": phoneNumber,
        "voucher_hash": voucherCode
      };
      print("[DEBUG] redeem body = $body");

      final redeemResponse = await http.post(
        Uri.parse(redeemUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );
      print("[DEBUG] redeemResponse.statusCode = ${redeemResponse.statusCode}");

      if (redeemResponse.statusCode == 200) {
        return {
          "amount_baht": giftAmount,
          "message": "🎉 รับเงินสำเร็จ: ${giftAmount} บาท"
        };
      } else {
        return {"error": "❌ รับซองไม่สำเร็จ กรุณาลองใหม่"};
      }
    } catch (e) {
      print("[DEBUG] Exception in redeemGift => $e");
      return {"error": "❌ เกิดข้อผิดพลาด: ${e.toString()}"};
    }
  }
}
