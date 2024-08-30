import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/location.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/provider/location.dart';
import 'package:weather_app/provider/weather.dart';
import 'package:weather_app/ui/widgets/weather_item.dart';
import 'package:weather_app/util/location.dart';
import 'package:weather_app/util/pair.dart';

class WeatherPage extends ConsumerStatefulWidget {
  const WeatherPage({super.key});

  @override
  ConsumerState<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends ConsumerState<WeatherPage> {
  final SearchController _searchController = SearchController();
  City? _selectedCity;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xfff6f6f8),
        appBar: AppBar(
          title: _buildNewSearchBar(),
          shape: Border(
            bottom: BorderSide(width: 1, color: Colors.grey.shade300),
          ),
        ),
        body: _buildWeather());
  }

  Widget _buildNewSearchBar() {
    return GestureDetector(
      onTap: () async {
        final result = await showSearch(context: context, delegate: SearchCityDelegate());
        if (result != null) {
          setState(() => _selectedCity = result);
        }
        ref.invalidate(searchCityProvider);
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.transparent),
            color: Colors.grey.shade200),
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.search,
              size: 22,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              _selectedCity?.name ?? "Search",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeather() {
    if (_selectedCity == null) return const SizedBox();
    final city = _selectedCity!;
    final weatherResult = ref.watch(
      weatherProvider(
        WeatherRequest(longitude: city.longitude, latitude: city.latitude, forecastHours: 7 * 24, forecastDays: 7),
      ),
    );
    return weatherResult.when(
      data: (weather) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 22),
            _buildCurrentWeather(weather, city),
            const SizedBox(height: 22),
            _buildHourlyWeather(weather),
            const SizedBox(height: 22),
            _buildWeeklyWeather(weather)
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

  Widget _buildCurrentWeather(Weather weather, City city) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 28,
            ),
            Text(
              city.name,
              style: theme.textTheme.headlineMedium,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${weather.daily.minTemperatues.last}°', style: theme.textTheme.headlineSmall),
            const SizedBox(width: 3),
            Text(
              '${weather.daily.maxTemperatues.first}°',
              style: theme.textTheme.headlineSmall?.copyWith(color: Colors.grey.shade400),
            )
          ],
        ),
      ],
    );
  }

  List<Widget> _getHourlyWeatherItems(Weather weather) {
    final hourIndexes = weather.hourly.time.foldIndexed([], (index, acc, element) {
      if(DateUtils.isSameDay(element, _selectedDate)) acc.add(index);
      return acc;
    });

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

  List<Widget> _getWeeklyWeatherItems(Weather weather) {
    return weather.daily.time.mapIndexed((index, date) {
      return GestureDetector(
        onTap: () {
          setState(() => _selectedDate = date);
        },
        child: Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 3),
          shadowColor: Colors.grey.shade200,
          shape: RoundedRectangleBorder(
                    side: DateUtils.isSameDay(_selectedDate, date)
                ? BorderSide(color: Colors.blueAccent.shade200, width: 2)
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

  Widget _buildWeeklyWeather(Weather weather) {
    const double horizontalPadding = 14;
    const double gapSize = 7;
    final items = _getWeeklyWeatherItems(weather);
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

  Widget _buildHourlyWeather(Weather weather) {
    const double horizontalPadding = 26;
    const double gapSize = 15;

    final items = _getHourlyWeatherItems(weather);
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class SearchCityDelegate extends SearchDelegate<City?> {
  SearchCityDelegate()
      : super(
          searchFieldLabel: "Search a city",
          searchFieldStyle: TextStyle(fontSize: 16, color: Colors.grey.shade800),
        );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = "",
        icon: const Icon(Icons.close),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _SearchSuggestions(
      query: query,
      onSuggestionClicked: (city) {
        close(context, city);
      },
    );
  }
}

class _SearchSuggestions extends ConsumerStatefulWidget {
  final String query;
  final void Function(City) onSuggestionClicked;

  const _SearchSuggestions({required this.query, required this.onSuggestionClicked});

  @override
  _SearchSuggestionsState createState() => _SearchSuggestionsState();
}

class _SearchSuggestionsState extends ConsumerState<_SearchSuggestions> {
  List<City> _lastResults = [];

  @override
  Widget build(BuildContext context) {
    final cities = ref.watch(searchCityProvider(search: widget.query.trim()));
    return cities.when(
      data: (data) {
        if (data.isNotEmpty) _lastResults = [...data];
        return _buildSuggestions(data);
      },
      error: (error, _) {
        return const Center(
          child: Text("Cannot fetch suggestions"),
        );
      },
      loading: () {
        if (_lastResults.isNotEmpty) {
          return _buildSuggestions(_lastResults);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildSuggestions(List<City> cities) {
    return ListView(children: cities.map((city) => _buildCitySuggestion(city)).toList());
  }

  Widget _buildCitySuggestion(City city) {
    return ListTile(
      leading: Text(
        LocationUtils.countryCodeToEmoji(city.countryCode),
        style: const TextStyle(
          fontFamily: "NotoColorEmoji",
          fontSize: 16,
        ),
      ),
      title: Text(city.name),
      subtitle: Text('${city.admin1 ?? ''}, ${city.country}'),
      onTap: () => widget.onSuggestionClicked(city),
    );
  }
}
