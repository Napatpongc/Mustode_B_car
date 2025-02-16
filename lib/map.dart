import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';

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
  bool _isManualLocation = false; // Flag to stop GPS updates when manually set

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
      if (!_isManualLocation) { // Only update if not manually overridden
        setState(() {
          _locationData = newLocation;
        });

        _mapController.move(
          LatLng(newLocation.latitude!, newLocation.longitude!),
          _currentZoom,
        );
      }
    });
  }

  void _zoomIn() {
    setState(() {
      _currentZoom += 1;
      _mapController.move(_mapController.center, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom -= 1;
      _mapController.move(_mapController.center, _currentZoom);
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

  void _openLocationPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Pick a Location'),
          ),
          body: FlutterLocationPicker(
            initZoom: 11,
            minZoomLevel: 5,
            maxZoomLevel: 16,
            trackMyPosition: true,
            searchBarBackgroundColor: Colors.white,
            mapLanguage: 'th',
            onError: (e) => print(e),
            onPicked: (pickedData) {
              print('Picked location: ${pickedData.latLong.latitude}, ${pickedData.latLong.longitude}');
              Navigator.pop(context, pickedData.latLong); // Pass the picked LatLng back
            },
          ),
        ),
      ),
    ).then((pickedLatLng) {
      if (pickedLatLng != null) {
        setState(() {
          _isManualLocation = true; // Stop real-time updates
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
    });
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
                    center: LatLng(_locationData!.latitude!, _locationData!.longitude!),
                    zoom: _currentZoom,
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
                  heroTag: "resumeTracking",
                  onPressed: () {
                    setState(() {
                      _isManualLocation = false; // Resume GPS tracking
                    });
                  },
                  child: const Icon(Icons.gps_fixed),
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
