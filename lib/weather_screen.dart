import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/AdditionInfoItem.dart';
import 'package:weather_app/HourlyWeatherForecastItem.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = "Jalna";
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherApiKey',
        ),
      );

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'unexpected Exception accure';
      }
      return data;

      // data[list][0][main][temp];
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Weather App",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // backgroundColor: const Color.fromARGB(255, 45, 39, 20),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: const CircularProgressIndicator.adaptive(),
            );
          }

          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          final data = snapshot.data!;
          final currentWeatherdata = data['list'][0];
          final currentTemp = currentWeatherdata['main']['temp'];
          final currentSky = currentWeatherdata['weather'][0]['main'];
          final currentPressure = currentWeatherdata['main']['pressure'];
          final currentWindSpeed = currentWeatherdata['wind']['speed'];
          final currentHumidity = currentWeatherdata['main']['humidity'];

          var tempCel = currentTemp - 273.15;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //  Main Card
                SizedBox(
                  width: double.infinity,

                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),

                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                "${tempCel.toStringAsFixed(1)} ° C",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 16),
                              Icon(
                                currentSky == "Clouds" || currentSky == "Rain"
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                currentSky,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                //  Weather Forecast Card
                const SizedBox(height: 16),
                Text(
                  "Weather Forecast",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       //  add card here
                //       for (int i = 0; i <= 5; i++)
                //         HourlyWeatherForecastItem(
                //           time: data['list'][i + 1]['dt_txt'].toString(),
                //           icon:
                //               data['list'][i + 1]['weather'][0]['main'] ==
                //                           "Clouds" ||
                //                       data['list'][i +
                //                               1]['weather'][0]['main'] ==
                //                           "Rain"
                //                   ? Icons.cloud
                //                   : Icons.sunny,
                //           temperature:
                //               data['list'][i + 1]['main']['temp'].toString(),
                //         ),
                //     ],
                //   ),
                // ),

                // Lazy Loading
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    itemCount: 12,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final hourlyForecast = data['list'][index + 1];
                      final hourlySky =
                          data['list'][index + 1]['weather'][0]['main'];
                      final hourlyTemp =
                          hourlyForecast['main']['temp'].toString();
                      final time = DateTime.parse(hourlyForecast['dt_txt']);
                      final hourlyTempCel = hourlyTemp-272.15;
                      return HourlyWeatherForecastItem(
                        time: DateFormat.Hm().format(time),
                        temperature: hourlyTempCel.toStringAsFixed(1),
                        icon:
                            hourlySky == "Clouds" || hourlySky == "Rain"
                                ? Icons.cloud
                                : Icons.sunny,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  "Additional Information",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionInfoItem(
                      icon: Icons.water_drop,
                      label: "Humidity",
                      value: currentHumidity.toString(),
                    ),
                    AdditionInfoItem(
                      icon: Icons.air,
                      label: "Wind Speed",
                      value: currentWindSpeed.toString(),
                    ),
                    AdditionInfoItem(
                      icon: Icons.beach_access,
                      label: "Pressure",
                      value: currentPressure.toString(),
                    ),
                  ],
                ),

                // const Placeholder(fallbackHeight: 150),
              ],
            ),
          );
        },
      ),
    );
  }
}
