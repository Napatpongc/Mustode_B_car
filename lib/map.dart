import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'account_page.dart';

class MapDetailPage extends StatefulWidget {
  const MapDetailPage({super.key});

  @override
  _MapDetailPageState createState() => _MapDetailPageState();
}

class _MapDetailPageState extends State<MapDetailPage> {
  final Location location = Location();
  bool _isManualLocation = false;
  LocationData? _locationData;
  late final MapController _mapController;
  double _currentZoom = 18.0;
  List<Map<String, dynamic>> _nearbyCars = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _fetchCurrentLocation();
  }

  void _fetchCurrentLocation() async {
    _locationData = await location.getLocation();
    setState(() {
      _mapController.move(
          LatLng(_locationData!.latitude!, _locationData!.longitude!), _currentZoom);
    });
    _listenToLocationChanges();
  }

  void _listenToLocationChanges() {
    location.onLocationChanged.listen((LocationData newLocation) {
      if (!_isManualLocation) {
        setState(() {
          _locationData = newLocation;
          _mapController.move(LatLng(newLocation.latitude!, newLocation.longitude!), _currentZoom);
        });
        _fetchNearbyCars();
      }
    });
  }

  void _fetchNearbyCars() {
    if (_locationData == null) return;
    double userLat = _locationData!.latitude!;
    double userLng = _locationData!.longitude!;

    FirebaseFirestore.instance.collection('cars').snapshots().listen((snapshot) {
      List<Map<String, dynamic>> filteredCars = [];
      for (var doc in snapshot.docs) {
        var data = doc.data();
        if (data.containsKey('location')) {
          double carLat = data['location']['latitude'] ?? 0.0;
          double carLng = data['location']['longitude'] ?? 0.0;
          double distance = _calculateDistance(userLat, userLng, carLat, carLng);
          if (distance <= 5.0) {
            filteredCars.add({...data, 'docId': doc.id});
          }
        }
      }
      setState(() {
        _nearbyCars = filteredCars;
      });
    });
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double radius = 6371;
    double dLat = (lat2 - lat1) * (pi / 180);
    double dLon = (lon2 - lon1) * (pi / 180);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) * cos(lat2 * (pi / 180)) *
            sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return radius * c;
  }

  void _openLocationPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Pick a Location')),
          body: FlutterLocationPicker(
            initZoom: 11,
            minZoomLevel: 5,
            maxZoomLevel: 16,
            trackMyPosition: true,
            onPicked: (pickedData) {
              Navigator.pop(context, pickedData.latLong);
            },
          ),
        ),
      ),
    ).then((pickedLatLng) {
      if (pickedLatLng != null) {
        setState(() {
          _isManualLocation = true;
          _locationData = LocationData.fromMap({'latitude': pickedLatLng.latitude, 'longitude': pickedLatLng.longitude});
          _mapController.move(pickedLatLng, _currentZoom);
        });
        _fetchNearbyCars();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map Detail')),
      body: Stack(
        children: [
          _locationData == null
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                      center: LatLng(_locationData!.latitude!, _locationData!.longitude!), zoom: _currentZoom),
                  children: [
                    TileLayer(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: const ['a', 'b', 'c']),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(_locationData!.latitude!, _locationData!.longitude!),
                          width: 80,
                          height: 80,
                          child: const Icon(Icons.my_location, size: 50, color: Colors.red),
                        ),
                        for (var car in _nearbyCars)
                          Marker(
                            point: LatLng(car['location']['latitude'], car['location']['longitude']),
                            width: 80,
                            height: 80,
                            child: GestureDetector(
                              onTap: () {
                                String ownerId = car['ownerId'];
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => AccountPage(docId: ownerId)));
                              },
                              child: const Icon(Icons.directions_car, size: 50, color: Colors.blue),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
          Positioned(
            bottom: 50,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                    heroTag: "pickLocation",
                    onPressed: _openLocationPicker,
                    mini: true,
                    child: const Icon(Icons.map)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
