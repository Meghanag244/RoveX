import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:roveeee/domain/models/hike.dart';
import 'package:roveeee/domain/repositories/hike_repository.dart';
import 'package:roveeee/domain/models/beacon.dart';
import 'package:uuid/uuid.dart';

class BeaconScreen extends StatefulWidget {
  final Hike hike;
  final HikeRepository hikeRepository;
  final String userId;

  const BeaconScreen({
    super.key,
    required this.hike,
    required this.hikeRepository,
    required this.userId,
  });

  @override
  State<BeaconScreen> createState() => _BeaconScreenState();
}

class _BeaconScreenState extends State<BeaconScreen> {
  LocationData? _currentLocation;
  late final Location _location;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<Beacon> _nearbyBeacons = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _location = Location();
    _initLocation();
  }

  void _initLocation() async {
    try {
      final location = await _location.getLocation();
      setState(() {
        _currentLocation = location;
      });
      _loadNearbyBeacons(location);
      _location.onLocationChanged.listen((loc) {
        setState(() {
          _currentLocation = loc;
        });
        _loadNearbyBeacons(loc);
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _loadNearbyBeacons(LocationData location) async {
    if (location.latitude == null || location.longitude == null) return;
    
    setState(() => _isLoading = true);
    try {
      final beacons = await widget.hikeRepository.getNearbyBeacons(
        widget.hike.id,
        location.latitude!,
        location.longitude!,
        1.0, // 1km radius
      );
      setState(() {
        _nearbyBeacons = beacons;
        _updateMarkers();
      });
    } catch (e) {
      print('Error loading beacons: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateMarkers() {
    final markers = <Marker>{};
    
    // Add current location marker
    if (_currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          infoWindow: const InfoWindow(title: 'You'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }

    // Add beacon markers
    for (final beacon in _nearbyBeacons) {
      markers.add(
        Marker(
          markerId: MarkerId(beacon.id),
          position: LatLng(beacon.latitude, beacon.longitude),
          infoWindow: InfoWindow(
            title: beacon.name,
            snippet: beacon.description,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            beacon.foundBy.contains(widget.userId)
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueRed,
          ),
        ),
      );
    }

    setState(() => _markers = markers);
  }

  Future<void> _addBeacon() async {
    if (_currentLocation == null) return;

    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Beacon'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true) {
      final beacon = Beacon(
        id: const Uuid().v4(),
        name: nameController.text,
        description: descriptionController.text,
        latitude: _currentLocation!.latitude!,
        longitude: _currentLocation!.longitude!,
        createdBy: widget.userId,
        createdAt: DateTime.now(),
        foundBy: [],
      );

      try {
        await widget.hikeRepository.addBeacon(widget.hike.id, beacon);
        _loadNearbyBeacons(_currentLocation!);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding beacon: $e')),
          );
        }
      }
    }
  }

  Future<void> _markBeaconAsFound(Beacon beacon) async {
    try {
      await widget.hikeRepository.markBeaconAsFound(
        widget.hike.id,
        beacon.id,
        widget.userId,
      );
      _loadNearbyBeacons(_currentLocation!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking beacon: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beacons'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation != null
                  ? LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!)
                  : LatLng(widget.hike.startLatitude, widget.hike.startLongitude),
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _addBeacon,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
} 