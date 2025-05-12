import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:weather_app/additional_information_item.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> currentWeather;
  late Future<Map<String, dynamic>> forecastWeather;
  final TextEditingController _cityController = TextEditingController(); // Controller for city input

  // Fetch current weather data
  Future<Map<String, dynamic>> getCurrentWeather(String cityName) async {
    try {
      final apiKey = dotenv.env['api_key'] ?? '';
      if (apiKey.isEmpty) throw 'API key not loaded';

      final response = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw errorData['message'] ?? 'Failed to fetch weather (${response.statusCode})';
      }
    } catch (e) {
      throw 'Failed to get weather: ${e.toString()}';
    }
  }

  // Fetch forecast weather data
  Future<Map<String, dynamic>> getForecastWeather(String cityName) async {
    try {
      final apiKey = dotenv.env['api_key'];
      final res = await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$apiKey'));
      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'An unexpected error occurred';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  // Fetch weather data for the entered city
  Future<void> fetchWeather() async {
    try {
      final cityName = _cityController.text.trim();
      if (cityName.isEmpty) return

        ;

      setState(() {
        currentWeather = getCurrentWeather(cityName);
        forecastWeather = getForecastWeather(cityName);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Default city on app launch
    _cityController.text = 'Mumbai';
    fetchWeather();
  }

  double kelvinToCelsius(double kelvin) {
    return kelvin - 273.15;
  }
  Widget getWeatherIcon(String skyCondition, DateTime time) {
    final hour = time.hour; // Get the current hour
    final isDayTime = hour >= 6 && hour < 18; // Daytime is between 6 AM and 6 PM

    if (skyCondition == 'Clear') {
      return BoxedIcon(
        isDayTime ? WeatherIcons.day_sunny : WeatherIcons.night_clear, // Day/Night icon for Clear
        size: 32,
      );
    } else if (skyCondition == 'Clouds') {
      return BoxedIcon(
        isDayTime ? WeatherIcons.day_cloudy : WeatherIcons.night_alt_cloudy, // Day/Night icon for Clouds
        size: 32,
      );
    } else if (skyCondition == 'Rain') {
      return BoxedIcon(
        isDayTime ? WeatherIcons.day_rain : WeatherIcons.night_alt_rain, // Day/Night icon for Rain
        size: 32,
      );
    } else if (skyCondition == 'Snow') {
      return BoxedIcon(
        isDayTime ? WeatherIcons.day_snow : WeatherIcons.night_alt_snow, // Day/Night icon for Snow
        size: 32,
      );
    } else if (skyCondition == 'Thunderstorm') {
      return BoxedIcon(
        isDayTime ? WeatherIcons.day_thunderstorm : WeatherIcons.night_alt_thunderstorm, // Day/Night icon for Thunderstorm
        size: 32,
      );
    }
    else if (skyCondition == 'Mist'|| skyCondition=='Haze') {
      return BoxedIcon(
        isDayTime ? WeatherIcons.day_haze : WeatherIcons.night_fog,
        size: 32,
      );
    }
    else {
      return BoxedIcon(
        isDayTime ? WeatherIcons.day_sunny : WeatherIcons.night_clear, // Default day/night icon
        size: 32,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        scrollDirection: Axis.vertical,
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 60,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent,
                    Colors.redAccent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: const Text(
              "Aeris",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: fetchWeather, // Refresh weather data
              ),
            ],

          ),
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(  // Wrap the Column in a SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(),  // Disable scrolling
                child: Column(
                  children: [
                    // City input field and search button
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              hintText: 'Enter city name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: fetchWeather, // Fetch weather for the entered city
                          child: const Text('Search'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Weather data display
                    FutureBuilder(
                      future: Future.wait([currentWeather, forecastWeather]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(snapshot.error.toString()),
                          );
                        }

                        final currentData = snapshot.data![0]; // Current weather data
                        final forecastData = snapshot.data![1]; // Forecast weather data

                        final  currentTemp = currentData['main']['temp'];
                        final currentSky = currentData['weather'][0]['main'];
                        final currentPressure = currentData['main']['pressure'];
                        final currentWindSpeed = currentData['wind']['speed'];
                        final currentHumidity = currentData['main']['humidity'];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            // Main card (current weather)
                            Container(
                              width: double.infinity,
                              child: Card(
                                elevation: 15,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 10.0, sigmaY: 10.0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${kelvinToCelsius(currentTemp).toStringAsFixed(1)}°C',
                                            style: TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          getWeatherIcon(currentSky,DateTime.now()),
                                          Text(
                                            '$currentSky',
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Weather forecast cards
                            const SizedBox(height: 20),
                            Text(
                              "Weather Forecast",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),

                            SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 39,
                                itemBuilder: (context, index) {
                                  final hourlyForecast = forecastData['list'][index + 1];
                                  final hourlySky = forecastData['list'][index + 1]['weather'][0]['main'];
                                  final time = DateTime.parse(hourlyForecast['dt_txt']);
                                  final formattedDate = DateFormat('dd-MM-yy').format(time); // Date in dd-MM-yy
                                  final formattedTime = DateFormat('HH:mm').format(time); // Time in HH:mm
                                  return HourlyForecastWidget(
                                    date: formattedDate,
                                    time: formattedTime,
                                    temp: '${kelvinToCelsius(hourlyForecast['main']['temp']).toStringAsFixed(1)}°C',
                                    iconData: getWeatherIcon(hourlySky,time),
                                  );
                                },
                              ),
                            ),

                            // Additional information
                            const SizedBox(height: 20),
                            Text(
                              "Additional Information",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                AdditionalInfoItem(
                                  icon: BoxedIcon(WeatherIcons.humidity, size: 32),
                                  label: "Humidity",
                                  value: "${currentHumidity.toString()}%",
                                ),
                                AdditionalInfoItem(
                                  icon: BoxedIcon(WeatherIcons.wind_beaufort_0, size: 32),
                                  label: "Wind Speed",
                                  value: "${currentWindSpeed.toString()} m/s",
                                ),
                                AdditionalInfoItem(
                                  icon: BoxedIcon(WeatherIcons.barometer, size: 32),
                                  label: "Pressure",
                                  value: "${currentPressure.toString()} hPa",
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}