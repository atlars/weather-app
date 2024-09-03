import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_app/models/location.dart';
import 'package:weather_app/provider/location.dart';
import 'package:weather_app/util/location.dart';

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