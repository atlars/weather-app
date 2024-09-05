import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_app/provider/prefs.dart';
import 'package:weather_app/provider/theme.dart';
import 'package:weather_app/ui/pages/weather_page.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Preserves the native splash screen until FlutterNativeSplash.remove() is called
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    const ProviderScope(
      child: _EagerInitialization(
        child: WeatherApp(),
      ),
    ),
  );
}

/// Only returns the [child] when the watched providers are initialized
class _EagerInitialization extends ConsumerWidget {
  const _EagerInitialization({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Providers that are initialized eagerly
    final values = [
      ref.watch(prefsProvider),
    ];

    if (values.every((value) => value.hasValue)) {
      return child;
    }

    return const SizedBox();
  }
}

class WeatherApp extends ConsumerStatefulWidget {
  const WeatherApp({super.key});

  @override
  ConsumerState<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends ConsumerState<WeatherApp> {

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Weahter app",
      theme: ref.watch(lightThemeProvider),
      darkTheme: ref.watch(darkThemeProvider),
      themeMode: ref.watch(currentThemeModeProvider),
      home: const WeatherPage(),
      scrollBehavior: WebScrollBehavior(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WebScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}
