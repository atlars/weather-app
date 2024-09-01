import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weather_app/models/location.dart';
import 'package:weather_app/provider/location.dart';
import 'package:weather_app/ui/widgets/weather_overview.dart';
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
      backgroundColor: const Color(0xfff6f6f8),
      appBar: AppBar(
        title: _buildNewSearchBar(),
        shape: Border(
          bottom: BorderSide(width: 1, color: Colors.grey.shade300),
        ),
      ),
      body: _selectedCity != null ? WeatherOverview(city: _selectedCity!) : const SizedBox(),
    );
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
          color: Colors.grey.shade200,
        ),
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
