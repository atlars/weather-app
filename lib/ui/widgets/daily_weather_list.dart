import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/ui/widgets/weather_item.dart';

class DailyWeatherList extends HookWidget {
  final DailyWeatherData weatherData;

  /// Is called when a day was clicked
  final void Function(DateTime date) onDaySelected;
  final DateTime? initialDate;
  final double itemGapSize;
  final double horizontalPadding;

  const DailyWeatherList(
      {required this.weatherData,
      required this.onDaySelected,
      this.initialDate,
      this.itemGapSize = 7,
      this.horizontalPadding = 14,
      super.key});

  @override
  Widget build(BuildContext context) {
    final selectedDate = useState(initialDate ?? DateTime.now());

    final items = _getWeahterItems(selectedDate, context);
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

  List<Widget> _getWeahterItems(ValueNotifier<DateTime> selectedDate, BuildContext context) {
    final theme = Theme.of(context);
    return weatherData.time.mapIndexed((index, date) {
      return GestureDetector(
        onTap: () {
          selectedDate.value = date;
          onDaySelected(date);
        },
        child: Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 3),
          shape: RoundedRectangleBorder(
            side: DateUtils.isSameDay(selectedDate.value, date)
                ? BorderSide(color: theme.focusColor, width: 1)
                : BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(DateFormat('E').format(date)),
                WeatherItem(
                  wmoCode: weatherData.weatherCodes[index],
                  minMaxTemperature: (
                    minTemp: weatherData.minTemperatues[index],
                    maxTemp: weatherData.maxTemperatues[index]
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
