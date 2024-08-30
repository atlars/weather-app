import 'package:flutter/material.dart';
import 'package:weather_app/util/pair.dart';
import 'package:weather_app/util/weather.dart';

class WeatherItem extends StatelessWidget {
  final int wmoCode;
  final Pair<double, double>? minMaxTemperature;
  final double temperature;

  const WeatherItem(
      {this.minMaxTemperature,
      required this.wmoCode,
      this.temperature = 0.0,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          WeatherUtils.getWeatherEmoji(wmoCode),
          style: const TextStyle(
            fontSize: 28,
            fontFamily: "NotoColorEmoji",
          ),
        ),
        _buildTemperature()
      ],
    );
  }

  Widget _buildTemperature() {
    if (minMaxTemperature != null) {
      return Text('${minMaxTemperature!.first}°/${minMaxTemperature!.last}°', style: const TextStyle(fontWeight: FontWeight.w100),);
    }
    return Text('$temperature°', style: const TextStyle(fontWeight: FontWeight.w500));
  }
}
