import 'dart:math';

/// แปลงเบอร์โทรศัพท์ไทยให้เป็นรูปแบบ "+66XXXXXXXXX" (E.164)
String formatThaiPhone(String input) {
  input = input.trim();
  if (input.startsWith('+66')) return input;
  String cleaned = input.replaceAll(RegExp(r'\D'), '');
  if (cleaned.startsWith('0')) {
    cleaned = cleaned.substring(1);
  }
  return '+66$cleaned';
}

/// สุ่ม OTP 6 หลัก
String generateOTP() {
  final random = Random();
  int otp = random.nextInt(900000) + 100000;
  return otp.toString();
}
