import'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationFetcher extends StatefulWidget {
  const LocationFetcher({super.key});

  @override
  _LocationFetcherState createState() => _LocationFetcherState();
}

class _LocationFetcherState extends State<LocationFetcher> {
  String _locationMessage = "";
  String _cityName = "";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    // Check for location services
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationMessage = "Location services are disabled.";
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationMessage = "Location permissions are denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationMessage = "Location permissions are permanently denied.";
      });
      return;
    } 

    // When we have permission, fetch the location
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    
    // Use reverse geocoding to get the city name
    _getCityName(position.latitude, position.longitude);
  }

  Future<void> _getCityName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        setState(() {
          _cityName = placemarks[0].locality ?? ""; // Extract city name
          _locationMessage = "Location: $latitude, $longitude\nCity: $_cityName";
        });
      } else {
        setState(() {
          _locationMessage = "City not found.";
        });
      }
    } catch (e) {
      setState(() {
        _locationMessage = "Error: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fetch Location")),
      body: Center(
        child: Text(_locationMessage),
      ),
    );
  }
}
