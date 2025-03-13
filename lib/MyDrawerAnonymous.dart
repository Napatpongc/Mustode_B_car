import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'map_forsidebar.dart';
import 'signup_page.dart';
import 'home_page.dart';
import 'map.dart';
import 'login_page.dart';

// ใช้ค่าสีที่ประกาศไว้ในโปรเจกต์ (หรือประกาศใหม่ได้ตามต้องการ)
const Color kDarkBlue = Color(0xFF050C9C);

class MyDrawerAnonymous extends StatelessWidget {
  const MyDrawerAnonymous({Key? key}) : super(key: key);

  // ฟังก์ชันแสดง Overlay (AlertDialog) เมื่อ Anonymous กดเมนูที่ต้องสมัครสมาชิก
  void _showOverlay(BuildContext mainContext) {
    showDialog(
      context: mainContext,
      barrierDismissible: true, // ให้แตะพื้นที่ว่างเพื่อปิดได้
      builder: (dialogContext) => AlertDialog(
        title: const Text("โปรดสมัครบัญชีเพื่อทำรายการนี้"),
        content:
            const Text("คุณจำเป็นต้องสมัครสมาชิกก่อนจึงจะทำรายการนี้ได้"),
        actions: [
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: kDarkBlue),
            accountName: Text(
              "Anonymous user",
              style: TextStyle(fontSize: 16),
            ),
            accountEmail: null,
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.grey),
            ),
          ),
          // เมนู "หน้าหลัก"
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('หน้าหลัก'),
            onTap: () {
              Navigator.pop(context); // ปิด Drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
          ),
          // เมนู "แผนที่"
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('แผนที่'),
            onTap: () {
              Navigator.pop(context); // ปิด Drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MapScreen()),
              );
            },
          ),
          // เมนู "รายการเช่าทั้งหมด" ที่ถูกจำกัดสำหรับ Anonymous
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('รายการเช่าทั้งหมด'),
            onTap: () {
              Navigator.pop(context); // ปิด Drawer
              _showOverlay(context);
            },
          ),
          // เมนู "ตั้งค่าบัญชี" ที่ถูกจำกัดสำหรับ Anonymous
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('ตั้งค่าบัญชี'),
            onTap: () {
              Navigator.pop(context); // ปิด Drawer
              _showOverlay(context);
            },
          ),
          const Spacer(),
          // ปุ่ม "ออกจากระบบ" สำหรับ Anonymous
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'ออกจากระบบ',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
