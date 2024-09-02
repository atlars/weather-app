import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme.g.dart';

@riverpod
TextTheme textTheme(TextThemeRef ref) {
  return const TextTheme(
    headlineLarge: TextStyle(fontSize: 38),
  );
}

@riverpod
ThemeData darkTheme(DarkThemeRef ref) {
  final textTheme = ref.watch(textThemeProvider);
  return ThemeData.from(
    colorScheme: const ColorScheme.highContrastDark(),
    textTheme: textTheme,
    useMaterial3: true,
  ).copyWith(
    iconTheme: const IconThemeData(color: Colors.white),
  );
}

@riverpod
ThemeData lightTheme(LightThemeRef ref) {
  final textTheme = ref.watch(textThemeProvider);
  return ThemeData.from(
    colorScheme: const ColorScheme.highContrastLight(),
    textTheme: textTheme,
    useMaterial3: true,
  ).copyWith(
    iconTheme: const IconThemeData(color: Color.fromARGB(255, 58, 58, 58)),
  );
}

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
