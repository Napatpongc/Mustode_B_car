// After resolving conflict manually
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
//Work at on branch
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
  }

  void _startTracking() {
    location.onLocationChanged.listen((LocationData newLocation) {
      setState(() {
        _locationData = newLocation;
      });

      _mapController.move(
        LatLng(newLocation.latitude!, newLocation.longitude!),
        _currentZoom,
      );
    });
  }

  void _zoomIn() {
    setState(() {
      _currentZoom += 1;
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom -= 1;
      _mapController.move(_mapController.camera.center, _currentZoom);
    });
  }

  void _reloadLocation() async {
    _locationData = await location.getLocation();
    setState(() {});

    _mapController.move(
      LatLng(_locationData!.latitude!, _locationData!.longitude!),
      _currentZoom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Map Detail'),
      ),
      body: Stack(
        children: [
          _locationData == null
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(_locationData!.latitude!, _locationData!.longitude!),
                    initialZoom: _currentZoom,
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

          // Floating Action Buttons
          Positioned(
            bottom: 50,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "zoomIn",
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add),
                  mini: true,
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "zoomOut",
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove),
                  mini: true,
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "reload",
                  onPressed: _reloadLocation,
                  child: const Icon(Icons.refresh),
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
