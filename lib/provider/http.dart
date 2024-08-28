import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      responseType: ResponseType.json,
    ),
  );

  dio.interceptors.add(LogInterceptor(
    request: true,
    error: true,
    logPrint: (object) => print("Response"),
  ));
  ref.onDispose(dio.close);
  return dio;
});