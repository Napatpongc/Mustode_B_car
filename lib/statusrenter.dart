import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class StatusRenter extends StatefulWidget {
  final String rentalId;

  const StatusRenter({Key? key, required this.rentalId}) : super(key: key);

  @override
  _StatusRenterState createState() => _StatusRenterState();
}

class _StatusRenterState extends State<StatusRenter> {
  /// -----------------------------------------------------------------
  /// ฟังก์ชันกำหนดลำดับขั้นตอน (Steps) ตาม status
  /// -----------------------------------------------------------------
  /// มี 5 สเต็ป:
  ///  1) รอติดต่อกลับ  (pending)
  ///  2) ชำระเงิน       (waitpayment)
  ///  3) อยู่ระหว่างการใช้รถ (release, recieve => index=2) -> ongoing => index=3
  ///  4) รอยืนยันเสร็จสิ้นใช้รถ (end => index=4)
  ///  5) เสร็จสิ้นการใช้รถ
  ///
  /// ขั้นที่ผ่านแล้ว -> สีเขียว
  /// ขั้นปัจจุบัน -> สีเหลือง
  ///
  /// เพิ่มเงื่อนไข:
  ///  - เมื่อ status = successed => ทุกสเต็ปเป็นสีเขียว
  ///  - เมื่อ status = canceled  => ถ้าสต็ปไหนเป็นสีเหลือง ให้เปลี่ยนเป็นสีแดง
  ///
  List<Map<String, dynamic>> buildSteps(String status) {
    final steps = [
      {"text": "รอติดต่อกลับ", "color": Colors.grey},
      {"text": "ชำระเงิน", "color": Colors.grey},
      {"text": "อยู่ระหว่างการใช้รถ", "color": Colors.grey},
      {"text": "รอยืนยันเสร็จสิ้นใช้รถ", "color": Colors.grey},
      {"text": "เสร็จสิ้นการใช้รถ", "color": Colors.grey},
    ];

    // ฟังก์ชันเพื่อไฮไลท์ขั้นปัจจุบันเป็นสีเหลือง และขั้นก่อนหน้าทั้งหมดเป็นสีเขียว
    void markStepActive(int indexActive) {
      for (int i = 0; i < indexActive; i++) {
        steps[i]["color"] = Colors.green; // ขั้นที่ผ่านแล้วเป็นสีเขียว
      }
      steps[indexActive]["color"] = Colors.yellow; // ขั้นปัจจุบันเป็นสีเหลือง
    }

    // ---- กรณี status = successed => ทุกสเต็ปเป็นสีเขียว ----
    if (status == "successed") {
      for (int i = 0; i < steps.length; i++) {
        steps[i]["color"] = Colors.green;
      }
      return steps;
    }

    // ---- กรณี status = canceled => ทำ logic ตามปกติก่อน แล้วค่อยเปลี่ยนเหลืองเป็นแดง ----
    if (status == "canceled") {
      final originalStatus = getOriginalStatusBeforeCancel(); // สมมติ
      switch (originalStatus) {
        case "pending":
          markStepActive(0);
          break;
        case "waitpayment":
          markStepActive(1);
          break;
        case "release":
        case "recieve":
          markStepActive(2);
          break;
        case "ongoing":
          markStepActive(3);
          break;
        case "end":
          markStepActive(4);
          break;
        default:
          markStepActive(0);
          break;
      }
      for (int i = 0; i < steps.length; i++) {
        if (steps[i]["color"] == Colors.yellow) {
          steps[i]["color"] = Colors.red;
        }
      }
      return steps;
    }

    // ---- กรณีสถานะอื่น ๆ ตาม logic เดิม ----
    switch (status) {
      case "pending":
        markStepActive(0);
        break;
      case "waitpayment":
        markStepActive(1);
        break;
      case "release":
      case "recieve":
        markStepActive(2);
        break;
      case "ongoing":
        markStepActive(3);
        break;
      case "end":
        markStepActive(4);
        break;
      default:
        markStepActive(0);
        break;
    }
    return steps;
  }

