import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/city_suggestion_view.dart';
import 'package:weather_app/utilities/shared_preferences_helpers.dart';
import 'package:weather_app/utilities/weather_fetcher.dart'; // Your weather fetching service

class CityInputScreen extends StatefulWidget {
  const CityInputScreen({super.key});

  @override
  _CityInputScreenState createState() => _CityInputScreenState();
}

class _CityInputScreenState extends State<CityInputScreen> {
  final TextEditingController _controller = TextEditingController();
List<String> _savedCities = [];
// To store city name and temperature
  final WeatherService _weatherService = WeatherService();
  List<Map<String, dynamic>> _weatherDataList = []; // To store weather data for each city


  
 @override
  void initState() {
    super.initState();
    _loadSavedCities(); // Load saved cities when the screen is initialized
  }

  //

Future<void> _loadSavedCities() async {
  _savedCities = await SharedPreferencesHelper.loadSavedCities();
  
  // Fetch weather for each saved city
  for (String city in _savedCities) {
    await _fetchWeatherForCity(city); // Fetch weather for each city
  }
  
  setState(() {}); // Update UI after fetching weather
}
  Future<void> _fetchWeatherForCity(String city) async {
  try {
    final weatherData = await _weatherService.fetchWeather(city);
    
    // Create a weather data map
    String currentTemp = '${weatherData['main']['temp'].round()}°C';
    String weatherCondition = weatherData['weather'][0]['main'];
    String minTemp = '${weatherData['main']['temp_min'].round()}°C';
    String maxTemp = '${weatherData['main']['temp_max'].round()}°C';

    // Get sunrise, sunset, and current time
    int sunrise = weatherData['sys']['sunrise'];
    int sunset = weatherData['sys']['sunset'];
    int timezone = weatherData['timezone'];
    int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Determine if it's day or night
    String dayOrNight = _weatherService.getDayOrNight(sunrise, sunset, currentTime, timezone);

    // Add the weather data for the city to the list
    _weatherDataList.add({
      'city': city,
      'currentTemp': currentTemp,
      'weatherCondition': weatherCondition,
      'minTemp': minTemp,
      'maxTemp': maxTemp,
      'dayOrNight': dayOrNight,
    });
  } catch (e) {
    print('Error fetching weather for $city: $e'); // Handle errors
  }
}

Future<void> _navigateToCitySuggestions() async {
    final selectedCity = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CitySuggestionScreen()),
    );

    if (selectedCity != null) {
      setState(() {
        _controller.text = selectedCity; // Update the text field with the selected city
      });
    }
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
          'Search City Name',
          style: TextStyle(
            fontSize: 20, // Customize font size
            color: Color.fromARGB(255, 84, 82, 82), // Customize text color
          ),
        ),
      ),
    ),
  ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
               style: const TextStyle(
                            color: Colors.black,),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.location_on_outlined,
                            size: 30,
                          ),
                          prefixIconColor: const Color.fromARGB(255, 100, 100, 100),

                          hintText: '  Enter Location',
                          hintStyle: const TextStyle( color: Color.fromARGB(255, 84, 82, 82),),

                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical:8.0),
                          // filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                            
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
              onTap: _navigateToCitySuggestions,
            ),
            const SizedBox(height: 10),
           
            const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                'Saved Cities:',
                style: TextStyle(
                  color: Color.fromARGB(255, 84, 82, 82),
                  fontSize: 18,
                   ),
              ),
            ),
            const SizedBox(height: 10),
            // Display the saved cities in a scrollable view
            Expanded(
              child: ListView.builder(
                 itemCount: _weatherDataList.length,
                itemBuilder: (context, index) {
                final cityData = _weatherDataList[index];
                  final city = cityData['city'];
                  final currentTemp = cityData['currentTemp'];
                  final weatherCondition = cityData['weatherCondition'];
                  final minTemp = cityData['minTemp'];
                  final maxTemp = cityData['maxTemp'];
                   final dayOrNight = cityData['dayOrNight']; 
                     // Set background color based on day or night
                  Color backgroundColor = dayOrNight == 'day' ? const Color.fromARGB(255, 82, 170, 241) : const Color.fromARGB(255, 39, 37, 37);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: backgroundColor,
                      ),
                     child: ListTile(
                        contentPadding: const EdgeInsets.symmetric( horizontal: 16),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              city ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 226, 226, 226)
                              ),
                            ),
                            Text(
                              currentTemp ?? '',
                              style: const TextStyle(
                                fontSize: 24, // Larger size for current temp
                                fontWeight: FontWeight.bold,
                                color:Color.fromARGB(255, 226, 226, 226)
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                           Text(
      weatherCondition ?? '',
      style: const TextStyle(color: Color.fromARGB(255, 226, 226, 226)), // Set desired color here
    ),
    const SizedBox(height: 4),
    // Change color for min and max temperature
    Text(
      'Max: $maxTemp, Min: $minTemp',
      style: const TextStyle(color:Color.fromARGB(255, 226, 226, 226)), // Set desired color here
    ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
