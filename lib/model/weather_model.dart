// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WeatherModel {
  Widget getWeatherIcon(int condition) {
    if (condition < 300) {
      return SvgPicture.asset(
        'svg/climacon-cloud_lightning.svg',
        color: Colors.black87,
      );
    } else if (condition < 600) {
      return SvgPicture.asset(
        'svg/climacon-cloud_snow_alt.svg',
        color: Colors.black87,
      );
    } else if (condition < 700) {
      return SvgPicture.asset(
        'svg/climacon-cloud_moon.svg',
        color: Colors.black87,
      );
    } else if (condition < 800) {
      return SvgPicture.asset(
        'svg/climacon-cloud_rain.svg',
        color: Colors.black87,
      );
    } else if (condition < 900) {
      return SvgPicture.asset(
        'svg/climacon-cloud_snow_alt.svg',
        color: Colors.black87,
      );
    } else if (condition == 900) {
      // You can add a different icon for condition 900 if needed
      return SvgPicture.asset(
        'svg/default_icon.svg',
        color: Colors.black87,
      );
    } else if (condition == 901) {
      return SvgPicture.asset(
        'svg/climacon-sun_fill.svg',
        color: Colors.black87,
      );
    } else if (condition <= 804) {
      return SvgPicture.asset(
        'svg/climacon-cloud_sun.svg',
        color: Colors.black87,
      );
    }

    // Default return statement
    return SvgPicture.asset(
      'svg/icon.svg',
      color: Colors.black87,
    );
  }

  Widget getAirIcon(int index) {
    if (index == 1) {
      return Image.asset(
        'assets/good.png',
        width: 37.0,
        height: 35.0,
      );
    } else if (index == 2) {
      return Image.asset(
        'assets/fair.png',
        width: 37.0,
        height: 35.0,
      );
    } else if (index == 3) {
      return Image.asset(
        'assets/moderate.png',
        width: 37.0,
        height: 35.0,
      );
    } else if (index == 4) {
      return Image.asset(
        'assets/poor.png',
        width: 37.0,
        height: 35.0,
      );
    } else if (index == 5) {
      return Image.asset(
        'assets/bad.png',
        width: 37.0,
        height: 35.0,
      );
    }
    // Default return statement
    return Image.asset(
      'assets/moderate.png',
      width: 37.0,
      height: 35.0,
    );
  }

  Widget getAirCondition(int index) {
    if (index == 1) {
      return const Text(
        '"매우좋음"',
        style: TextStyle(
          color: Colors.indigo,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (index == 2) {
      return const Text(
        '"좋음"',
        style: TextStyle(
          color: Colors.indigo,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (index == 3) {
      return const Text(
        '"보통"',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (index == 4) {
      return const Text(
        '"나쁨"',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (index == 5) {
      return const Text(
        '"매우나쁨"',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    // Default return statement
    return const Text(
      '"알 수 없음"',
      style: TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
