import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather.freezed.dart';
part 'weather.g.dart';

@freezed
class Weather with _$Weather {
  const factory Weather(
    double longitude,
    double latitude,
    String timezone,
    String timezoneAbbreviation,
    DailyWeatherData daily,
    HourlyWeatherData hourly,
  ) = _Weather;

  factory Weather.fromJson(Map<String, Object?> json) =>
      _$WeatherFromJson(json);
}

@freezed
sealed class WeatherUnits with _$WeatherUnits {
  const factory WeatherUnits.daily() = DailyWeatherUnits;
  const factory WeatherUnits.hourly() = HourlyWeatherUnits;

  factory WeatherUnits.fromJson(Map<String, Object?> json) =>
      _$WeatherUnitsFromJson(json);
}

@freezed
sealed class WeatherData with _$WeatherData {
  const factory WeatherData.daily(
    List<DateTime> time,
    @JsonKey(name: "temperature_2m_min") List<double> minTemperatues,
    @JsonKey(name: "temperature_2m_max") List<double> maxTemperatues,
    @JsonKey(name: "weather_code") List<int> weatherCodes,
  ) = DailyWeatherData;

  const factory WeatherData.hourly(
    List<DateTime> time,
    @JsonKey(name: "temperature_2m") List<double> temperatues,
    @JsonKey(name: "weather_code") List<int> weatherCodes,
  ) = HourlyWeatherData;

  factory WeatherData.fromJson(Map<String, Object?> json) =>
      _$WeatherDataFromJson(json);
}

@freezed
class WeatherRequest with _$WeatherRequest {
  const factory WeatherRequest({
    required double longitude,
    required double latitude,
    @Default(7) int forecastDays,
    @Default(0) int pastDays,
    @Default(7 * 24) int forecastHours,
    @Default(0) int pastHours,
    DateTime? startDate,
    DateTime? endDate,
    @Default("celsius") String temperatureUnit,
    @Default("kmh") String windSpeedUnit,
    @Default("mm") String precipitationUnit,
    @Default("auto") String timezone,
    @Default("iso8601") String timeformat,
  }) = DailyWeatherRequest;

  factory WeatherRequest.fromJson(Map<String, Object?> json) =>
      _$WeatherRequestFromJson(json);
}