  /// ฟังก์ชันสมมติไว้ว่า ถ้า canceled มาจากขั้น pending
  /// (ถ้าอยากให้ตรงตามจริง อาจต้องเก็บ oldStatus ไว้ก่อนเปลี่ยนเป็น canceled)
  String getOriginalStatusBeforeCancel() {
    return "pending";
  }

  /// ฟังก์ชันสร้าง UI แบบ Dynamic ตามค่า status
  Widget buildDynamicComponent(String status) {
    switch (status) {
      case 'pending':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            const SizedBox(height: 8),
            const Text("กำลังรอติดต่อกลับ...", style: TextStyle(fontSize: 16)),
          ],
        );
      case 'waitpayment':
        return WaitPaymentComponent(rentalId: widget.rentalId);
      case 'release':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("เมื่อถึงวัน-เวลารับรถ กรุณามาถึงเวลาตามนัดที่กำหนด", style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            const Text("เมื่อผู้ปล่อยเช่ายืนยันส่งมอบรถ กรุณากดปุ่มยืนยันรับรถ", style: TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            // ปุ่มยืนยันรับรถในกรณี release ยังคงแสดงปุ่ม disabled
            ElevatedButton(
              onPressed: null,
              child: const Text("ยืนยันรับรถ", style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      case 'recieve':
        // เมื่อกดปุ่ม "ยืนยันรับรถ" ให้แสดง overlay dialog เพื่อยืนยันอีกครั้ง
        return RecieveComponent(rentalId: widget.rentalId);
      case 'ongoing':
        // เมื่อกดปุ่ม "ขอสิ้นสุดการเช่ารถ" ให้แสดง overlay dialog
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("ยืนยันการสิ้นสุดการเช่า"),
                          content: const Text("กดตกลงอีกครั้งเพื่อยืนยันการสิ้นสุดการเช่ารถ"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("ย้อนกลับ"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("ตกลง"),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirm == true) {
                      await FirebaseFirestore.instance
                          .collection('rentals')
                          .doc(widget.rentalId)
                          .update({'status': 'end'});
                    }
                  },
                  child: const Text("ขอสิ้นสุดการเช่ารถ", style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: () {
                    // ปุ่มที่สอง (เช่น "ติดต่อเจ้าหน้าที่") ไม่ได้ทำอะไร
                  },
                  child: const Text("ติดต่อเจ้าหน้าที่", style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        );
      case 'end':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            const SizedBox(height: 8),
            const Text("กำลังยืนยันสิ้นสุดการใช้รถ...", style: TextStyle(fontSize: 16)),
          ],
        );
      case 'successed':
        return ElevatedButton(
          onPressed: null,
          child: const Text("รีวิว", style: TextStyle(fontSize: 16)),
        );
      case 'canceled':
        return const Text(
          "ยกเลิก",
          style: TextStyle(
            fontSize: 20,
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rentals')
          .doc(widget.rentalId)
          .snapshots(),
      builder: (context, rentalSnap) {
        if (rentalSnap.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("รายละเอียด / สถานะ"),
              centerTitle: true,
              backgroundColor: const Color(0xFF00377E),
            ),
            body: Center(
              child: Text("เกิดข้อผิดพลาดในการดึงข้อมูล: ${rentalSnap.error}"),
            ),
          );
        }
        if (!rentalSnap.hasData || !rentalSnap.data!.exists) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("รายละเอียด / สถานะ"),
              centerTitle: true,
              backgroundColor: const Color(0xFF00377E),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final rentalData =
            rentalSnap.data!.data() as Map<String, dynamic>? ?? {};
        final status = rentalData['status'] ?? 'pending';
        final lessorId = rentalData['lessorId'] ?? '';
        final carId = rentalData['carId'] ?? '';
        final steps = buildSteps(status);

        final rentalStartTS = rentalData['rentalStart'] as Timestamp?;
        final rentalEndTS = rentalData['rentalEnd'] as Timestamp?;
        final rentalStart = rentalStartTS?.toDate();
        final rentalEnd = rentalEndTS?.toDate();

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(lessorId)
              .get(),
          builder: (context, lessorSnap) {
            if (lessorSnap.hasError) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text("รายละเอียด / สถานะ"),
                  centerTitle: true,
                  backgroundColor: const Color(0xFF00377E),
                ),
                body: Center(
                  child: Text("เกิดข้อผิดพลาดในการดึงข้อมูลผู้ให้เช่า: ${lessorSnap.error}"),
                ),
              );
            }
            if (!lessorSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final lessorData =
                lessorSnap.data!.data() as Map<String, dynamic>? ?? {};

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('cars')
                  .doc(carId)
                  .get(),
              builder: (context, carSnap) {
                if (carSnap.hasError) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text("รายละเอียด / สถานะ"),
                      centerTitle: true,
                      backgroundColor: const Color(0xFF00377E),
                    ),
                    body: Center(
                      child: Text("เกิดข้อผิดพลาดในการดึงข้อมูลรถ: ${carSnap.error}"),
                    ),
                  );
                }
                if (!carSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final carData =
                    carSnap.data!.data() as Map<String, dynamic>? ?? {};

                return buildStatusUI(
                  context: context,
                  rentalData: rentalData,
                  lessorData: lessorData,
                  carData: carData,
                  steps: steps,
                  rentalStart: rentalStart,
                  rentalEnd: rentalEnd,
                );
              },
            );
          },
        );
      },
    );
  }

  /// สร้าง UI หลัก เมื่อได้ rentalData, lessorData, carData ครบ
  Widget buildStatusUI({
    required BuildContext context,
    required Map<String, dynamic> rentalData,
    required Map<String, dynamic> lessorData,
    required Map<String, dynamic> carData,
    required List<Map<String, dynamic>> steps,
    DateTime? rentalStart,
    DateTime? rentalEnd,
  }) {
    // ข้อมูลผู้ให้เช่า
    final lessorName = lessorData['username'] ?? '---';
    final lessorEmail = lessorData['email'] ?? '---';
    final lessorPhone = lessorData['phone'] ?? '---';
    final lessorProfile = (lessorData['image'] != null)
        ? lessorData['image']['profile']
        : null;

    // ข้อมูลรถ
    final brand = carData['brand'] ?? '---';
    final model = carData['model'] ?? '';
    final carfront = carData['image']?['carfront'];
    final detail = carData['detail'] ?? {};
    final vehicleType = detail['Vehicle'] ?? '---';
    final gear = detail['gear'] ?? '---';
    final seat = detail['seat']?.toString() ?? '---';
    final fuel = detail['fuel'] ?? '---';
    final door = detail['door']?.toString() ?? '---';
    final engine = detail['engine'] ?? '---';
    final baggage = detail['baggage'] ?? '---';

    // คำนวณราคา
    final dailyPrice = carData['price'] ?? 0;
    final days = (rentalStart != null && rentalEnd != null)
        ? rentalEnd.difference(rentalStart).inDays
        : 1;
    final deposit = (dailyPrice * 0.15).round();
    final total = (dailyPrice * days) + deposit;

    // เงื่อนไขสำหรับปุ่ม "ยกเลิก"
    // ปุ่ม "ยกเลิก" จะ active ได้เฉพาะเมื่อ status เป็น pending, waitpayment, release
    final allowedCancelStatuses = ['pending', 'waitpayment', 'release'];
    final canCancel = allowedCancelStatuses.contains(rentalData['status']);

    return Scaffold(
      appBar: AppBar(
        title: const Text("รายละเอียด / สถานะ"),
        centerTitle: true,
        backgroundColor: const Color(0xFF00377E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------------------
            // สถานะ (Steps)
            // ------------------------------
            const Text(
              'สถานะ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(width: double.infinity, height: 1, color: Colors.grey[300]),
            const SizedBox(height: 8),
            for (int i = 0; i < steps.length; i++)
              _buildStepItem(steps[i]['text'], steps[i]['color']),
            const SizedBox(height: 16),
            Container(width: double.infinity, height: 1, color: Colors.grey[300]),

            // ------------------------------
            // ส่วน Dynamic (เปลี่ยนตาม status)
            // ------------------------------
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Center(
                child: buildDynamicComponent(rentalData['status'] ?? 'pending'),
              ),
            ),

            // ------------------------------
            // รายละเอียดผู้ให้เช่า
            // ------------------------------
            const SizedBox(height: 20),
            const Text('รายละเอียดผู้ให้เช่า',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            Container(width: double.infinity, height: 1, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      (lessorProfile != null && lessorProfile != '')
                          ? NetworkImage(lessorProfile)
                          : null,
                  child: (lessorProfile == null || lessorProfile == '')
                      ? const Icon(Icons.person, size: 30, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _iconText(Icons.person, lessorName),
                      const SizedBox(height: 5),
                      _iconText(Icons.email, lessorEmail),
                      const SizedBox(height: 5),
                      _iconText(Icons.phone, lessorPhone),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(width: double.infinity, height: 9, color: Colors.grey[300]),

            // ------------------------------
            // ข้อมูลการเช่ารถ
            // ------------------------------
            const SizedBox(height: 10),
            const Text(
              'ข้อมูลการเช่ารถ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                image: (carfront != null && carfront != '')
                    ? DecorationImage(
                        image: NetworkImage(carfront), fit: BoxFit.cover)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "$brand $model",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 20,
              runSpacing: 10,
              children: [
                _carFeature(Icons.directions_car, "ประเภทรถ", vehicleType),
                _carFeature(Icons.settings, "ระบบเกียร์", gear),
                _carFeature(Icons.event_seat, "จำนวนที่นั่ง", seat),
                _carFeature(Icons.local_gas_station, "เชื้อเพลิง", fuel),
                _carFeature(Icons.meeting_room, "ประตู", door),
                _carFeature(Icons.speed, "เครื่องยนต์", engine),
                _carFeature(Icons.luggage, "สัมภาระ", baggage),
              ],
            ),
            const SizedBox(height: 20),
            const Text('รายละเอียดการรับ-คืนรถ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            Container(width: double.infinity, height: 1, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRentalInfo(
                  "รับรถ",
                  rentalStart,
                  rentalData['pickupLocation'] ?? '---',
                ),
                Container(width: 1, height: 100, color: Colors.grey[400]),
                _buildRentalInfo(
                  "คืนรถ",
                  rentalEnd,
                  rentalData['returnLocation'] ?? '---',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(width: double.infinity, height: 1, color: Colors.grey[300]),
            const SizedBox(height: 20),
            const Text(
              'ค่าเช่ารถ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('$brand $model',
                      style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  Text('- รายต่อวัน ฿$dailyPrice x $days วัน',
                      style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ]),
                Text(
                  '฿${dailyPrice * days}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text('ค่ามัดจำ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('- มัดจำ',
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
                Text(
                  '฿$deposit',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF0C5),
                borderRadius: BorderRadius.circular(3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x3F000000),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ทั้งหมด',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '฿$total',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // ปุ่มยกเลิก (Cancel)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: canCancel
                    ? () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("ยืนยันการยกเลิก"),
                              content: const Text("กรุณากดตกลงเพื่อยืนยันการยกเลิก"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text("ย้อนกลับ"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("ตกลง"),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirm == true) {
                          await FirebaseFirestore.instance
                              .collection('rentals')
                              .doc(widget.rentalId)
                              .update({'status': 'canceled'});
                        }
                      }
                    : null,
                child: const Text('ยกเลิก', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// แสดงแต่ละ step พร้อมสี
  Widget _buildStepItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          CircleAvatar(radius: 6, backgroundColor: color),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 15, color: Colors.black)),
        ],
      ),
    );
  }

  /// สร้าง widget แสดง icon + text
  Widget _iconText(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black),
        const SizedBox(width: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black),
        ),
      ],
    );
  }

  /// แสดง feature ของรถ (icon + label + value)
  Widget _carFeature(IconData icon, String label, String value) {
    return SizedBox(
      width: 160,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF00377E),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      const TextStyle(color: Color(0xFF8F8F8F), fontSize: 14)),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// แสดงข้อมูลวันเวลา + สถานที่ รับ/คืน
  Widget _buildRentalInfo(String label, DateTime? dateTime, String location) {
    String dateStr = '---';
    String timeStr = '---';
    if (dateTime != null) {
      dateStr =
          '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
      timeStr =
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} น.';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 5),
        Text(dateStr, style: const TextStyle(color: Colors.black, fontSize: 14)),
        const SizedBox(height: 2),
        Text(timeStr, style: const TextStyle(color: Colors.black, fontSize: 14)),
        const SizedBox(height: 2),
        Text(location, style: const TextStyle(color: Colors.black, fontSize: 14)),
      ],
    );
  }
}

