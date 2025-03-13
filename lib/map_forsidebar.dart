import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'account_page.dart';
import 'vertical_calendar_page.dart';

class MapScreen extends StatefulWidget {
  final DateTime? pickupDate;
  final TimeOfDay? pickupTime;
  final DateTime? returnDate;
  final TimeOfDay? returnTime;

  const MapScreen({
    Key? key,
    this.pickupDate,
    this.pickupTime,
    this.returnDate,
    this.returnTime,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;
  late final MapController _mapController;
  double _currentZoom = 18.0;
  bool _isManualLocation = false;
  List<Map<String, dynamic>> nearbyUsers = [];

  // ตัวแปรสำหรับเก็บวัน-เวลาใน MapScreen
  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  DateTime? _returnDate;
  TimeOfDay? _returnTime;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // กำหนดค่าเริ่มต้นจาก widget ที่รับเข้ามา
    _pickupDate = widget.pickupDate;
    _pickupTime = widget.pickupTime;
    _returnDate = widget.returnDate;
    _returnTime = widget.returnTime;
    _requestLocationPermission();
    _fetchNearbyUsers();

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
            ) / 1000; // Convert meters to kilometers

            print("📍 Checking ${data['username']} at ($userLat, $userLng) - Distance: ${distance.toStringAsFixed(2)} km");

            if (distance <= 5) {
              filteredUsers.add({
                ...data,
                'docId': doc.id,
                'distance': distance, // Add distance to user data
              });
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
        backgroundColor: const Color(0xFF00377E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            color: Colors.white,
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
                    center: LatLng(_locationData!.latitude!, _locationData!.longitude!),
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
                          point: LatLng(_locationData!.latitude!, _locationData!.longitude!),
                          width: 50,
                          height: 50,
                          child: const Icon(Icons.person_pin_circle, size: 40, color: Colors.green),
                        ),
                        for (var user in nearbyUsers)
                          Marker(
                            point: LatLng(
                              user['location']['latitude'],
                              user['location']['longitude'],
                            ),
                            width: 100,
                            height: 90,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  user['distance'] < 1
                                      ? "${(user['distance'] * 1000).toInt()} m" // แสดงเป็นเมตร ถ้าน้อยกว่า 1 กม.
                                      : "${user['distance'].toStringAsFixed(2)} km", // แสดงเป็นกิโลเมตร ถ้ามากกว่า 1 กม.
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    // เลือกปฏิทินทุกครั้งที่กดที่ marker
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VerticalCalendarPage(
                                          initialPickupDate: _pickupDate,
                                          initialPickupTime: _pickupTime,
                                          initialReturnDate: _returnDate,
                                          initialReturnTime: _returnTime,
                                        ),
                                      ),
                                    );
                                    if (result != null && result is Map<String, dynamic>) {
                                      setState(() {
                                        _pickupDate = result['pickupDate'];
                                        _pickupTime = result['pickupTime'];
                                        _returnDate = result['returnDate'];
                                        _returnTime = result['returnTime'];
                                      });
                                    }
                                    // หลังจากเลือกวันแล้ว ให้ navigate ไป AccountPage
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AccountPage(
                                          docId: user['docId'],
                                          pickupDate: _pickupDate,
                                          pickupTime: _pickupTime,
                                          returnDate: _returnDate,
                                          returnTime: _returnTime,
                                          currentLat: _locationData!.latitude,
                                          currentLng: _locationData!.longitude,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Icon(Icons.person, size: 40, color: Colors.blue),
                                ),
                              ],
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
