import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrueWalletService {
  final String receiverPhoneNumber = "0982124588"; // เบอร์รับเงิน

  Future<Map<String, dynamic>> redeemGift(String url) async {
    try {
      if (!isURL(url)) {
        return {"error": "URL ไม่ถูกต้อง"};
      }

      const String baseUrl = 'https://gift.truemoney.com/campaign/?v=';
      if (!url.startsWith(baseUrl)) {
        return {"error": "ลิงก์ต้องอยู่ในรูปแบบ: $baseUrl"};
      }

      final String voucherCode = url.split(baseUrl)[1];
      final String verifyUrl =
          'https://gift.truemoney.com/campaign/vouchers/$voucherCode/verify?mobile=$receiverPhoneNumber';

      final response = await http.get(Uri.parse(verifyUrl));
      if (response.statusCode != 200) {
        return {"error": "ซองของขวัญไม่ถูกต้อง หรือหมดอายุ"};
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      if (!data.containsKey("data") || !data["data"].containsKey("voucher")) {
        return {"error": "ข้อมูลไม่ถูกต้อง หรือไม่มีซองของขวัญนี้"};
      }

      final giftAmount = data['data']['voucher']['amount_baht'];
      final giftStatus = data['data']['voucher']['status'];
      final available = data['data']['voucher']['available'];

      if (available == 0) {
        return {
          "amount_baht": giftAmount,
          "status": giftStatus,
          "available": available,
          "error": "ซองหมดแล้ว"
        };
      }

      final redeemUrl =
          'https://gift.truemoney.com/campaign/vouchers/$voucherCode/redeem';
      final Map<String, dynamic> body = {
        "mobile": receiverPhoneNumber,
        "voucher_hash": voucherCode
      };

      final redeemResponse = await http.post(
        Uri.parse(redeemUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      if (redeemResponse.statusCode == 200) {
        return {
          "amount_baht": giftAmount,
          "status": giftStatus,
          "available": available,
          "message": "รับซองสำเร็จ และโอนเข้าบัญชี"
        };
      } else {
        return {"error": "รับซองไม่สำเร็จ กรุณาลองใหม่"};
      }
    } catch (e) {
      return {"error": "เกิดข้อผิดพลาด: ${e.toString()}"};
    }
  }
}

void main() {
  runApp(const MaterialApp(
    home: TrialPage(),
  ));
}

class TrialPage extends StatefulWidget {
  const TrialPage({super.key});

  @override
  TrialPageState createState() => TrialPageState();
}

class TrialPageState extends State<TrialPage> {
  final TextEditingController _urlController = TextEditingController();
  final TrueWalletService _walletService = TrueWalletService();
  List<String> _logMessages = [];

  void _redeemGift() async {
    setState(() {
      _logMessages.clear(); // เคลียร์ log ก่อนเพิ่มข้อความใหม่
      _logMessages.add("กำลังตรวจสอบ...");
    });

    final result = await _walletService.redeemGift(_urlController.text);
    setState(() {
      if (result.containsKey("error")) {
        _logMessages.add("ข้อผิดพลาด: ${result["error"]}");
      } else {
        _logMessages.add("จำนวนเงิน: ${result["amount_baht"]} บาท");
        _logMessages.add("สถานะ: ${result["status"]}");
        _logMessages.add("ใช้ได้: ${result["available"]} ครั้ง");
        _logMessages.add("${result["message"]}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ทดลองใช้ TrueMoney Gift")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: "ลิงก์ซองของขวัญ",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _redeemGift,
              child: const Text("ทดลองรับเงิน"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _logMessages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      _logMessages[index],
                      style: const TextStyle(color: Colors.blue),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
