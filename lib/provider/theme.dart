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
      primary: const Color(0xff1f3046),
      onPrimary: const Color(0xffffffff),
    ),
    textTheme: GoogleFonts.openSansTextTheme(textTheme),
    useMaterial3: true,
  ).copyWith(
    iconTheme: const IconThemeData(color: Colors.white),
  );
}

// Color(0xffc5e1fd)
@riverpod
ThemeData lightTheme(LightThemeRef ref) {
  final textTheme = ref.watch(textThemeProvider);
  return ThemeData.from(
    colorScheme: const ColorScheme.light().copyWith(
      primary: const Color(0xff2b5d98),
      surfaceBright: const Color(0xffffffff),
      onPrimary: const Color(0xffffffff),
      surface: const Color(0xffffffff),
      surfaceContainer: const Color(0xffefefef),
      secondary: const Color(0xfff6f6f8),
      onSecondary: const Color(0xff3a3949),
    ),
    textTheme: GoogleFonts.nunitoTextTheme(textTheme),
    useMaterial3: true,
  ).copyWith(
    iconTheme: const IconThemeData(
      color: Color.fromARGB(255, 58, 58, 58),
    ),
  );
}

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
