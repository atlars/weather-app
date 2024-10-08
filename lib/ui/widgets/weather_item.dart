import 'package:flutter/material.dart';
import 'package:weather_app/util/weather.dart';

class WeatherItem extends StatelessWidget {
  final int wmoCode;
  final ({double minTemp, double maxTemp})? minMaxTemperature;
  final double temperature;

  const WeatherItem({this.minMaxTemperature, required this.wmoCode, this.temperature = 0.0, super.key});

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
        _buildTemperature(context)
      ],
    );
  }

  Widget _buildTemperature(BuildContext context) {
    if (minMaxTemperature != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${minMaxTemperature!.minTemp.toInt()}°',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 3),
          Text(
            '${minMaxTemperature!.maxTemp.toInt()}°',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      );
    }
    return Text('$temperature°', style: const TextStyle(fontWeight: FontWeight.w500));
  }
}
