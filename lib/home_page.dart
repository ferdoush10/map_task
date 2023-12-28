import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Location location = Location();
  LocationData? initialLocation;
  LocationData? currentLocation;
  late StreamSubscription locationSubscription;
  late GoogleMapController googleMapController;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    getInitialLocation();
  }

  void getCurrentLocation() {
    locationSubscription = location.onLocationChanged.listen((locationLive) {
      Timer.periodic(const Duration(seconds: 12), (timer) {
        currentLocation = locationLive;
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(locationLive.latitude ?? 23.80525621032685,
                  locationLive.longitude ?? 90.41280160761826),
              zoom: 18,
            ),
          ),
        );
        if (mounted) {
          setState(() {});
        }
        timer.cancel();
      });
    });
  }

  Future<void> getInitialLocation() async {
    initialLocation = await location.getLocation();
    if (mounted) {}
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Real_Time Location Tracker",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(23.73779338178549, 90.40124943963241),
        ),
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },
        markers: {
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(
              currentLocation?.latitude ?? 23.73779338178549,
              currentLocation?.longitude ?? 90.40124943963241,
            ),
            infoWindow: InfoWindow(
              title: "myCurrent Location",
              snippet:
                  '${currentLocation?.latitude} , ${currentLocation?.longitude}',
            ),
          ),
        },
        polylines: {
          Polyline(
            polylineId: const PolylineId('initial-location'),
            width: 5,
            color: Colors.red,
            points: [
              LatLng(
                initialLocation?.latitude ?? 23.73779338178549,
                initialLocation?.longitude ?? 90.40124943963241,
              ),
              LatLng(
                currentLocation?.latitude ?? 23.73779338178549,
                currentLocation?.longitude ?? 90.40124943963241,
              ),
            ],
          ),
        },
      ),
    );
  }

  @override
  void dispose() {
    locationSubscription.cancel();
    super.dispose();
  }
}
