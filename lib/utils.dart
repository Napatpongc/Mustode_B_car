import 'dart:math';

/// แปลงเบอร์โทรศัพท์ไทยจากรูปแบบ "0956453648" เป็น "+66956453648" (E.164)
String formatThaiPhone(String input) {
  String cleaned = input.replaceAll(RegExp(r'\D'), '');
  if (cleaned.startsWith('0')) {
    cleaned = cleaned.substring(1);
  }
  return '+66$cleaned';
}

/// สุ่ม OTP 6 หลัก
String generateOTP() {
  final random = Random();
  int otp = random.nextInt(900000) + 100000; // ให้ได้ตัวเลข 6 หลัก
  return otp.toString();
}
