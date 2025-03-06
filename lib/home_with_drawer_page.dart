import 'package:flutter/material.dart';
import 'login_page.dart'; // ให้แน่ใจว่า import หน้า login_page.dart แล้ว

class HomeWithDrawerPage extends StatefulWidget {
  const HomeWithDrawerPage({Key? key}) : super(key: key);

  @override
  _HomeWithDrawerPageState createState() => _HomeWithDrawerPageState();
}

class _HomeWithDrawerPageState extends State<HomeWithDrawerPage> {
  // GlobalKey สำหรับ Scaffold เพื่อเปิด/ปิด Drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ฟังก์ชันเมื่อกดปุ่ม "ออกจากระบบ"
  void _handleLogout() {
    debugPrint("ออกจากระบบแล้ว");
    // นำทางกลับไปยังหน้า login_page.dart โดยใช้ pushReplacement
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // ผูก GlobalKey กับ Scaffold
      appBar: AppBar(
        title: const Text("Home Page With Drawer"),
        backgroundColor: const Color(0xFF00377E),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // เมื่อกดเมนู ให้เปิด Drawer
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      // เนื้อหาหลักของหน้า
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ตัวอย่างเนื้อหาหลัก สามารถปรับเปลี่ยนให้เป็น UI ของคุณได้
            const Text(
              "เนื้อหาหลักของ Home Page",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            // ตัวอย่าง Card หรือ widget อื่นๆ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: const Text(
                "นี่คือส่วนของเนื้อหาหลักในหน้า Home Page With Drawer",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      // Drawer แบบ Overlay
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // Header ของ Drawer
              Container(
                color: const Color(0xFF00377E),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                width: double.infinity,
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 30, color: Color(0xFF00377E)),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Young Yuri",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // สามารถเพิ่ม email หรือข้อมูลอื่นๆ ได้
                      ],
                    ),
                  ],
                ),
              ),
              // รายการเมนูใน Drawer
              ListTile(
                leading: const Icon(Icons.home, color: Color(0xFF00377E)),
                title: const Text("หน้าหลัก"),
                onTap: () {
                  debugPrint("กดเมนูหน้าหลัก");
                  Navigator.pop(context); // ปิด Drawer
                  // TODO: นำทางไปหน้าหลัก
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on, color: Color(0xFF00377E)),
                title: const Text("แผนที่"),
                onTap: () {
                  debugPrint("กดเมนูแผนที่");
                  Navigator.pop(context);
                  // TODO: นำทางไปหน้าแผนที่
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt, color: Color(0xFF00377E)),
                title: const Text("รายการเช่าทั้งหมด"),
                onTap: () {
                  debugPrint("กดเมนูรายการเช่าทั้งหมด");
                  Navigator.pop(context);
                  // TODO: นำทางไปหน้ารายการเช่า
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline, color: Color(0xFF00377E)),
                title: const Text("การตั้งค่าบัญชี"),
                onTap: () {
                  debugPrint("กดเมนูการตั้งค่าบัญชี");
                  Navigator.pop(context);
                  // TODO: นำทางไปหน้าตั้งค่าบัญชี
                },
              ),
              const Spacer(),
              // ปุ่ม "ออกจากระบบ"
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    "ออกจากระบบ",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
