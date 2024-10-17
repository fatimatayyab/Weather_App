import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/utilities/shared_preferences_helpers.dart';
import 'package:weather_app/utilities/weather_fetcher.dart'; // Your weather fetching service

class WeatherForecastScreen extends StatefulWidget {
  final String cityName;

  const WeatherForecastScreen({super.key, required this.cityName});

  @override
  State<WeatherForecastScreen> createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
 List<String> _savedCities = [];


  @override
  void initState() {
    super.initState();
     _loadSavedCities();
    
   
  }
  void _handleTap() {
  _addCityToSaved(context);
}
Future<void> _loadSavedCities() async {
  _savedCities = await SharedPreferencesHelper.loadSavedCities();
  setState(() {
    print("Saved cities: $_savedCities");
  });
}
Future<void> _addCityToSaved(BuildContext context) async {
  try {
    await SharedPreferencesHelper.saveCity(widget.cityName, context);
   
  } catch (e) {
    
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100, // Set the height for the AppBar
    flexibleSpace:  Align(
      alignment: Alignment.bottomLeft, // Align the title at the bottom
      child: Padding(
        padding: const EdgeInsets.only(left: 30.0, bottom: 5.0), // Adjust padding to position the title
        child: Text(
          widget.cityName,
          style: const TextStyle(
            fontSize: 20, // Customize font size
            color: Color.fromARGB(255, 84, 82, 82), // Customize text color
          ),
        ),
      ),
    ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: WeatherService().fetch5DayForecast(widget.cityName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Assuming snapshot.data contains the forecast data
          final forecastData = snapshot.data;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Grid for displaying the 5-day forecast
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25.0),
                  child: GridView.builder(
                    // physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6, // 5 columns for 5 days
                      childAspectRatio: 0.3, // Adjust aspect ratio as needed
                    ),
                    itemCount: forecastData!.length,
                    itemBuilder: (context, index) {
                      final dayForecast = forecastData[index];
                      final date = dayForecast['date'];
                      final tempMax = dayForecast['tempMax'];
                      final tempMin = dayForecast['tempMin'];
                      final windSpeed = dayForecast['windSpeed'];
                      final weatherIcon = dayForecast['weatherIcon'];
                              
                      return Card(
                        color: Colors.white,
                        shadowColor: Colors.grey,
                                                child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              getDayName(date), // Function to get the day name from the date
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5,),
                         Text(getFormattedDate(date)),
                           const SizedBox(height: 10,),
                            Image.network(
                              'http://openweathermap.org/img/wn/$weatherIcon@2x.png',
                              height: 50,
                              width: 50,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                            ),
                              const SizedBox(height: 7,),
                            Text(' ${tempMax.toString()}°C'),
                              const SizedBox(height: 7,),
                            Text(' ${tempMin.toString()}°C'),
                              const SizedBox(height: 7,),
                            Text(' ${windSpeed.toString()} m/s'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20), // Space between grid and button
                  GestureDetector(
      onTap: _handleTap, // Function to call on tap
  child: Container(
    padding: const EdgeInsets.all(16), // Padding around the button
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.transparent, // Background color
    ),
    child: const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.add, size: 50), // Icon size can be adjusted
        SizedBox(height: 4), // Space between icon and label
        Text('Add to Start Page'), // Label text
      ],
    ),
  ),
),
                 
              ],
            ),
          );
        },
      ),
    );
  }

String getFormattedDate(String date) {
    // Parse the date string to a DateTime object
    DateTime parsedDate = DateTime.parse(date);

    // Format the date to show only the day and month (e.g., '14 Oct')
    return DateFormat('dd MMM').format(parsedDate);
  }

String getDayName(String date) {
  // Parse the date string to a DateTime object
  DateTime parsedDate = DateTime.parse(date);
  
  // Format the date to get the day name (e.g., 'Monday' or 'Mon')
 // return DateFormat('EEEE').format(parsedDate); // Full day name
   return DateFormat('EEE').format(parsedDate); // Abbreviated day name
}


}
