import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/ui/widgets/weather_item.dart';

class HourlyWeatherList extends HookWidget {
  final HourlyWeatherData weatherData;

  /// Only display the hourly weather for this specfic day
  final DateTime day;
  final double horizontalPadding;
  final double itemGapSize;

  const HourlyWeatherList(
      {required this.weatherData, required this.day, this.horizontalPadding = 26, this.itemGapSize = 15, super.key});

  @override
  Widget build(BuildContext context) {
    final items = _getHourlyWeatherItems();
    final listWidgets = items.expandIndexed((index, item) => [item, SizedBox(width: itemGapSize)]).toList()
      ..removeLast();
    listWidgets.add(SizedBox(width: horizontalPadding));
    listWidgets.insert(0, SizedBox(width: horizontalPadding));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: listWidgets,
      ),
    );
  }

  List<Widget> _getHourlyWeatherItems() {
    final List<int> hourIndexes = weatherData.time.foldIndexed<List<int>>(
      [],
      (index, acc, element) {
        if (DateUtils.isSameDay(element, day)) acc.add(index);
        return acc;
      },
    ).toList();

    return hourIndexes.map((index) {
      return Column(
        children: [
          Text(DateFormat('HH:mm').format(weatherData.time[index])),
          const SizedBox(
            height: 12,
          ),
          WeatherItem(
            wmoCode: weatherData.weatherCodes[index],
            temperature: weatherData.temperatues[index],
          )
        ],
      );
    }).toList();
  }
}
