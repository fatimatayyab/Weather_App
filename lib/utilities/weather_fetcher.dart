import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_app/keys.dart';

class WeatherService {
  final String apiKey = api_key_weather;  // Replace with your OpenWeatherMap API key
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  final String baseAqiUrl = 'https://api.openweathermap.org/data/2.5/air_pollution';

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    final response = await http.get(Uri.parse('$baseUrl?q=$city&appid=$apiKey&units=metric'));
    if (response.statusCode == 200) {
      return json.decode(response.body); 
       // Return decoded JSON
    } else {
      throw Exception('Failed to load weather data');
    }
  }
  

  

  String getDayOrNight(int sunrise, int sunset, int currentTime, int timezone) {
    // Adjust times for timezone
    DateTime localSunrise = DateTime.fromMillisecondsSinceEpoch((sunrise + timezone) * 1000);
    DateTime localSunset = DateTime.fromMillisecondsSinceEpoch((sunset + timezone) * 1000);
    DateTime localCurrentTime = DateTime.fromMillisecondsSinceEpoch((currentTime + timezone) * 1000);

    // Check if it's day or night
    if (localCurrentTime.isAfter(localSunrise) && localCurrentTime.isBefore(localSunset)) {
      return 'day';
    } else {
      return 'night';
    }
  }
 Future<List<Map<String, dynamic>>> fetch5DayForecast(String cityName) async {
  final url =
      'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$apiKey&units=metric';

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    Map<String, Map<String, dynamic>> dailyForecast = {};

    for (var entry in data['list']) {
      String dateKey = entry['dt_txt'].split(' ')[0]; // Extract the date (YYYY-MM-DD)

      // Initialize the daily forecast if it doesn't exist
      if (!dailyForecast.containsKey(dateKey)) {
        dailyForecast[dateKey] = {
          'tempMax': entry['main']['temp_max'], // Initialize max temp
          'tempMin': entry['main']['temp_min'], // Initialize min temp
          'windSpeed': entry['wind']['speed'], // Assume wind speed for the first entry
          'weatherIcon': entry['weather'][0]['icon'], // Assume the first entry's icon
          'date': dateKey, // Store the date
        };
      } else {
        // Update the max and min temperatures
        dailyForecast[dateKey]!['tempMax'] = 
            dailyForecast[dateKey]!['tempMax'] < entry['main']['temp_max']
            ? entry['main']['temp_max'] 
            : dailyForecast[dateKey]!['tempMax'];

        dailyForecast[dateKey]!['tempMin'] = 
            dailyForecast[dateKey]!['tempMin'] > entry['main']['temp_min']
            ? entry['main']['temp_min'] 
            : dailyForecast[dateKey]!['tempMin'];
        
        // Update wind speed and weather icon if necessary (you can customize this logic)
        // Here we are just keeping the first weather icon; you might want to enhance this logic
      }
    }

    // Convert the map to a list
    return dailyForecast.values.toList();
  } else {
    throw Exception('Failed to load forecast data');
  }
}

}
