import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_items.dart';

import 'package:weather_app/secrets.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // cleared because doing it with future builder
  @override
  void initState() {
    ///build function should be least expensive thats why called the async funtion in initState
    super.initState();
    weather = getCurrentWeather();
  }

  String cityName = 'Peshawar';
  late Future<Map<String, dynamic>> weather;
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherApiKey'),
      );
      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'An Unexpected error occured';
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          ///for splash effect icon like a button
          // InkWell(
          //   onTap: () => print('refresh'),
          //   child: const Icon(Icons.refresh),
          // ),

          ///for detecting click
          // GestureDetector(
          //   onTap: () => print('refresh'),
          //   child: const Icon(Icons.refresh),
          // ),

          ///With icon button we have nice padding and a circle splash
          IconButton(
              onPressed: () {
                setState(() {
                  weather = getCurrentWeather();
                });
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            ///with adaptive it would adapt style according to operating system
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          final currentTemperature = currentWeatherData['main']['temp'];
          final currentTempInCent = (currentTemperature - 273);
          final currentSkyCondition = currentWeatherData['weather'][0]['main'];

          final currentPressure = currentWeatherData['main']['pressure'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];
          final currentHumidity = currentWeatherData['main']['humidity'];

          dynamic skyCondition = Icons.sunny;
          DateTime currentTime = DateTime.now();
          DateTime startTime = DateTime(
              currentTime.year, currentTime.month, currentTime.day, 19); // 7 PM
          DateTime endTime =
              DateTime(currentTime.year, currentTime.month, currentTime.day, 5)
                  .add(const Duration(days: 1)); // 5 AM next day
          if (currentSkyCondition == 'Clouds') {
            skyCondition = Icons.cloud;
          } else if (currentSkyCondition == 'Rain') {
            skyCondition = Icons.thunderstorm_sharp;
          } else if (currentSkyCondition == 'Clear' &&
              (currentTime.isAfter(startTime) &&
                  currentTime.isBefore(endTime))) {
            skyCondition = Icons.nights_stay;
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  child: Center(
                    child: Text(
                      cityName,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                //main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10,
                          sigmaY: 10,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                // '${currentTempInCent != 0 ? currentTempInCent.toStringAsFixed(2) : currentTempInCent.toStringAsFixed(0)}',
                                '${(currentTempInCent).toStringAsFixed(0)} °',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Icon(
                                skyCondition,
                                size: 64,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                '$currentSkyCondition',
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
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
                const SizedBox(
                  height: 24,
                ),

                const Text(
                  'Weather Forecast',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                const SizedBox(
                  height: 12,
                ),

                //Forecast cards
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 0; i < 15; i++)
                //         HourlyForecastCards(
                //           time: data['list'][i + 1]['dt'].toString(),

                //           icon: (data['list'][i + 1]['weather'][0]['main'] ==
                //                   'Clouds'
                //               ? Icons.cloud
                //               : (data['list'][i + 1]['weather'][0]['main'] ==
                //                       'Rain'
                //                   ? Icons.thunderstorm
                //                   : (data['list'][i + 1]['weather'][0]
                //                                   ['main'] ==
                //                               'Clear' &&
                //                           (currentTime.isAfter(startTime) &&
                //                               currentTime.isBefore(endTime))
                //                       ? Icons.nights_stay
                //                       : Icons.sunny))),

                //           ///temp in cent from kelvin
                //           temperature:
                //               (data['list'][i + 1]['main']['temp'] - 273)
                //                   .toStringAsFixed(1),
                //         ),
                //     ],
                //   ),
                // ),

                SizedBox(
                  height: 120,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        final hourlyForecast = data['list'][index + 1];
                        final hourlyForcastWeatherSky =
                            data['list'][index + 1]['weather'][0]['main'];
                        final hourlyForecastTemperature =
                            data['list'][index + 1]['main']['temp'];
                        final time =
                            DateTime.parse(hourlyForecast['dt_txt'].toString());

                        return HourlyForecastCards(
                          time: DateFormat.j().format(time),
                          temperature:
                              '${(hourlyForecastTemperature - 273).toStringAsFixed(0)}°',
                          icon: (hourlyForcastWeatherSky == 'Clouds'
                              ? Icons.cloud
                              : (hourlyForcastWeatherSky == 'Rain'
                                  ? Icons.thunderstorm
                                  : (hourlyForcastWeatherSky == 'Clear' &&
                                          (currentTime.isAfter(startTime) &&
                                              currentTime.isBefore(endTime))
                                      ? Icons.nights_stay
                                      : Icons.sunny))),
                        );
                      }),
                ),

                const SizedBox(
                  height: 24,
                ),

                ///Additional information
                const Text(
                  'Additional Information',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),

                const SizedBox(
                  height: 12,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalWeatherInfo(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: currentHumidity.toString(),
                    ),
                    AdditionalWeatherInfo(
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value: currentWindSpeed.toString(),
                    ),
                    AdditionalWeatherInfo(
                      icon: Icons.beach_access,
                      label: 'Pressure',
                      value: currentPressure.toString(),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
