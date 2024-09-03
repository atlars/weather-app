import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/location.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/provider/location.dart';
import 'package:weather_app/provider/weather.dart';
import 'package:weather_app/ui/views/search_city.dart';
import 'package:weather_app/ui/widgets/weather_item.dart';
import 'package:weather_app/util/pair.dart';

class WeatherPage extends HookConsumerWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 3);
    final selectedCity = ref.watch(selectedCityProvider);

    return Scaffold(
      body: selectedCity.when(
        data: (data) {
          if (data != null) {
            return _buildWeather(data, ref, context, tabController);
          }
          return Text("Add a city");
        },
        error: (error, stacktrace) => Text("Could not load selected City"),
        loading: () => CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildWeather(City city, WidgetRef ref, BuildContext context, TabController tabController) {
    final selectedDate = useState(DateTime.now());
    final weatherResult = ref.watch(
      weatherProvider(
        WeatherRequest(longitude: city.longitude, latitude: city.latitude, forecastHours: 7 * 24, forecastDays: 7),
      ),
    );
    return weatherResult.when(
      data: (weather) {
        return Stack(
          children: [
            Container(
              color: const Color(0xffc5e1fd),
              child: SafeArea(
                child: _buildCurrentWeather(weather, city, context, ref),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 200),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 22),
                        _buildTabBar(tabController, context),
                        const SizedBox(height: 14),
                        _buildTabBarContent(tabController, weather, selectedDate),
                        const SizedBox(height: 14),
                        _buildWeeklyWeather(weather, selectedDate)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        );
      },
      error: (error, stacktrace) => const Text("Error"),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildTabBarContent(TabController tabController, Weather weather, ValueNotifier<DateTime> selectedDate) {
    return SizedBox(
      height: 100,
      child: TabBarView(
        controller: tabController,
        children: [
          _buildHourlyWeather(weather, selectedDate),
          const Tab(icon: Icon(Icons.water_drop_outlined)),
          const Tab(icon: Icon(Icons.wind_power_rounded)),
        ],
      ),
    );
  }

  Widget _buildTabBar(TabController tabController, BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TabBar(
        dividerColor: Colors.transparent,
        unselectedLabelColor: Colors.black,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200,
        ),
        indicatorPadding: const EdgeInsets.symmetric(vertical: 4),
        enableFeedback: false,
        controller: tabController,
        labelStyle: theme.textTheme.labelSmall,
        labelPadding: EdgeInsets.zero,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: [
          Tab(
            child: IntrinsicWidth(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.thermostat,
                      color: theme.iconTheme.color,
                    ),
                    const Text("Temperature"),
                  ],
                ),
              ),
            ),
          ),
          Tab(
            child: IntrinsicWidth(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wind_power,
                      color: theme.iconTheme.color,
                    ),
                    const Text("Wind")
                  ],
                ),
              ),
            ),
          ),
          Tab(
            child: IntrinsicWidth(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.water_drop,
                      color: theme.iconTheme.color,
                    ),
                    const Text("Rain")
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeather(Weather weather, City city, BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(theme, context, ref, city),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                // Todo: fix
                '${weather.daily.maxTemperatues.last.toInt()}°',
                style: theme.textTheme.headlineLarge
                    ?.copyWith(color: Color(0xff2b5d98), fontWeight: FontWeight.w600, fontSize: 46),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme, BuildContext context, WidgetRef ref, City city) {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          color: Color(0xff2b5d98),
          size: 28,
        ),
        Text(
          city.name,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w400, color: Color(0xff2b5d98)),
        ),
        const Spacer(),
        IconButton(
          onPressed: () async {
            final result = await showSearch(context: context, delegate: SearchCityDelegate());
            if (result != null) {
              ref.read(selectedCityProvider.notifier).set(result);
            }
            ref.invalidate(searchCityProvider);
          },
          icon: const Icon(
            Icons.search,
            color: Color(0xff2b5d98),
            size: 28,
          ),
        )
      ],
    );
  }

  List<Widget> _getHourlyWeatherItems(Weather weather, ValueNotifier<DateTime> selectedDate) {
    final hourIndexes = weather.hourly.time.foldIndexed(
      [],
      (index, acc, element) {
        if (DateUtils.isSameDay(element, selectedDate.value)) acc.add(index);
        return acc;
      },
    );

    return hourIndexes.map((index) {
      return Column(
        children: [
          Text(DateFormat('HH:mm').format(weather.hourly.time[index])),
          const SizedBox(
            height: 12,
          ),
          WeatherItem(
            wmoCode: weather.hourly.weatherCodes[index],
            temperature: weather.hourly.temperatues[index],
          )
        ],
      );
    }).toList();
  }

  List<Widget> _getWeeklyWeatherItems(Weather weather, ValueNotifier<DateTime> selectedDate) {
    return weather.daily.time.mapIndexed((index, date) {
      return GestureDetector(
        onTap: () => selectedDate.value = date,
        child: Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 3),
          shadowColor: Colors.grey.shade200,
          shape: RoundedRectangleBorder(
            side: DateUtils.isSameDay(selectedDate.value, date)
                ? BorderSide(color: Colors.blueAccent.shade200, width: 1)
                : BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(DateFormat('E').format(date)),
                WeatherItem(
                  wmoCode: weather.daily.weatherCodes[index],
                  minMaxTemperature: Pair(
                    weather.daily.minTemperatues[index],
                    weather.daily.maxTemperatues[index],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildWeeklyWeather(Weather weather, ValueNotifier<DateTime> selectedDate) {
    const double horizontalPadding = 14;
    const double gapSize = 7;
    final items = _getWeeklyWeatherItems(weather, selectedDate);
    final listWidgets = items.expandIndexed((index, item) => [item, const SizedBox(width: gapSize)]).toList()
      ..removeLast();
    listWidgets.add(const SizedBox(width: horizontalPadding));
    listWidgets.insert(0, const SizedBox(width: horizontalPadding));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: listWidgets,
      ),
    );
  }

  Widget _buildHourlyWeather(Weather weather, ValueNotifier<DateTime> selectedDate) {
    const double horizontalPadding = 26;
    const double gapSize = 15;

    final items = _getHourlyWeatherItems(weather, selectedDate);
    final listWidgets = items.expandIndexed((index, item) => [item, const SizedBox(width: gapSize)]).toList()
      ..removeLast();
    listWidgets.add(const SizedBox(width: horizontalPadding));
    listWidgets.insert(0, const SizedBox(width: horizontalPadding));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: listWidgets,
      ),
    );
  }
}
