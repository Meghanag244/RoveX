import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../data/models/hike_model.dart';
import '../cubit/hike_cubit.dart';

class CreateHikeScreen extends StatefulWidget {
  final String teamLeader;
  const CreateHikeScreen({Key? key, required this.teamLeader}) : super(key: key);

  @override
  State<CreateHikeScreen> createState() => _CreateHikeScreenState();
}

class _CreateHikeScreenState extends State<CreateHikeScreen> {
  final TextEditingController hikeNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController startPointController = TextEditingController();
  final TextEditingController endPointController = TextEditingController();
  bool isPublic = true;
  LatLng? startPoint;
  LatLng? endPoint;
  DateTime? scheduledDateTime;
  GoogleMapController? mapController;
  bool pickingStart = true;

  void _onMapTap(LatLng pos) {
    setState(() {
      if (pickingStart) {
        startPoint = pos;
        startPointController.text = "${pos.latitude},${pos.longitude}";
      } else {
        endPoint = pos;
        endPointController.text = "${pos.latitude},${pos.longitude}";
      }
    });
  }

  void _onStartPointChanged(String value) {
    final latlng = _parseLatLng(value);
    if (latlng != null) {
      setState(() {
        startPoint = latlng;
      });
      mapController?.animateCamera(CameraUpdate.newLatLng(latlng));
    }
  }

  void _onEndPointChanged(String value) {
    final latlng = _parseLatLng(value);
    if (latlng != null) {
      setState(() {
        endPoint = latlng;
      });
      mapController?.animateCamera(CameraUpdate.newLatLng(latlng));
    }
  }

  LatLng? _parseLatLng(String value) {
    final parts = value.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  void _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() {
      scheduledDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _onStartHike() {
    if (hikeNameController.text.isEmpty || 
        descriptionController.text.isEmpty ||
        startPoint == null || 
        endPoint == null || 
        scheduledDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and pick start/end points.')),
      );
      return;
    }

    final hikeCubit = context.read<HikeCubit>();
    hikeCubit.createHike(
      name: hikeNameController.text,
      description: descriptionController.text,
      teamLeader: widget.teamLeader,
      isPublic: isPublic,
      startPoint: startPoint!,
      endPoint: endPoint!,
      scheduledDateTime: scheduledDateTime!,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181A20),
      appBar: AppBar(
        title: const Text('Create Hike', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00FFB4), fontSize: 24)),
        backgroundColor: const Color(0xFF232A34),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                TextField(
                  controller: hikeNameController,
                  decoration: InputDecoration(
                    labelText: 'Hike Name',
                    prefixIcon: const Icon(Icons.terrain, color: Color(0xFF00FFB4)),
                    filled: true,
                    fillColor: const Color(0xFF181A20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    labelStyle: const TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    prefixIcon: const Icon(Icons.description, color: Color(0xFF00FFB4)),
                    filled: true,
                    fillColor: const Color(0xFF181A20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    labelStyle: const TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Public', style: TextStyle(color: Colors.white70)),
                    Switch(
                      value: isPublic,
                      onChanged: (v) => setState(() => isPublic = v),
                      activeColor: const Color(0xFF00FFB4),
                    ),
                    const Text('Private', style: TextStyle(color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: startPointController,
                  decoration: InputDecoration(
                    labelText: 'Start Point (lat,lng)',
                    prefixIcon: const Icon(Icons.location_on, color: Color(0xFF00FFB4)),
                    filled: true,
                    fillColor: const Color(0xFF181A20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    labelStyle: const TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: _onStartPointChanged,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: endPointController,
                  decoration: InputDecoration(
                    labelText: 'End Point (lat,lng)',
                    prefixIcon: const Icon(Icons.flag, color: Color(0xFF00FFB4)),
                    filled: true,
                    fillColor: const Color(0xFF181A20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    labelStyle: const TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: _onEndPointChanged,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pickingStart ? const Color(0xFF00FFB4) : const Color(0xFF232A34),
                          foregroundColor: pickingStart ? Colors.black : const Color(0xFF00FFB4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        onPressed: () => setState(() => pickingStart = true),
                        child: const Text('Pick Start Point'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !pickingStart ? const Color(0xFF00FFB4) : const Color(0xFF232A34),
                          foregroundColor: !pickingStart ? Colors.black : const Color(0xFF00FFB4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        onPressed: () => setState(() => pickingStart = false),
                        child: const Text('Pick End Point'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(12.9716, 77.5946),
                        zoom: 12,
                      ),
                      onMapCreated: (controller) => mapController = controller,
                      onTap: _onMapTap,
                      markers: {
                        if (startPoint != null)
                          Marker(
                            markerId: const MarkerId('start'),
                            position: startPoint!,
                            infoWindow: const InfoWindow(title: 'Start'),
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                          ),
                        if (endPoint != null)
                          Marker(
                            markerId: const MarkerId('end'),
                            position: endPoint!,
                            infoWindow: const InfoWindow(title: 'End'),
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                          ),
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, color: Color(0xFF00FFB4)),
                        label: Text(
                          scheduledDateTime == null
                              ? 'Pick Date & Time'
                              : DateFormat('yyyy-MM-dd – kk:mm').format(scheduledDateTime!),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF00FFB4), width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _pickDateTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _onStartHike,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FFB4),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 6,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  child: const Text('Create Hike'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 