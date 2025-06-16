import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:roveeee/domain/models/hike.dart';
import 'package:roveeee/domain/repositories/hike_repository.dart';
import 'package:uuid/uuid.dart';

class CreateHikeScreen extends StatefulWidget {
  final HikeRepository hikeRepository;
  final String userId;

  const CreateHikeScreen({
    super.key,
    required this.hikeRepository,
    required this.userId,
  });

  @override
  State<CreateHikeScreen> createState() => _CreateHikeScreenState();
}

class _CreateHikeScreenState extends State<CreateHikeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  LatLng? _startLocation;
  LatLng? _endLocation;
  bool _isPublic = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _createHike() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startLocation == null || _endLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end locations')),
      );
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final hike = Hike(
        id: const Uuid().v4(),
        name: _nameController.text,
        description: _descriptionController.text,
        startLatitude: _startLocation!.latitude,
        startLongitude: _startLocation!.longitude,
        endLatitude: _endLocation!.latitude,
        endLongitude: _endLocation!.longitude,
        userId: widget.userId,
        createdAt: DateTime.now(),
        isPublic: _isPublic,
        dateTime: dateTime,
        members: [widget.userId],
        beacons: [],
      );

      await widget.hikeRepository.createHike(hike);
      
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Hike'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Hike Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectDate,
                      child: Text(_selectedDate == null
                          ? 'Select Date'
                          : 'Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectTime,
                      child: Text(_selectedTime == null
                          ? 'Select Time'
                          : 'Time: ${_selectedTime!.hour}:${_selectedTime!.minute}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(0, 0),
                    zoom: 2,
                  ),
                  onTap: (LatLng position) {
                    setState(() {
                      if (_startLocation == null) {
                        _startLocation = position;
                      } else if (_endLocation == null) {
                        _endLocation = position;
                      } else {
                        _startLocation = position;
                        _endLocation = null;
                      }
                    });
                  },
                  markers: {
                    if (_startLocation != null)
                      Marker(
                        markerId: const MarkerId('start'),
                        position: _startLocation!,
                      ),
                    if (_endLocation != null)
                      Marker(
                        markerId: const MarkerId('end'),
                        position: _endLocation!,
                      ),
                  },
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Public Hike'),
                value: _isPublic,
                onChanged: (value) {
                  setState(() => _isPublic = value);
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createHike,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Create Hike'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 