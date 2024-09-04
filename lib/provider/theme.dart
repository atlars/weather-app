import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
    colorScheme: const ColorScheme.dark().copyWith(
      primary: const Color(4289054974),
      onPrimary: const Color.fromARGB(255, 42, 42, 42),
      primaryContainer: const Color.fromARGB(255, 103, 103, 103),
      secondary: const Color(4290562012),
      onSurface: const Color(0xffffffff),
      surface: const Color.fromARGB(255, 28, 28, 28),
      surfaceContainerLow: const Color.fromARGB(255, 40, 40, 40),
      surfaceContainerHighest: const Color.fromARGB(255, 64, 68, 69),
      onSurfaceVariant: const Color(0xffffffff),
    ),
    textTheme: GoogleFonts.openSansTextTheme(textTheme),
    useMaterial3: true,
  ).copyWith(
    shadowColor: Colors.grey.shade800,
  );
}

@riverpod
ThemeData lightTheme(LightThemeRef ref) {
  final textTheme = ref.watch(textThemeProvider);
  return ThemeData.from(
    colorScheme: const ColorScheme.light().copyWith(
      primary: const Color(0xff2b5d98),
      onPrimary: const Color(0xffffffff),
      surfaceBright: const Color(0xffffffff),
      surface: const Color(0xffffffff),
      surfaceContainerHighest: const Color.fromARGB(255, 218, 229, 231),
      surfaceContainer: const Color(0xffefefef),
      onSecondary: const Color(0xff3a3949),
      primaryContainer: const Color.fromARGB(255, 218, 229, 231),
    ),
    textTheme: GoogleFonts.openSansTextTheme(textTheme),
    useMaterial3: true,
  ).copyWith(
    iconTheme: const IconThemeData(
      color: Color.fromARGB(255, 58, 58, 58),
    ),
    focusColor: Colors.blue.shade800,
  );
}

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);