import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ProfileRenter.dart'; // สำหรับใช้ MyDrawerRenter

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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.blue.shade100,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              indicator: BoxDecoration(
                color: Colors.blue.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              tabs: const [
                Tab(text: "ล่าสุด"),
                Tab(text: "ประวัติ"),
              ],
            ),
          ),
        ),
      ),
      // --------------------------------------
      // เปลี่ยน Sidebar ให้เหมือน ProfileRenter.dart
      // --------------------------------------
      drawer: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Drawer(
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final username = data['username'] ?? 'ไม่มีชื่อ';
          final profileUrl = (data['image'] != null) ? data['image']['profile'] : null;
          final isGoogleLogin = FirebaseAuth.instance.currentUser!.providerData
              .any((p) => p.providerId == 'google.com');
          return MyDrawerRenter(
            username: username,
            isGoogleLogin: isGoogleLogin,
            profileUrl: profileUrl,
          );
        },
      ),
      // --------------------------------------
      // เนื้อหา TabBarView
      // --------------------------------------
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLatestTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // ส่วนของ Tab แรก "ล่าสุด"
  // ---------------------------------------------------
  Widget _buildLatestTab() {
    return ListView.builder(
      itemCount: 1, // สมมติว่ามี 1 รายการ
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: ListTile(
            leading: const Icon(Icons.car_rental, size: 40),
            title: const Text("Honda Jazz"),
            subtitle: const Text("สถานะ: กำลังเช่า"),
            onTap: () {
              // กดเพื่อดูรายละเอียดเพิ่มได้
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
    return ListView.builder(
      itemCount: 1, // สมมติว่ามี 1 รายการ
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: ListTile(
            leading: const Icon(Icons.car_rental, size: 40),
            title: const Text("Toyota Yaris"),
            subtitle: const Text("สถานะ: สำเร็จ"),
            onTap: () {
              // กดเพื่อดูรายละเอียดเพิ่มได้
            },
          ),
        );
      },
    );
  }
}
