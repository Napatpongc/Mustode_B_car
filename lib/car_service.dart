import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class CarService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getNearbyCars(double userLat, double userLng) async {
    List<Map<String, dynamic>> nearbyCars = [];

    QuerySnapshot snapshot = await _firestore.collection('cars').get();

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      if (data['location'] != null && data['statuscar'] == 'yes') {
        double carLat = data['location']['latitude'];
        double carLng = data['location']['longitude'];

        double distance = Geolocator.distanceBetween(userLat, userLng, carLat, carLng) / 1000; // แปลงเป็นกิโลเมตร

        if (distance <= 5) { // เฉพาะรถที่อยู่ในระยะ 5 กม.
          nearbyCars.add({
            "id": doc.id,
            "model": data['model'],
            "ownerId": data['ownerId'],
            "price": data['price'],
            "location": LatLng(carLat, carLng),
            "images": data['images'] ?? {},
          });
        }
      }
    }

    return nearbyCars;
  }
}
