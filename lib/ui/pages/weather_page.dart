import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/models/location.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/provider/location.dart';
import 'package:weather_app/provider/weather.dart';
import 'package:weather_app/ui/widgets/weather_item.dart';
import 'package:weather_app/util/location.dart';

class WeatherPage extends ConsumerStatefulWidget {
  const WeatherPage({super.key});

  @override
  ConsumerState<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends ConsumerState<WeatherPage> {
  final SearchController _searchController = SearchController();
  City? _selectedCity;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: _buildSearchbar(), shape: Border(bottom: BorderSide(width: 1, color: Colors.grey.shade300))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            if (_selectedCity != null)
              Padding(
                padding: const EdgeInsets.only(top: 62, left: 10, right: 10),
                child: _buildWeather(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeather() {
    final city = _selectedCity!;
    final weatherResult = ref.watch(
      weatherProvider(
        WeatherRequest(longitude: city.longitude, latitude: city.latitude, forecastHours: 24),
      ),
    );
    return weatherResult.when(
      data: (weather) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentWeather(weather, city),
            _buildHourlyWeather(weather),
          ],
        );
      },
      error: (error, stacktrace) => const Text("Error"),
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 22),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildCurrentWeather(Weather weather, City city) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          city.name,
          style: theme.textTheme.headlineLarge,
        ),
        Text(
          '${weather.daily.minTemperatues.first}°/${weather.daily.maxTemperatues.first}°',
          style: theme.textTheme.headlineMedium,
        )
      ],
    );
  }

  Widget _buildHourlyWeather(Weather weather) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: weather.hourly.time.mapIndexed((index, time) {
          return Column(
            children: [
              Text(DateFormat('HH:mm').format(weather.hourly.time[index])),
              const SizedBox(
                height: 12,
              ),
              WeatherItem(
                wmoCode: weather.hourly.weatherCodes[index],
                temperature: weather.hourly.temperatues[index],
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Iterable<Widget> _lastSuggestions = <Widget>[];
  final FocusNode _searchFocus = FocusNode();

  Widget _buildSearchbar() {
    return SearchAnchor(
      isFullScreen: true,
      viewElevation: 0,
      searchController: _searchController,
      headerTextStyle: TextStyle(fontSize: 14),
      builder: (context, controller) {
        return SearchBar(
          focusNode: _searchFocus,
          constraints: BoxConstraints.tight(Size.fromHeight(kToolbarHeight - 14)),
          elevation: WidgetStateProperty.all(0),
          shadowColor: WidgetStateProperty.all(Colors.grey.shade400),
          overlayColor: WidgetStateProperty.all(Colors.grey.shade200),
          backgroundColor: WidgetStateProperty.all(Colors.grey.shade200),
          hintText: "Search a city",
          leading: const Icon(Icons.search),
          controller: controller,
          onTap: () {
            controller.openView();
          },
          textStyle: WidgetStateProperty.all(TextStyle(fontSize: 14)),
        );
      },
      suggestionsBuilder: (context, controller) {
        ref.invalidate(searchCityProvider);
        return ref.read(searchCityProvider(search: controller.text.trim()).future).then(
          (cities) {
            final suggestions = cities.map((city) => _citySearchResult(city));
            _lastSuggestions = suggestions;
            return suggestions;
          },
        ).catchError((error) {
          return _lastSuggestions;
        });
      },
    );
  }

  Widget _citySearchResult(City city) {
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
      onTap: () {
        setState(() {
          _selectedCity = city;
        });
        _searchController.closeView(_searchController.text);
        _searchFocus.unfocus();
      },
    );
  }

  Widget _buildSearchResults(AsyncValue<List<City>> searchResult) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: searchResult.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 22),
                child: Text("No results"),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final city = data[index];
            },
          );
        },
        error: (error, stacktrace) => const Text("Error"),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 22),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
