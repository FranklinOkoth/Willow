import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:willow/db/db_services.dart';
import 'package:willow/model/contactsm.dart';
import 'package:willow/widgets/home_widgets/custom_carousel.dart';
import 'package:willow/widgets/home_widgets/custom_app_bar.dart';
import 'package:willow/widgets/home_widgets/emergency.dart';
import 'package:willow/widgets/home_widgets/safe_home/safe_home.dart';
import 'package:willow/widgets/live_safe.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int qIndex = 0;
  Position? _currentPosition;
  String? _currentAddress;
  LocationPermission? permission;
  bool _locationPermissionGranted = false;
  String _currentCity = "";

  _getPermission() async => await [Permission.sms].request();
  _isPermissionGranted() async => await Permission.sms.status.isGranted;

  @override
  void initState() {
    super.initState();
    getRandomQuote();
    _getPermission();
    checkLocationPermission();
  }

  void getRandomQuote() {
    Random random = Random();
    setState(() {
      qIndex = random.nextInt(6);
    });
  }

  Future<void> checkLocationPermission() async {
    bool permissionGranted = await _requestLocationPermission();
    setState(() {
      _locationPermissionGranted = permissionGranted;
    });

    if (_locationPermissionGranted) {
      _getCurrentCity();
    }
  }

  Future<bool> _requestLocationPermission() async {
    var status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }

  void _getCurrentCity() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        setState(() {
          _currentCity = placemark.locality ?? 'Unknown';
          _currentPosition = position;
        });
        _getCurrentAddress();
      }
    } catch (e) {
      print('Error getting current city: $e');
    }
  }

  void _getCurrentAddress() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);

      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
        "${place.locality}, ${place.postalCode}, ${place.street}";
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> getAndSendSms() async {
    List<TContact> contactList = await DatabaseHelper().getContactList();

    if (_currentPosition != null) {
      String messageBody =
          "https://maps.google.com/?daddr=${_currentPosition!.latitude},${_currentPosition!.longitude}";
      if (await _isPermissionGranted()) {
        for (var element in contactList) {
          // Implement SMS sending logic here
          // _sendSms("${element.number}", "I am in trouble $messageBody");
        }
      } else {
        Fluttertoast.showToast(msg: "SMS permission not granted");
      }
    } else {
      Fluttertoast.showToast(msg: "Location not available");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 10,
                child: Container(
                  color: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 5),
              CustomAppBar(
                  quoteIndex: qIndex,
                  onTap: () {
                    getRandomQuote();
                  }),
              const SizedBox(height: 5),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey.shade300,
                                  child: const Icon(Icons.flight_takeoff_outlined),
                                ),
                                const SizedBox(width: 5),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _locationPermissionGranted
                                          ? "Location enabled"
                                          : "Turn on location services.",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      _currentCity.isNotEmpty
                                          ? "Current City: $_currentCity"
                                          : "Please enable location for a better experience.",
                                      maxLines: 2,
                                    ),
                                    const SizedBox(height: 5),
                                    if (!_locationPermissionGranted)
                                      MaterialButton(
                                        onPressed: checkLocationPermission,
                                        color: Colors.grey.shade100,
                                        shape: const StadiumBorder(),
                                        child: const Text(
                                          "Enable location",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "In case of emergency dial me",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const Emergency(),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Explore your power",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const CustomCarousel(),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Explore LiveSafe",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const LiveSafe(),
                    const SafeHome(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}