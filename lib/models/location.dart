import 'package:freezed_annotation/freezed_annotation.dart';

part 'location.freezed.dart';
part 'location.g.dart';

@freezed
class City with _$City {
  const factory City(
    int id,
    String name,
    double longitude,
    double latitude,
    String country,
    String countryCode,
    List<String>? postcodes,
    String? admin1,
    String? admin2,
    String? admin3,
    String? admin4,
  ) = _City;

  factory City.fromJson(Map<String, Object?> json) => _$CityFromJson(json);
}