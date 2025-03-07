import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'calendar_page.dart';
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
  List<Map<String, dynamic>> nearbyOwners = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _requestLocationPermission();
    _startTracking();
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
    _fetchNearbyOwners();
  }

  void _startTracking() {
    location.onLocationChanged.listen((LocationData newLocation) {
      if (!_isManualLocation) {
        setState(() {
          _locationData = newLocation;
        });

        _mapController.move(
          LatLng(newLocation.latitude!, newLocation.longitude!),
          _currentZoom,
        );
        _fetchNearbyOwners();
      }
    });
  }

  Future<void> _fetchNearbyOwners() async {
    if (_locationData == null) return;

    QuerySnapshot usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    List<Map<String, dynamic>> filteredOwners = [];

    for (var doc in usersSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data['location'] != null) {
        double ownerLat = data['location']['latitude'];
        double ownerLng = data['location']['longitude'];
        double distance = Geolocator.distanceBetween(
          _locationData!.latitude!,
          _locationData!.longitude!,
          ownerLat,
          ownerLng,
        ) / 1000; // แปลงเป็นกิโลเมตร

        print("🔍 Owner ${data['username']} ห่าง ${distance.toStringAsFixed(2)} km");

        if (distance <= 5) {
          filteredOwners.add({...data, 'docId': doc.id});
        }
      }
    }

    setState(() {
      nearbyOwners = filteredOwners;
    });
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
        _locationData = LocationData.fromMap({
          'latitude': pickedLatLng.latitude,
          'longitude': pickedLatLng.longitude,
        });
        _mapController.move(
          LatLng(pickedLatLng.latitude, pickedLatLng.longitude),
          _currentZoom,
        );
      });
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
                          point: LatLng(_locationData!.latitude!,
                              _locationData!.longitude!),
                          width: 80,
                          height: 80,
                          child: const Icon(Icons.person_pin_circle,
                              size: 50, color: Colors.green),
                        ),
                        for (var owner in nearbyOwners)
                          Marker(
                            point: LatLng(
                                owner['location']['latitude'],
                                owner['location']['longitude']),
                            width: 80,
                            height: 80,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AccountPage(docId: owner['docId']),
                                  ),
                                );
                              },
                              child: const Icon(Icons.person,
                                  size: 50, color: Colors.blue),
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
                  heroTag: "zoomIn",
                  onPressed: () {
                    setState(() {
                      _currentZoom += 1;
                      _mapController.move(_mapController.center, _currentZoom);
                    });
                  },
                  child: const Icon(Icons.add),
                  mini: true,
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "zoomOut",
                  onPressed: () {
                    setState(() {
                      _currentZoom -= 1;
                      _mapController.move(_mapController.center, _currentZoom);
                    });
                  },
                  child: const Icon(Icons.remove),
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
