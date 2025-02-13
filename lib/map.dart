import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

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

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {}); // Update UI when location data is available
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Map Detail'),
      ),
      body: _locationData == null
          ? const Center(child: CircularProgressIndicator()) // Show loading until location is fetched
          : FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(_locationData!.latitude!, _locationData!.longitude!),
                initialZoom: 18,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_locationData!.latitude!, _locationData!.longitude!),
                      width: 80,
                      height: 80,
                      child: const Icon(Icons.location_on, size: 50, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}