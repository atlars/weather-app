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
    final theme = Theme.of(context);
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
              color: theme.colorScheme.primaryFixed,
              child: SafeArea(
                child: _buildCurrentWeather(weather, city, context, ref, theme),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 220),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.only(
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
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        indicatorPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        enableFeedback: false,
        controller: tabController,
        labelPadding: EdgeInsets.zero,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: const [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.thermostat, size: 16),
                SizedBox(width: 2),
                Text('Temperature', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.water_drop, size: 16),
                SizedBox(width: 2),
                Text('Rain', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.air, size: 16),
                SizedBox(width: 2),
                Text('Wind', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeather(Weather weather, City city, BuildContext context, WidgetRef ref, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(city, theme, context, ref),
          Padding(
            padding: const EdgeInsets.only(bottom: 26, top: 18),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                '${weather.current.temperatue.toInt()}°',
                style: theme.textTheme.headlineLarge
                    ?.copyWith(color: theme.colorScheme.onPrimaryFixed, fontWeight: FontWeight.w600, fontSize: 46),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherDataTile(Icons.water_drop, "${weather.current.rainProbability}%", 3, theme),
              _buildWeatherDataTile(Icons.air, "${weather.current.windSpeed}km/h", 3, theme)
            ],
          )
        ],
      ),
    );
  }

  Widget _buildWeatherDataTile(IconData icon, String text, double gap, ThemeData theme) {
    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.onPrimaryFixed,
        ),
        if (gap > 0) SizedBox(width: gap),
        Text(
          text,
          style: TextStyle(color: theme.colorScheme.onPrimaryFixed, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildAppBar(City city, ThemeData theme, BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          color: theme.colorScheme.onPrimaryFixed,
          size: 24,
        ),
        Text(
          city.name,
          style: TextStyle(fontWeight: FontWeight.w400, color: theme.colorScheme.onPrimaryFixed, fontSize: 20),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FavoriteCitiesPage()));
          },
          icon: Icon(
            Icons.menu_sharp,
            color: theme.colorScheme.onPrimaryFixed,
            size: 28,
          ),
        )
      ],
    );
  }
}
