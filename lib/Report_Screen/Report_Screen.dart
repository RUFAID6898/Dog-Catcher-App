import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  Position? _currentPosition;
  String _locationName = '';

  File? _dogImage;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report Stray Dog',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 180, 179, 176),
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    _dogImage != null
                        ? SizedBox(
                            width: double.infinity,
                            height: 200,
                            child: Image.file(
                              _dogImage!,
                              fit: BoxFit.cover,
                            ))
                        : SizedBox(
                            width: double.infinity,
                            height: 200,
                            child: Image.asset(
                              'assets/images/camera3.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _captureImage();
                        },
                        icon: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Capture Dog Image',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _descriptionController,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: ListTile(
                          title: Text(
                            _currentPosition != null
                                ? 'Location: $_locationName,'
                                : 'Selact Location...',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          trailing: IconButton(
                              onPressed: () async {
                                await _getLocation();
                              },
                              icon: const Icon(
                                Icons.location_on_outlined,
                                color: Colors.red,
                              )),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_currentPosition == null || _dogImage == null) {
                            return;
                          }

                          String locationDescription = _locationName;
                          String dogDescription = _descriptionController.text;

                          await _saveReportToFirestore(
                              locationDescription, dogDescription);

                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Submit Report',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark firstPlacemark = placemarks[0];

      String locationName = '';

      if (firstPlacemark.name != null) {
        locationName += '${firstPlacemark.name!}, ';
      }

      if (firstPlacemark.locality != null) {
        locationName += '${firstPlacemark.locality!}, ';
      }

      if (firstPlacemark.administrativeArea != null) {
        locationName += '${firstPlacemark.administrativeArea!}, ';
      }

      locationName = locationName.isNotEmpty
          ? locationName.substring(0, locationName.length - 2)
          : 'Unknown';

      setState(() {
        _currentPosition = position;
        _locationName = locationName;
      });
    } else {
      print('No placemarks found for the current location.');
    }
  }

  Future<void> _captureImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _dogImage = File(image.path);
      });
    }
  }

  Future<void> _saveReportToFirestore(
    String locationDescription,
    String dogDescription,
  ) async {
    DocumentReference reportRef =
        await FirebaseFirestore.instance.collection('reports').add({
      'location': _locationName,
      'description': dogDescription,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
