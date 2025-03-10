import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatusRenter extends StatelessWidget {
  final String rentalId;

  const StatusRenter({super.key, required this.rentalId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("รายละเอียด / สถานะ"),
        backgroundColor: const Color(0xFF00377E),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rentals')
            .doc(rentalId)
            .snapshots(),
        builder: (context, rentalSnapshot) {
          if (!rentalSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rentalData = rentalSnapshot.data!.data() as Map<String, dynamic>;
          final status = rentalData['status'] ?? 'pending';
          final carId = rentalData['carId'] ?? '';
          final lessorId = rentalData['lessorId'] ?? '';

          // แปลง Timestamp เป็น DateTime และ Format เป็น String
          final rentalStartTS = rentalData['rentalStart'] as Timestamp?;
          final rentalEndTS = rentalData['rentalEnd'] as Timestamp?;
          String formattedRentalStart = '';
          String formattedRentalEnd = '';
          
          if (rentalStartTS != null) {
            final rentalStart = rentalStartTS.toDate();
            formattedRentalStart = "${rentalStart.day.toString().padLeft(2, '0')}/${rentalStart.month.toString().padLeft(2, '0')}/${rentalStart.year} ${rentalStart.hour.toString().padLeft(2, '0')}:${rentalStart.minute.toString().padLeft(2, '0')}";
          }
          
          if (rentalEndTS != null) {
            final rentalEnd = rentalEndTS.toDate();
            formattedRentalEnd = "${rentalEnd.day.toString().padLeft(2, '0')}/${rentalEnd.month.toString().padLeft(2, '0')}/${rentalEnd.year} ${rentalEnd.hour.toString().padLeft(2, '0')}:${rentalEnd.minute.toString().padLeft(2, '0')}";
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  'สถานะการจอง',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              StatusRow(status: status),

              // User and Car Details
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(lessorId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final username = userData['username'] ?? '';
                  final email = userData['email'] ?? '';
                  final phone = userData['phone'] ?? '';
                  final profilePic = userData['image']?['profile'] ?? '';

                  return Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(profilePic),
                        ),
                        title: Text(username),
                        subtitle: Text('$email | $phone'),
                      ),
                    ],
                  );
                },
              ),
              const Divider(),

              // Car Details
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('cars')
                    .doc(carId)
                    .get(),
                builder: (context, carSnapshot) {
                  if (!carSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final carData = carSnapshot.data!.data() as Map<String, dynamic>;
                  final carName = '${carData['brand']} ${carData['model']}';
                  final carImage = carData['image']?['carfront'] ?? '';
                  final carDetails = carData['detail'] ?? {};

                  return Column(
                    children: [
                      Image.network(carImage),
                      Text(
                        carName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      CarDetailRow(label: "ประเภทรถ", value: carDetails['Vehicle'] ?? 'ไม่ระบุ'),
                      CarDetailRow(label: "ระบบเกียร์", value: carDetails['gear'] ?? 'ไม่ระบุ'),
                      CarDetailRow(label: "ระบบเชื้อเพลิง", value: carDetails['fuel'] ?? 'ไม่ระบุ'),
                      CarDetailRow(label: "จำนวนที่นั่ง", value: '${carDetails['seat'] ?? 'ไม่ระบุ'}'),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Rental Dates
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  'วัน-เวลารับรถ/คืนรถ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              RentalDateRow(label: "รับรถ", value: formattedRentalStart),
              RentalDateRow(label: "คืนรถ", value: formattedRentalEnd),

              const SizedBox(height: 20),

              // Payment and Refund
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'ค่าเช่ารถ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              PaymentSummary(rentalId: rentalId),
            ],
          );
        },
      ),
    );
  }
}

class StatusRow extends StatelessWidget {
  final String status;

  const StatusRow({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final List<String> statusLabels = [
      'รอติดต่อกลับ',
      'ชำระเงิน',
      'อยู่ระหว่างการใช้รถ',
      'รอยืนยันเสร็จสิ้นใช้รถ',
      'เสร็จสิ้นการใช้รถ'
    ];

    final Map<String, Color> statusColors = {
      'pending': Colors.yellow,
      'waitpayment': Colors.green,
      'approved': Colors.green,
      'ongoing': Colors.yellow,
      'end': Colors.yellow,
    };

    return Column(
      children: List.generate(statusLabels.length, (index) {
        final currentStatus = statusLabels[index];
        final color = statusColors[status] ?? Colors.grey;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: color,
          ),
          title: Text(currentStatus),
        );
      }),
    );
  }
}

class RentalDateRow extends StatelessWidget {
  final String label;
  final String value;

  const RentalDateRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }
}

class CarDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const CarDetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }
}

class PaymentSummary extends StatelessWidget {
  final String rentalId;

  const PaymentSummary({super.key, required this.rentalId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rentals')
          .doc(rentalId)
          .snapshots(),
      builder: (context, rentalSnapshot) {
        if (!rentalSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final rentalData = rentalSnapshot.data!.data() as Map<String, dynamic>;
        final pricePerDay = rentalData['pricePerDay'] ?? 0;
        final days = rentalData['days'] ?? 0;
        final deposit = pricePerDay * days * 0.15;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ค่าเช่ารถ'),
                Text('฿${pricePerDay * days}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ค่ามัดจำ'),
                Text('฿$deposit'),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF0C5),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ทั้งหมด'),
                  Text('฿${pricePerDay * days + deposit}'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
