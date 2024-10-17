import 'package:flutter/material.dart';
import 'package:adv_flutter_weather/flutter_weather_bg.dart';
import 'package:weather_app/city_input_view.dart';
import 'package:weather_app/services/location_service.dart';
import 'package:weather_app/utilities/weather_fetcher.dart'; // Your weather fetching service

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {

  String _cityName = ""; // Default city
  String _temperature = "";
  String _weatherCondition = "";
    String _minTemp = "";
  String _maxTemp = "";
 
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _getCityName(); // Fetch location on app start

    // Fetch weather on app start
  }

  Future<void> _getCityName() async {
    try {
      String city = await _locationService.getCityName();
      setState(() {
        _cityName = city;
      });
      _fetchWeather(); // Fetch weather for current location
    } catch (e) {
      print(e);
      // Handle error
    }
  }

  Future<void> _fetchWeather() async {
    try {
     final weatherData = await _weatherService.fetchWeather(_cityName);
      print(weatherData);
      

      setState(() {
        _temperature =
             '${weatherData['main']['temp'].round()}°C'; // Extract and round temperature

        _weatherCondition =
            weatherData['weather'][0]['main']; 
            _minTemp = '${weatherData['main']['temp_min'].round()}'; // Extract min temperature
        _maxTemp = '${weatherData['main']['temp_max'].round()}'; // Extract max temperature
       
      });
    } catch (e) {
      print(e);

      // Handle errors, maybe show an error message
    }
  }

   Future<void> _navigateToCityInput() async {

    final selectedCity = await Navigator.push(

      context,

      MaterialPageRoute(builder: (context) => const CityInputScreen()),

    );

    if (selectedCity != null) {

      setState(() {

        _cityName = selectedCity;

      });

      _fetchWeather(); // Fetch weather for the new city

    }

  }

  WeatherType _getWeatherType(String weatherCondition) {
    switch (weatherCondition) {
      case 'Clear':
        return WeatherType.sunny;
      case 'Clouds':
        return WeatherType.cloudy;
      case 'Thunderstorm':
        return WeatherType.heavyRainy;
      case 'Snow':
        return WeatherType.heavySnow;
        case 'CloudyNight':
        return WeatherType.cloudyNight;
        case 'Dust':
        return WeatherType.dusty;
        case 'Fog':
        return WeatherType.foggy;
        case 'Haze':
        return WeatherType.hazy;
        case 'Drizzle':
        return WeatherType.lightRainy;
        case 'lightySnow':
        return WeatherType.lightSnow;
        case 'Rain':
        return WeatherType.middleRainy;
        case 'ShowerSnow':
        return WeatherType.middleSnow;
        case 'Storm':
        return WeatherType.storm;
        case 'ClearNight':
        return WeatherType.sunnyNight;
      default:
        return WeatherType.overcast; // Fallback for unhandled conditions
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          WeatherBg(
            weatherType: _getWeatherType(_weatherCondition),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Positioned(
             top: 200, // Adjust this value to move the content upwards or downwards

            left: 16, // Padding from the left

            right: 16, // 
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
              children: [
                Text(
                  _cityName,
                  style:
                      const TextStyle(fontSize: 25,),
                ),
                 Text(
              _temperature,
              style:
                  const TextStyle(fontSize: 90, ),
            ),
            Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      _weatherCondition,
                      style: const TextStyle(fontSize: 14),
                    ),
                    SizedBox(width: 10,),
                    Text(
                      '$_minTemp°/$_maxTemp°',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                 
              ],
            ),
          ),
        ],
      ),
        floatingActionButton: FloatingActionButton.large(

        onPressed: _navigateToCityInput,

        child: const Icon(Icons.add), 
        backgroundColor: Colors.transparent, 
          elevation: 0,
        

      ),
    );
  }
}
