import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      responseType: ResponseType.json,
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      error: true,
      logPrint: (object) => debugPrint(object.toString()),
    ));
  }
  ref.onDispose(dio.close);
  return dio;
});
