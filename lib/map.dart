import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'account_page.dart';

class MapDetailPage extends StatefulWidget {
  const MapDetailPage({Key? key}) : super(key: key);

  @override
  _MapDetailPageState createState() => _MapDetailPageState();
}

class _MapDetailPageState extends State<MapDetailPage> {
  final Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;
  late final MapController _mapController;
  double _currentZoom = 18.0;
  bool _isManualLocation = false;
  List<Map<String, dynamic>> nearbyUsers = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _requestLocationPermission();
    _fetchNearbyUsers();

    // 🔥 ติดตามการเปลี่ยนแปลง Firestore และอัปเดตข้อมูลอัตโนมัติ
    FirebaseFirestore.instance.collection('users').snapshots().listen((snapshot) {
      print("🔄 Firestore updated, refreshing nearby users...");
      _fetchNearbyUsers();
    });
  }

  Future<void> _requestLocationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) return;
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    _locationData = await location.getLocation();
    setState(() {});
    _fetchNearbyUsers();
  }

  Future<void> _fetchNearbyUsers() async {
    if (_locationData == null) return;

    try {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      print("🔍 Firestore returned ${usersSnapshot.docs.length} users");

      List<Map<String, dynamic>> filteredUsers = [];
      for (var doc in usersSnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        print("📄 Raw User Data: ${data}");

        if (data.containsKey('location') && data['location'] != null) {
          double? userLat = data['location']['latitude']?.toDouble();
          double? userLng = data['location']['longitude']?.toDouble();

          if (userLat != null && userLng != null) {
            double distance = Geolocator.distanceBetween(
              _locationData!.latitude!,
              _locationData!.longitude!,
              userLat,
              userLng,
            ) / 1000; // Convert to kilometers

            print("📍 Checking ${data['username']} at ($userLat, $userLng) - Distance: ${distance.toStringAsFixed(2)} km");

            if (distance <= 5) {
              filteredUsers.add({...data, 'docId': doc.id});
            }
          } else {
            print("⚠️ User ${data['username']} has invalid location data: $userLat, $userLng");
          }
        } else {
          print("⚠️ Skipping user ${data['username']} - No location field");
        }
      }

      print("✅ Nearby users found: ${filteredUsers.length}");
      setState(() {
        nearbyUsers = filteredUsers;
      });
    } catch (e) {
      print("❌ Error fetching users: $e");
    }
  }

  void _updateLocation(LatLng newLocation) {
    setState(() {
      _isManualLocation = false;
      _locationData = LocationData.fromMap({
        'latitude': newLocation.latitude,
        'longitude': newLocation.longitude,
      });
      _mapController.move(newLocation, _currentZoom);
    });
    _fetchNearbyUsers();
  }

  void _openLocationPicker() async {
    final pickedLatLng = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Pick a Location'),
          ),
          body: FlutterLocationPicker(
            initZoom: _currentZoom,
            minZoomLevel: 5,
            maxZoomLevel: 16,
            trackMyPosition: false,
            searchBarBackgroundColor: Colors.white,
            mapLanguage: 'th',
            initPosition: _locationData != null
                ? LatLong(_locationData!.latitude!, _locationData!.longitude!)
                : null,
            onError: (e) => print(e),
            onPicked: (pickedData) {
              Navigator.pop(context, LatLng(pickedData.latLong.latitude, pickedData.latLong.longitude));
            },
          ),
        ),
      ),
    );

    if (pickedLatLng != null) {
      setState(() {
        _isManualLocation = true;
      });
      _updateLocation(pickedLatLng);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Map Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: _openLocationPicker,
          ),
        ],
      ),
      body: Stack(
        children: [
          _locationData == null
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: LatLng(
                        _locationData!.latitude!, _locationData!.longitude!),
                    zoom: _currentZoom,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(
                              _locationData!.latitude!, _locationData!.longitude!),
                          width: 50,
                          height: 50,
                          child: const Icon(Icons.person_pin_circle,
                              size: 40, color: Colors.green),
                        ),
                        // Marker สำหรับผู้ใช้งานที่อยู่ใกล้เคียง
                        for (var user in nearbyUsers)
                          Marker(
                            point: LatLng(
                              user['location']['latitude'],
                              user['location']['longitude'],
                            ),
                            width: 50,
                            height: 50,
                            // เมื่อกด Marker ให้ navigate ไปหน้า AccountPage พร้อมส่ง docId
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AccountPage(
                                      docId: user['docId'],
                                    ),
                                  ),
                                );
                              },
                              child: const Icon(Icons.person,
                                  size: 40, color: Colors.blue),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
