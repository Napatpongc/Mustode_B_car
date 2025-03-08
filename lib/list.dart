import 'package:flutter/material.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --------------------------------------
      // AppBar + side bar (Drawer)
      // --------------------------------------
      appBar: AppBar(
        title: const Text("รายการเช่า"),
        centerTitle: true,
        backgroundColor: const Color(0xFF00377E),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "ล่าสุด"),
            Tab(text: "ประวัติ"),
          ],
        ),
      ),
      drawer: Drawer(
        // side bar ที่ยังกดไม่ได้
        child: ListView(
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                "Side Bar",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              title: Text("เมนูยังไม่พร้อมใช้งาน"),
            ),
          ],
        ),
      ),
      // --------------------------------------
      // เนื้อหา TabBarView
      // --------------------------------------
      body: TabBarView(
        controller: _tabController,
        children: [
          // -----------------------
          // Tab 1: ล่าสุด
          // -----------------------
          _buildLatestTab(),

          // -----------------------
          // Tab 2: ประวัติ
          // -----------------------
          _buildHistoryTab(),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // ส่วนของ Tab แรก "ล่าสุด"
  // ---------------------------------------------------
  Widget _buildLatestTab() {
    // ตัวอย่าง ListView รถที่กำลังเช่า
    // (ปรับตามโครงสร้างจริงของคุณ)
    return ListView.builder(
      itemCount: 1, // สมมติว่าเรามี 1 รายการ
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: ListTile(
            leading: const Icon(Icons.car_rental, size: 40),
            title: const Text("Honda Jazz"),
            subtitle: const Text("สถานะ: กำลังเช่า"),
            onTap: () {
              // กดเพื่อดูรายละเอียดเพิ่มได้ (ถ้าต้องการ)
            },
          ),
        );
      },
    );
  }

  // ---------------------------------------------------
  // ส่วนของ Tab สอง "ประวัติ"
  // ---------------------------------------------------
  Widget _buildHistoryTab() {
    // ตัวอย่าง ListView ประวัติการเช่า
    return ListView.builder(
      itemCount: 1, // สมมติว่าเรามี 1 รายการ
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: ListTile(
            leading: const Icon(Icons.car_rental, size: 40),
            title: const Text("Toyota Yaris"),
            subtitle: const Text("สถานะ: สำเร็จ"),
            onTap: () {
              // กดเพื่อดูรายละเอียดเพิ่มได้ (ถ้าต้องการ)
            },
          ),
        );
      },
    );
  }
}
