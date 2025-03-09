import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ProfileRenter.dart'; // ไฟล์ Drawer (sidebar) ของคุณ
import 'CarReviewPage.dart'; // import หน้ารีวิวรถ

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage>
    with SingleTickerProviderStateMixin {
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
            width: double.infinity,
            color: Colors.blue.shade100,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              isScrollable: false,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: _HalfBarIndicator(), // ใช้ custom Indicator
              tabs: const [
                Tab(text: "ล่าสุด"),
                Tab(text: "ประวัติ"),
              ],
            ),
          ),
        ),
      ),
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
          final profileUrl =
              (data['image'] != null) ? data['image']['profile'] : null;
          final isGoogleLogin = FirebaseAuth.instance.currentUser!.providerData
              .any((p) => p.providerId == 'google.com');
          return MyDrawerRenter(
            username: username,
            isGoogleLogin: isGoogleLogin,
            profileUrl: profileUrl,
          );
        },
      ),
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
  //  - แสดงเฉพาะ status: ['pending', 'approved', 'ongoing']
  // ---------------------------------------------------
  Widget _buildLatestTab() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rentals')
          .where('renterId', isEqualTo: uid)
          .where('status',
              whereIn: ['pending', 'approved', 'ongoing']).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('ยังไม่มีรายการเช่าในขณะนี้'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final rentalDoc = docs[index];
            final rentalData = rentalDoc.data() as Map<String, dynamic>;

            final carId = rentalData['carId'] ?? '';
            final status = rentalData['status'] ?? '';
            final rentalStartTS = rentalData['rentalStart'] as Timestamp?;
            final rentalEndTS = rentalData['rentalEnd'] as Timestamp?;
            final rentalStart = rentalStartTS?.toDate();
            final rentalEnd = rentalEndTS?.toDate();
            final pickupLocation = rentalData['pickupLocation'] ?? '';
            final returnLocation = rentalData['returnLocation'] ?? '';

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('cars')
                  .doc(carId)
                  .get(),
              builder: (context, carSnapshot) {
                if (carSnapshot.hasError) {
                  return Card(
                    margin: const EdgeInsets.all(16),
                    child: ListTile(
                      title: Text(
                          "เกิดข้อผิดพลาดในการโหลดข้อมูลรถ: ${carSnapshot.error}"),
                    ),
                  );
                }
                if (!carSnapshot.hasData) {
                  return const Card(
                    margin: EdgeInsets.all(16),
                    child: ListTile(
                      title: Text("กำลังโหลดข้อมูลรถ..."),
                    ),
                  );
                }

                final carData =
                    carSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                final brand = carData['brand'] ?? '';
                final carFront = carData['image']?['carfront'];
                final carReg = carData['Car registration'] ?? '';

                return Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // แถวบนสุด: รูปรถ + ยี่ห้อ + ทะเบียน + สถานะ
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: (carFront != null && carFront != '')
                                  ? Image.network(carFront, fit: BoxFit.cover)
                                  : const Icon(Icons.car_rental, size: 40),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    brand,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('ทะเบียน: $carReg'),
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
                            // รับรถ
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('รับรถ'),
                                if (pickupLocation.isNotEmpty)
                                  Text(pickupLocation),
                                if (rentalStart != null)
                                  Text(
                                    '${rentalStart.day.toString().padLeft(2, '0')}/${rentalStart.month.toString().padLeft(2, '0')}/${rentalStart.year} '
                                    '${rentalStart.hour.toString().padLeft(2, '0')}:${rentalStart.minute.toString().padLeft(2, '0')} น.',
                                  ),
                              ],
                            ),
                            // คืนรถ
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('คืนรถ'),
                                if (returnLocation.isNotEmpty)
                                  Text(returnLocation),
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
                        // ปุ่ม "ดูรายละเอียด / สถานะ"
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: กดเพื่อดูรายละเอียด / สถานะเพิ่มเติม
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
  // ส่วนของ Tab สอง "ประวัติ"
  //  - แสดงเฉพาะ status: ['canceled', 'successed', 'done']
  // ---------------------------------------------------
  Widget _buildHistoryTab() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rentals')
          .where('renterId', isEqualTo: uid)
          .where('status',
              whereIn: ['canceled', 'successed', 'done']).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('ยังไม่มีประวัติการเช่า'));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final rentalDoc = docs[index];
            final rentalData = rentalDoc.data() as Map<String, dynamic>;

            final carId = rentalData['carId'] ?? '';
            final status = rentalData['status'] ?? '';
            final rentalStartTS = rentalData['rentalStart'] as Timestamp?;
            final rentalEndTS = rentalData['rentalEnd'] as Timestamp?;
            final rentalStart = rentalStartTS?.toDate();
            final rentalEnd = rentalEndTS?.toDate();
            final pickupLocation = rentalData['pickupLocation'] ?? '';
            final returnLocation = rentalData['returnLocation'] ?? '';

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('cars')
                  .doc(carId)
                  .get(),
              builder: (context, carSnapshot) {
                if (carSnapshot.hasError) {
                  return Card(
                    margin: const EdgeInsets.all(16),
                    child: ListTile(
                      title: Text(
                          "เกิดข้อผิดพลาดในการโหลดข้อมูลรถ: ${carSnapshot.error}"),
                    ),
                  );
                }
                if (!carSnapshot.hasData) {
                  return const Card(
                    margin: EdgeInsets.all(16),
                    child: ListTile(
                      title: Text("กำลังโหลดข้อมูลรถ..."),
                    ),
                  );
                }

                final carData =
                    carSnapshot.data!.data() as Map<String, dynamic>? ?? {};
                final brand = carData['brand'] ?? '';
                final carFront = carData['image']?['carfront'];
                final carReg = carData['Car registration'] ?? '';

                // ถ้า status เป็น 'done' หรือ 'canceled' => ปุ่มรีวิวจะกดไม่ได้
                // ถ้า status เป็น 'successed' => ปุ่มรีวิวจะกดได้
                final isReviewable = (status == 'successed');

                return Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // รูปรถ + ข้อมูลรถ
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: (carFront != null && carFront != '')
                                  ? Image.network(carFront, fit: BoxFit.cover)
                                  : const Icon(Icons.car_rental, size: 40),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    brand,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('ทะเบียน: $carReg'),
                                  const SizedBox(height: 4),
                                  Text('สถานะ: $status'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        // วันเวลา และสถานที่ รับ/คืน
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // รับรถ
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('รับรถ'),
                                if (pickupLocation.isNotEmpty)
                                  Text(pickupLocation),
                                if (rentalStart != null)
                                  Text(
                                    '${rentalStart.day.toString().padLeft(2, '0')}/${rentalStart.month.toString().padLeft(2, '0')}/${rentalStart.year} '
                                    '${rentalStart.hour.toString().padLeft(2, '0')}:${rentalStart.minute.toString().padLeft(2, '0')} น.',
                                  ),
                              ],
                            ),
                            // คืนรถ
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('คืนรถ'),
                                if (returnLocation.isNotEmpty)
                                  Text(returnLocation),
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
                        // ปุ่ม "รีวิว"
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isReviewable
                                ? () {
                                    // ถ้า status == 'successed' ถึงจะกดรีวิวได้
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CarReviewPage(
                                          carDocumentId: carId,
                                          rentalDocId: rentalDoc.id,
                                        ),
                                      ),
                                    );
                                  }
                                : null, // ถ้า status == 'done' หรือ 'canceled' => กดไม่ได้
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isReviewable
                                  ? const Color(0xFF00377E)
                                  : Colors.grey,
                            ),
                            child: Text(
                              (status == 'done')
                                  ? 'รีวิวแล้ว'
                                  : (status == 'canceled')
                                      ? 'ถูกยกเลิก'
                                      : 'รีวิว',
                              style: const TextStyle(color: Colors.white),
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

    // แต่ละแท็บจะมี size เป็นครึ่งจอ (เพราะมี 2 แท็บแบบ isScrollable=false)
    // ดังนั้น width นี่คือ "ครึ่งหนึ่งของความกว้างทั้งหมด" แล้ว
    final tabWidth = configuration.size!.width;
    final tabHeight = configuration.size!.height;

    final rect = Rect.fromLTWH(offset.dx, offset.dy, tabWidth, tabHeight);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));

    canvas.drawRRect(rrect, paint);
  }
}
