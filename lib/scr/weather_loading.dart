import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
  AdManagerInterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    loadAd();
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
    print(netWork);
    var weatherData = await netWork.getJsonData();
    print(weatherData);

    var airData = await netWork.getAirData();
    print(airData);

    Get.to(() => WeatherScreen(
          parseWeatherData: weatherData,
          parseAirPollution: airData,
        ));
  }

  void loadAd() {
    AdManagerInterstitialAd.load(
      adUnitId: Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910',
      request: const AdManagerAdRequest(),
      adLoadCallback: AdManagerInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          _interstitialAd = ad;
          _interstitialAd?.show(); // Show the ad when it's loaded
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('AdManagerInterstitialAd failed to load: $error');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
