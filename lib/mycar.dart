import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CarListScreen(),
    );
  }
}

class CarListScreen extends StatefulWidget {
  @override
  _CarListScreenState createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  List<Car> cars = [
    Car(name: 'Honda Jazz', image: 'assets/image/image6.png', active: true),
    Car(name: 'Toyota Vios', image: 'assets/image/image7.png', active: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // เพิ่มรูปภาพ bar.png ที่มุมซ้ายบน โดยกำหนดขนาด 48 x 27
        leading: Container(
          width: 48,
          height: 27,
          margin: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              // ตัวอย่างการทำงานเมื่อแตะที่รูป (สามารถแก้ไขตามต้องการ)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Bar image tapped')),
              );
            },
            child: Image.asset(
              'assets/image/bar.png',
              width: 32,
              height: 39,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text('รถฉัน'),
        backgroundColor: Colors.blue[900],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cars.length,
              itemBuilder: (context, index) {
                return CarCard(
                  car: cars[index],
                  onToggle: (bool value) {
                    setState(() {
                      cars[index].active = value;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
              onPressed: () {},
              child: Icon(Icons.add),
              backgroundColor: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class CarCard extends StatelessWidget {
  final Car car;
  final ValueChanged<bool> onToggle;

  CarCard({required this.car, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        leading: Image.asset(car.image, width: 60, height: 60, fit: BoxFit.cover),
        title: Row(
          children: [
            Text(car.name, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 5),
            Icon(
              car.active ? Icons.circle : Icons.circle,
              color: car.active ? Colors.green : Colors.red,
              size: 12,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.edit, size: 16),
              label: Text("แก้ไข"),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.delete, size: 16, color: Colors.red),
              label: Text("ลบ", style: TextStyle(color: Colors.red)),
            ),
            Text("เอกสารหมดอายุ xx/xx/xxxx", style: TextStyle(color: Colors.red)),
          ],
        ),
        trailing: Switch(
          value: car.active,
          onChanged: onToggle,
        ),
      ),
    );
  }
}

class Car {
  String name;
  String image;
  bool active;

  Car({required this.name, required this.image, required this.active});
}
