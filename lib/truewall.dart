import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:validators/validators.dart';

class TrueWalletService {
  final String receiverPhoneNumber = "0982124588"; // เบอร์รับเงิน

  Future<void> redeemGift(String url) async {
    if (!isURL(url)) {
      print('URL ไม่ถูกต้อง');
      return;
    }

    const String baseUrl = 'https://gift.truemoney.com/campaign/?v=';
    if (!url.startsWith(baseUrl)) {
      print('ลิงก์ต้องอยู่ในรูปแบบ: $baseUrl');
      return;
    }

    final String voucherCode = url.split(baseUrl)[1];
    final String verifyUrl =
        'https://gift.truemoney.com/campaign/vouchers/$voucherCode/verify?mobile=$receiverPhoneNumber';

    final response = await http.get(Uri.parse(verifyUrl));
    if (response.statusCode != 200) {
      print('ล้มเหลว: ซองไม่พบเจอ');
      return;
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final giftAmount = data['data']['voucher']['amount_baht'];
    final giftStatus = data['data']['voucher']['status'];
    final available = data['data']['voucher']['available'];

    print('จำนวนเงิน: $giftAmount บาท');
    print('สถานะ: $giftStatus');
    print('ใช้ได้: $available ครั้ง');

    if (available == 0) {
      print('ซองหมดแล้ว');
      return;
    }

    // ส่งคำขอรับเงิน
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
      print('รับซองสำเร็จ และโอนเข้าบัญชี $receiverPhoneNumber');
    } else {
      print('รับซองไม่สำเร็จ');
    }
  }
}
