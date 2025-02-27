/// แปลงเบอร์โทรศัพท์ไทยจากรูปแบบ "0956453648" เป็น E.164 เช่น "+66956453648"
String formatThaiPhone(String input) {
  String cleaned = input.replaceAll(RegExp(r'\D'), '');
  if (cleaned.startsWith('0')) {
    cleaned = cleaned.substring(1);
  }
  return '+66' + cleaned;
}
