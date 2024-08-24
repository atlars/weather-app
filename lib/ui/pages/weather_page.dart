import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_app/models/location.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/provider/location.dart';
import 'package:weather_app/provider/weather.dart';
import 'package:weather_app/util/location.dart';
import 'package:weather_app/ui/widgets/weather_item.dart';
import 'package:intl/intl.dart';

class WeatherPage extends ConsumerStatefulWidget {
  const WeatherPage({super.key});

  @override
  ConsumerState<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends ConsumerState<WeatherPage> {
  final TextEditingController _searchController = TextEditingController();
  City? _selectedCity;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final searchResult = ref.watch(searchCityProvider(search: _searchController.text));

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_outlined),
            SizedBox(width: 8),
            Text('Weather'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            if (_selectedCity != null)
              Padding(
                padding: const EdgeInsets.only(top: 62, left: 10, right: 10),
                child: _buildWeather(),
              ),
            _buildSearchBar(searchResult),
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
              const SizedBox(height: 12,),
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

  Widget _buildSearchBar(AsyncValue<List<City>> searchResult) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onTapOutside: (event) => {FocusManager.instance.primaryFocus?.unfocus()},
          onChanged: (value) => ref.invalidate(searchCityProvider),
          decoration: InputDecoration(
            hintText: 'Search for a city',
            hintStyle: TextStyle(color: Colors.grey.shade800),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 8, right: 4),
              child: Icon(Icons.search),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  ref.invalidate(searchCityProvider);
                  _searchController.clear();
                },
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: _buildTextfieldBorder(),
            focusedBorder: _buildTextfieldBorder(),
          ),
          style: const TextStyle(fontSize: 16),
        ),
        if (_searchController.text.isNotEmpty) _buildSearchResults(searchResult)
      ],
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
              return ListTile(
                leading: Text(
                  LocationUtils.countryCodeToEmoji(data[index].countryCode),
                  style: const TextStyle(
                    fontFamily: "NotoColorEmoji",
                    fontSize: 16,
                  ),
                ),
                title: Text(city.name),
                subtitle: Text('${city.admin1 ?? ''}, ${city.country}'),
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  setState(() => _selectedCity = data[index]);
                  _searchController.clear();
                },
              );
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

  OutlineInputBorder _buildTextfieldBorder() {
    return OutlineInputBorder(
      borderRadius: _searchController.text.isNotEmpty
          ? const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            )
          : BorderRadius.circular(30),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
