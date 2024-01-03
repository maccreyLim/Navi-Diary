import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navi_diary/controller/weather_location_controller.dart';
import 'package:navi_diary/controller/weather_network_controller.dart';
import 'package:navi_diary/scr/weather_screen.dart';

const apikey = '2d0b9df3630730263dd41e14f37ccb9e';

class WeatherLoading extends StatefulWidget {
  const WeatherLoading({Key? key}) : super(key: key);

  @override
  State<WeatherLoading> createState() => _WeatherLoadingState();
}

class _WeatherLoadingState extends State<WeatherLoading> {
  late double latitude3;
  late double longitude3;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  void _getLocation() async {
    WeatherLocationController myLocation = WeatherLocationController();
    await myLocation.getMyCurrentLocation();
    latitude3 = myLocation.latitude2;
    longitude3 = myLocation.longitude2;

    print('위도3: $latitude3');
    print('경도3: $longitude3');

    WeatherNetWorkController netWork = WeatherNetWorkController(
      'https://api.openweathermap.org/data/2.5/weather'
          '?lat=$latitude3&lon=$longitude3&appid=$apikey&units=metric',
      'https://api.openweathermap.org/data/2.5/air_pollution'
          '?lat=$latitude3&lon=$longitude3&appid=$apikey&units=metric',
    );

    var weatherData = await netWork.getJsonData();
    print(weatherData);

    var airData = await netWork.getAirData();
    print(airData);

    Get.to(() => WeatherScreen(
          parseWeatherData: weatherData,
          parseAirPollution: airData,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
