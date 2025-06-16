import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:roveeee/domain/models/hike.dart';
import 'package:roveeee/data/models/hike_model.dart';
import 'dart:math';
import 'package:roveeee/data/repositories/user_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:roveeee/presentation/hike/screen/hike_members_screen.dart';
import 'package:roveeee/domain/repositories/user_profile_repository.dart';
import 'package:roveeee/data/repositories/firebase_user_profile_repository.dart';
import 'package:roveeee/domain/repositories/hike_repository.dart';
import 'package:roveeee/data/repositories/firebase_hike_repository.dart';
import 'package:roveeee/domain/repositories/user_repository.dart';

class OngoingHikeScreen extends StatefulWidget {
  final dynamic hike;  // Can be either Hike or HikeModel
  final HikeRepository hikeRepository;
  final UserRepository userRepository;

  const OngoingHikeScreen({
    Key? key,
    required this.hike,
    required this.hikeRepository,
    required this.userRepository,
  }) : super(key: key);

  @override
  State<OngoingHikeScreen> createState() => _OngoingHikeScreenState();
}

class _OngoingHikeScreenState extends State<OngoingHikeScreen> {
  late final Hike _hike;
  LocationData? _currentLocation;
  late final Location _location;
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  String? _distance;
  String? _duration;
  Map<String, LatLng> _groupLocations = {}; // userId -> LatLng
  late final FirebaseFirestore _firestore;
  StreamSubscription? _locationsStream;

  @override
  void initState() {
    super.initState();
    // Convert HikeModel to Hike if needed
    if (widget.hike is HikeModel) {
      final hikeModel = widget.hike as HikeModel;
      _hike = hikeModel.toHike();
    } else if (widget.hike is Hike) {
      _hike = widget.hike as Hike;
    } else {
      throw ArgumentError('hike must be either HikeModel or Hike');
    }
    
    _location = Location();
    _firestore = FirebaseFirestore.instance;
    _initLocation();
    _fetchRoute();
    _listenToGroupLocations();
  }

  @override
  void dispose() {
    _locationsStream?.cancel();
    super.dispose();
  }

  void _initLocation() async {
    try {
      final location = await _location.getLocation();
      setState(() {
        _currentLocation = location;
      });
      _uploadLocation(location);
      _location.onLocationChanged.listen((loc) {
        setState(() {
          _currentLocation = loc;
        });
        _uploadLocation(loc);
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _uploadLocation(LocationData loc) async {
    if (loc.latitude == null || loc.longitude == null) return;
    final userId = _hike.members.firstWhere((id) => id == _hike.userId, orElse: () => _hike.userId);
    await _firestore.collection('hikes').doc(_hike.id).collection('locations').doc(userId).set({
      'lat': loc.latitude,
      'lng': loc.longitude,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _fitMapToMarkers() {
    final markers = <LatLng>[
      LatLng(_hike.startLatitude, _hike.startLongitude),
      LatLng(_hike.endLatitude, _hike.endLongitude),
      if (_currentLocation != null) LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
      ..._groupLocations.values,
    ];
    if (markers.isEmpty || _mapController == null) return;
    double minLat = markers.first.latitude, maxLat = markers.first.latitude;
    double minLng = markers.first.longitude, maxLng = markers.first.longitude;
    for (final m in markers) {
      if (m.latitude < minLat) minLat = m.latitude;
      if (m.latitude > maxLat) maxLat = m.latitude;
      if (m.longitude < minLng) minLng = m.longitude;
      if (m.longitude > maxLng) maxLng = m.longitude;
    }
    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
  }

  void _listenToGroupLocations() {
    _locationsStream = _firestore
        .collection('hikes')
        .doc(_hike.id)
        .collection('locations')
        .snapshots()
        .listen((snapshot) {
      final updated = <String, LatLng>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['lat'] != null && data['lng'] != null) {
          updated[doc.id] = LatLng(data['lat'], data['lng']);
        }
      }
      setState(() {
        _groupLocations = updated;
      });
      _fitMapToMarkers();
    });
  }

  Future<void> _fetchRoute() async {
    final start = '${_hike.startLatitude},${_hike.startLongitude}';
    final end = '${_hike.endLatitude},${_hike.endLongitude}';
    const apiKey = ''; // Replace with your actual Google Maps API key
    final url = 
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'].isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          final polyline = _decodePolyline(points);
          setState(() {
            _polylines = {
              Polyline(
                polylineId: const PolylineId('route'),
                color: Colors.blue,
                width: 4,
                points: polyline,
              ),
            };
            _distance = data['routes'][0]['legs'][0]['distance']['text'];
            _duration = data['routes'][0]['legs'][0]['duration']['text'];
          });
        }
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polyline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        title: const Text('roveX', 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: Color(0xFF00FFB4), 
            fontSize: 28, 
            letterSpacing: 2
          )
        ),
        backgroundColor: const Color(0xFF232A34),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF232A34),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _hike.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_distance != null && _duration != null)
                Text(
                  'Distance: $_distance • Duration: $_duration',
                  style: const TextStyle(color: Colors.white70),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      if (widget.hike is HikeModel) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HikeMembersScreen(
                              hike: widget.hike as HikeModel,
                              hikeRepository: widget.hikeRepository,
                              userProfileRepository: FirebaseUserProfileRepository(),
                              currentUserId: _hike.userId,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cannot manage members for this hike type'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.people, color: Color(0xFF00FFB4)),
                    label: const Text(
                      'Members',
                      style: TextStyle(color: Color(0xFF00FFB4)),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF232A34),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_hike.startLatitude, _hike.startLongitude),
                      zoom: 12,
                    ),
                    onMapCreated: (controller) {
                      _mapController = controller;
                      _fitMapToMarkers();
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('start'),
                        position: LatLng(_hike.startLatitude, _hike.startLongitude),
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                      ),
                      Marker(
                        markerId: const MarkerId('end'),
                        position: LatLng(_hike.endLatitude, _hike.endLongitude),
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                      ),
                      if (_currentLocation != null)
                        Marker(
                          markerId: const MarkerId('current'),
                          position: LatLng(
                            _currentLocation!.latitude!,
                            _currentLocation!.longitude!,
                          ),
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                        ),
                      ..._groupLocations.entries.map(
                        (e) => Marker(
                          markerId: MarkerId(e.key),
                          position: e.value,
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
                        ),
                      ),
                    },
                    polylines: _polylines,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
