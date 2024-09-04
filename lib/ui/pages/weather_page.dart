import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weather_app/models/location.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/provider/location.dart';
import 'package:weather_app/provider/weather.dart';
import 'package:weather_app/ui/pages/favorite_cities_page.dart';
import 'package:weather_app/ui/widgets/daily_weather_list.dart';
import 'package:weather_app/ui/widgets/hourly_weather_list.dart';

class WeatherPage extends HookConsumerWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCity = ref.watch(selectedCityProvider);

    return Scaffold(
      body: selectedCity != null ? _buildWeather(selectedCity, ref, context) : _buildNoCitySelected(context),
    );
  }

  Widget _buildNoCitySelected(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("No city selected"),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FavoriteCitiesPage()));
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text("Add"),
          )
        ],
      ),
    );
  }

  Widget _buildWeather(City city, WidgetRef ref, BuildContext context) {
    final tabController = useTabController(initialLength: 3);
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
                const SizedBox(height: 240),
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
                        DailyWeatherList(
                          weatherData: weather.daily,
                          onDaySelected: (date) {
                            selectedDate.value = date;
                          },
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        );
      },
      error: (error, stacktrace) {
        return const Center(child: Text("Error"));
      },
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
          HourlyWeatherList(weatherData: weather.hourly, day: selectedDate.value),
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
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200,
        ),
        indicatorPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        enableFeedback: false,
        controller: tabController,
        labelStyle: theme.textTheme.labelSmall,
        labelPadding: EdgeInsets.zero,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: [
          Tab(
            child: RichText(
              text: const TextSpan(
                children: [
                  WidgetSpan(
                    child: Icon(Icons.thermostat, size: 16),
                    alignment: PlaceholderAlignment.middle,
                  ),
                  TextSpan(
                    text: ' Temperature',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          Tab(
            child: RichText(
              text: const TextSpan(
                children: [
                  WidgetSpan(
                    child: Icon(Icons.water_drop, size: 16),
                    alignment: PlaceholderAlignment.middle,
                  ),
                  TextSpan(
                    text: ' Rain',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          Tab(
            child: RichText(
              text: const TextSpan(
                children: [
                  WidgetSpan(
                    child: Icon(Icons.air, size: 16),
                    alignment: PlaceholderAlignment.middle,
                  ),
                  TextSpan(
                    text: ' Wind',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ],      ),
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
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FavoriteCitiesPage()));
          },
          icon: const Icon(
            Icons.menu_sharp,
            color: Color(0xff2b5d98),
            size: 28,
          ),
        )
      ],
    );
  }
}
