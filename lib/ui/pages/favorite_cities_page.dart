import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_app/models/location.dart';
import 'package:weather_app/provider/location.dart';
import 'package:weather_app/ui/pages/settings_page.dart';
import 'package:weather_app/ui/views/search_city.dart';
import 'package:weather_app/util/location.dart';

class FavoriteCitiesPage extends ConsumerWidget {
  const FavoriteCitiesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteCities = ref.watch(favoriteCitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Locations"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          )
        ],
      ),
      bottomNavigationBar: SafeArea(
        maintainBottomViewPadding: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 26),
          child: FilledButton.icon(
            onPressed: () async {
              final result = await showSearch(context: context, delegate: SearchCityDelegate());
              if (result != null) {
                ref.read(favoriteCitiesProvider.notifier).add(result);
              }
              ref.invalidate(searchCityProvider);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add city'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ),
      ),
      body: _buildFavoriteCitiesList(favoriteCities, ref, context),
    );
  }

  Widget _buildFavoriteCitiesList(List<City> cities, WidgetRef ref, BuildContext context) {
    final selectedCity = ref.watch(selectedCityProvider);
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemBuilder: (context, index) {
        return ListTile(
          leading: Text(
            LocationUtils.countryCodeToEmoji(cities[index].countryCode),
            style: const TextStyle(
              fontSize: 18,
              fontFamily: "NotoColorEmoji",
            ),
          ),
          selectedTileColor: theme.colorScheme.primaryContainer,
          selected: selectedCity?.id == cities[index].id,
          title: Text(
            cities[index].name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(cities[index].admin1 ?? ""),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              ref.read(favoriteCitiesProvider.notifier).remove(cities[index]);
            },
            color: theme.iconTheme.color,
          ),
          onTap: () {
            ref.read(selectedCityProvider.notifier).set(cities[index]);
            Navigator.of(context).pop();
          },
          contentPadding: const EdgeInsets.only(left: 14),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemCount: cities.length,
    );
  }
}
