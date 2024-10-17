import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // For reverse geocoding
import 'package:weather_app/keys.dart';
import 'package:weather_app/weather_forecast_view.dart';

class CitySuggestionScreen extends StatefulWidget {
  const CitySuggestionScreen({super.key});

  @override
  _CitySuggestionScreenState createState() => _CitySuggestionScreenState();
}

class _CitySuggestionScreenState extends State<CitySuggestionScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<dynamic> _suggestions = [];
  final String _apiKey = api_key_places; // Replace with your actual API key
  final List<String> _popularCities = [
    "New York",
    "London",
    "Tokyo",
    "Paris",
    "Sydney",
    "Berlin",
    "Los Angeles",
    "Cairo",
    "Rome",
    "Dubai",
  ];

  void _onSearchChanged(String query) {
    if (query.isNotEmpty) {
      _fetchCitySuggestions(query);
    } else {
      setState(() {
        _suggestions.clear();
      });
    }
  }

  Future<void> _fetchCitySuggestions(String query) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&types=(cities)&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final predictions = data['predictions']; // Extract predictions directly

        setState(() {
          _suggestions.clear();
          _suggestions.addAll(predictions.map((prediction) => prediction['description']).toList());
        });
      } else {
        print('Failed to load suggestions: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  Future<void> _locateUser() async {
    Position position;

    try {
      // Fetch current location
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      
      // Get city name from coordinates using reverse geocoding
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        String cityName = placemarks[0].locality ?? '';
        
        if (cityName.isNotEmpty) {
          setState(() {
            _controller.text = cityName; // Set the city name in the text field
            _suggestions.clear(); // Clear previous suggestions
          });
           // Navigate to the WeatherForecastScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WeatherForecastScreen(
              cityName: cityName, // Pass the fetched city name
            ),
          ),
        );
        }
      }
    } catch (e) {
      print('Error: $e');
      // Handle location fetching error
    }
  }

  void _selectCity(String city) {
    // Set the selected city to the text field
    _controller.text = city;

    // Navigate to the WeatherForecastScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeatherForecastScreen(
          cityName: city, // Pass the selected city name
        ),
      ),
    );

    // Clear the suggestions
    setState(() {
      _suggestions.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100, // Set the height for the AppBar
        flexibleSpace: const Align(
          alignment: Alignment.bottomLeft, // Align the title at the bottom
          child: Padding(
            padding: EdgeInsets.only(left: 30.0, bottom: 5.0), // Adjust padding to position the title
            child: Text(
              'Select City',
              style: TextStyle(
                fontSize: 20, // Customize font size
                color: Color.fromARGB(255, 84, 82, 82), // Customize text color
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Locate button with pin icon
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _locateUser,
                  icon: const Icon(Icons.pin_drop, color:  Color.fromARGB(255, 100, 100, 100)),
                  label: const Text('Locate'),
                  style: ElevatedButton.styleFrom(
                    iconColor: Colors.blue, // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    style: const TextStyle(
                      color: Colors.black, 
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.location_on_outlined,
                        size: 30,
                      ),
                      prefixIconColor: const Color.fromARGB(255, 100, 100, 100),
                      hintText: 'Enter City Name',
                      hintStyle: const TextStyle(
                        color: Color.fromARGB(255, 84, 82, 82),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    controller: _controller,
                    onChanged: _onSearchChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Display city suggestions in a scrollable view
            Expanded(
              child: Column(
                children: [
                  // Display city suggestions in a scrollable view (if there are any)
                  if (_suggestions.isNotEmpty) ...[
                    Expanded(
                      child: ListView.builder(
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final city = _suggestions[index];
                          return ListTile(
                            title: Text(city),
                            onTap: () => _selectCity(city), // Select city on tap
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    // Popular Cities Section
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Popular Cities:',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Wrap(
                        spacing: 10, // Horizontal spacing between items
                        runSpacing: 10, // Vertical spacing between rows
                        children: _popularCities.map((city) {
                          return GestureDetector(
                            onTap: () => _selectCity(city),
                            child: Container(
                              width: 100, // Set the width of each item
                              height: 50, // Set the height of each item
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(213, 233, 232, 239), // Light grey background
                                borderRadius: BorderRadius.circular(10), // Rounded corners
                              ),
                              child: Center(
                                child: Text(
                                  city,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