/// Widget สำหรับสถานะ "waitpayment" โดยมี countdown timer 3 ชั่วโมง
/// เมื่อเอกสาร rentals/{rentalId} ไม่มี field 'waitUntil' จะบันทึก waitUntil = currentTime + 3 ชั่วโมง
/// เมื่อเวลาถอยหลังหมดและหาก status ยังคงเป็น 'waitpayment' จะอัปเดต status เป็น 'canceled'
class WaitPaymentComponent extends StatefulWidget {
  final String rentalId;
  const WaitPaymentComponent({Key? key, required this.rentalId}) : super(key: key);

  @override
  _WaitPaymentComponentState createState() => _WaitPaymentComponentState();
}

class _WaitPaymentComponentState extends State<WaitPaymentComponent> {
  Duration remaining = const Duration(hours: 3);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    initializeWaitUntil().then((_) {
      startCountdown();
    });
  }

  Future<void> initializeWaitUntil() async {
    final docRef =
        FirebaseFirestore.instance.collection('rentals').doc(widget.rentalId);
    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data.containsKey('waitUntil')) {
        final Timestamp ts = data['waitUntil'];
        final DateTime waitUntil = ts.toDate();
        setState(() {
          remaining = waitUntil.difference(DateTime.now());
          if (remaining.isNegative) {
            remaining = Duration.zero;
          }
        });
      } else {
        final DateTime newWaitUntil = DateTime.now().add(const Duration(hours: 3));
        await docRef.update({'waitUntil': Timestamp.fromDate(newWaitUntil)});
        setState(() {
          remaining = const Duration(hours: 3);
        });
      }
    }
  }

  void startCountdown() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (mounted) {
        setState(() {
          remaining -= const Duration(seconds: 1);
        });
        if (remaining.inSeconds <= 0) {
          timer?.cancel();
          final docRef =
              FirebaseFirestore.instance.collection('rentals').doc(widget.rentalId);
          final doc = await docRef.get();
          final currentStatus = doc.data()?['status'];
          if (currentStatus == 'waitpayment') {
            await docRef.update({'status': 'canceled'});
          }
        }
      }
    });
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}';
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("โปรดชำระเงินภายใน 3 ชั่วโมง", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Text("เวลาที่เหลือ: ${formatDuration(remaining)}", style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}

/// Widget สำหรับสถานะ "recieve" ที่มีปุ่มเริ่มต้น disabled แล้วค่อย enable เพื่อรับรถ
/// เมื่อกดปุ่ม ให้แสดง Alert Dialog overlay เพื่อยืนยันการรับรถ
class RecieveComponent extends StatefulWidget {
  final String rentalId;
  const RecieveComponent({Key? key, required this.rentalId}) : super(key: key);

  @override
  _RecieveComponentState createState() => _RecieveComponentState();
}

class _RecieveComponentState extends State<RecieveComponent> {
  bool buttonEnabled = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          buttonEnabled = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: buttonEnabled
              ? () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("ยืนยันการรับรถ"),
                        content: const Text("กดตกลงอีกครั้งเพื่อยืนยันรับรถ"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("ย้อนกลับ"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("ตกลง"),
                          ),
                        ],
                      );
                    },
                  );
                  if (confirm == true) {
                    await FirebaseFirestore.instance
                        .collection('rentals')
                        .doc(widget.rentalId)
                        .update({'status': 'ongoing'});
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonEnabled ? Colors.blue : Colors.grey,
          ),
          child: const Text("ยืนยันรับรถ", style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 8),
        Text(
          buttonEnabled ? "สามารถกดเพื่อรับรถ" : "รอสักครู่...",
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
