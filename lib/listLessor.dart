import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ProfileLessor.dart'; // Import MyDrawer จาก ProfileLessor.dart

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
      // AppBar พร้อม TabBar
      // --------------------------------------
      appBar: AppBar(
        title: const Text("รายการเช่า"),
        centerTitle: true,
        backgroundColor: const Color(0xFF00377E),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            width: double.infinity,
            color: Colors.blue.shade100,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              isScrollable: false,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: const _HalfBarIndicator(),
              tabs: const [
                Tab(text: "ล่าสุด"),
                Tab(text: "ประวัติ"),
              ],
            ),
          ),
        ),
        actions: [
          // ปุ่มแจ้งเตือน
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // กำหนด action ของปุ่มนี้ได้ตามต้องการ
            },
          ),
        ],
      ),
      // --------------------------------------
      // Drawer โดยใช้ MyDrawer จาก ProfileLessor.dart
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
          return MyDrawer(
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
  // Tab "ล่าสุด" สำหรับผู้ปล่อยเช่า
  // ดึงข้อมูลทั้งหมดจาก 'rentals' แล้วคัดกรองในฝั่ง client:
  // - เฉพาะ document ที่มี lessorId ตรงกับ uid
  // - status ไม่เป็น "canceled", "successed" หรือ "done"
  // สำหรับแต่ละ rental, ใช้ field renterId ไปดึงข้อมูลผู้เช่าใน collection 'users'
  // แล้วเอา image.profile และ username มาแสดงแทนข้อมูลทะเบียนเดิม
  // ---------------------------------------------------
  Widget _buildLatestTab() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rentals').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        // คัดกรองข้อมูลในฝั่ง client
        final docs = snapshot.data!.docs.where((doc) {
          final rentalData = doc.data() as Map<String, dynamic>;
          return rentalData['lessorId'] == uid &&
              !(['canceled', 'successed', 'done'].contains(rentalData['status']));
        }).toList();

        if (docs.isEmpty) {
          return const Center(child: Text('ยังไม่มีรายการเช่าในขณะนี้'));
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final rentalDoc = docs[index];
            final rentalData = rentalDoc.data() as Map<String, dynamic>;
            final status = rentalData['status'] ?? '';
            final rentalStartTS = rentalData['rentalStart'] as Timestamp?;
            final rentalEndTS = rentalData['rentalEnd'] as Timestamp?;
            final rentalStart = rentalStartTS?.toDate();
            final rentalEnd = rentalEndTS?.toDate();
            final pickupLocation = rentalData['pickupLocation'] ?? '';
            final returnLocation = rentalData['returnLocation'] ?? '';
            // ดึงข้อมูลผู้เช่าจาก field renterId
            final renterId = rentalData['renterId'] ?? '';

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(renterId).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.hasError) {
                  return Card(
                    margin: const EdgeInsets.all(16),
                    child: ListTile(
                      title: Text("เกิดข้อผิดพลาดในการโหลดข้อมูลผู้เช่า: ${userSnapshot.error}"),
                    ),
                  );
                }
                if (!userSnapshot.hasData) {
                  return const Card(
                    margin: EdgeInsets.all(16),
                    child: ListTile(
                      title: Text("กำลังโหลดข้อมูลผู้เช่า..."),
                    ),
                  );
                }
                final userData = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                final renterName = userData['username'] ?? 'ไม่ระบุชื่อ';
                final profileImage = userData['image']?['profile'];

                return Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // แถวบนสุด: รูปโปรไฟล์ผู้เช่า + ชื่อผู้เช่า + สถานะ
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // รูปโปรไฟล์ผู้เช่า
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: (profileImage != null && profileImage != '')
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.network(
                                        profileImage,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.person, size: 40),
                            ),
                            const SizedBox(width: 16),
                            // ชื่อผู้เช่าและสถานะ
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    renterName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('สถานะ: $status'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        // ข้อมูลวันเวลา และสถานที่ รับ/คืน
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('รับรถ'),
                                if (pickupLocation.isNotEmpty) Text(pickupLocation),
                                if (rentalStart != null)
                                  Text(
                                    '${rentalStart.day.toString().padLeft(2, '0')}/${rentalStart.month.toString().padLeft(2, '0')}/${rentalStart.year} '
                                    '${rentalStart.hour.toString().padLeft(2, '0')}:${rentalStart.minute.toString().padLeft(2, '0')} น.',
                                  ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('คืนรถ'),
                                if (returnLocation.isNotEmpty) Text(returnLocation),
                                if (rentalEnd != null)
                                  Text(
                                    '${rentalEnd.day.toString().padLeft(2, '0')}/${rentalEnd.month.toString().padLeft(2, '0')}/${rentalEnd.year} '
                                    '${rentalEnd.hour.toString().padLeft(2, '0')}:${rentalEnd.minute.toString().padLeft(2, '0')} น.',
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // ปุ่ม "ดูรายละเอียด/สถานะ"
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: กดดูรายละเอียดหรือสถานะเพิ่มเติม
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00377E),
                            ),
                            child: const Text(
                              'ดูรายละเอียด / สถานะ',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------
  // Tab "ประวัติ" สำหรับผู้ปล่อยเช่า
  // ดึงข้อมูลทั้งหมดจาก 'rentals' แล้วคัดกรองในฝั่ง client:
  // - เฉพาะ document ที่มี lessorId ตรงกับ uid
  // - status เป็น "canceled", "successed" หรือ "done"
  // สำหรับแต่ละ rental, ใช้ field renterId ไปดึงข้อมูลผู้เช่าใน collection 'users'
  // แล้วเอา image.profile และ username มาแสดงแทนข้อมูลทะเบียนเดิม
  // (ใน segment นี้จะไม่มีปุ่มรีวิว)
  // ---------------------------------------------------
  Widget _buildHistoryTab() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('rentals').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs.where((doc) {
          final rentalData = doc.data() as Map<String, dynamic>;
          return rentalData['lessorId'] == uid &&
              (['canceled', 'successed', 'done'].contains(rentalData['status']));
        }).toList();
        if (docs.isEmpty) {
          return const Center(child: Text('ยังไม่มีประวัติการเช่า'));
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final rentalDoc = docs[index];
            final rentalData = rentalDoc.data() as Map<String, dynamic>;
            final status = rentalData['status'] ?? '';
            final rentalStartTS = rentalData['rentalStart'] as Timestamp?;
            final rentalEndTS = rentalData['rentalEnd'] as Timestamp?;
            final rentalStart = rentalStartTS?.toDate();
            final rentalEnd = rentalEndTS?.toDate();
            final pickupLocation = rentalData['pickupLocation'] ?? '';
            final returnLocation = rentalData['returnLocation'] ?? '';
            // ดึงข้อมูลผู้เช่าจาก field renterId
            final renterId = rentalData['renterId'] ?? '';

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(renterId).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.hasError) {
                  return Card(
                    margin: const EdgeInsets.all(16),
                    child: ListTile(
                      title: Text("เกิดข้อผิดพลาดในการโหลดข้อมูลผู้เช่า: ${userSnapshot.error}"),
                    ),
                  );
                }
                if (!userSnapshot.hasData) {
                  return const Card(
                    margin: EdgeInsets.all(16),
                    child: ListTile(
                      title: Text("กำลังโหลดข้อมูลผู้เช่า..."),
                    ),
                  );
                }
                final userData = userSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                final renterName = userData['username'] ?? 'ไม่ระบุชื่อ';
                final profileImage = userData['image']?['profile'];

                return Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // แถวบนสุด: รูปโปรไฟล์ผู้เช่า + ชื่อผู้เช่า + สถานะ
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: (profileImage != null && profileImage != '')
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.network(
                                        profileImage,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.person, size: 40),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    renterName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('สถานะ: $status'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        // ข้อมูลวันเวลา และสถานที่ รับ/คืน
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('รับรถ'),
                                if (pickupLocation.isNotEmpty) Text(pickupLocation),
                                if (rentalStart != null)
                                  Text(
                                    '${rentalStart.day.toString().padLeft(2, '0')}/${rentalStart.month.toString().padLeft(2, '0')}/${rentalStart.year} '
                                    '${rentalStart.hour.toString().padLeft(2, '0')}:${rentalStart.minute.toString().padLeft(2, '0')} น.',
                                  ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('คืนรถ'),
                                if (returnLocation.isNotEmpty) Text(returnLocation),
                                if (rentalEnd != null)
                                  Text(
                                    '${rentalEnd.day.toString().padLeft(2, '0')}/${rentalEnd.month.toString().padLeft(2, '0')}/${rentalEnd.year} '
                                    '${rentalEnd.hour.toString().padLeft(2, '0')}:${rentalEnd.minute.toString().padLeft(2, '0')} น.',
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------
// คลาส Decoration + Painter สำหรับทำ Indicator กินพื้นที่ "ครึ่งหนึ่งของหน้าจอ"
// ---------------------------------------------------------------------
class _HalfBarIndicator extends Decoration {
  const _HalfBarIndicator();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _HalfBarPainter();
  }
}

class _HalfBarPainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()..color = Colors.blue.shade300;
    final tabWidth = configuration.size!.width;
    final tabHeight = configuration.size!.height;
    final rect = Rect.fromLTWH(offset.dx, offset.dy, tabWidth, tabHeight);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(rrect, paint);
  }
}
