// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'school.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

School _$SchoolFromJson(Map<String, dynamic> json) => new School(
    id: json['id'] as String,
    name: json['name'] as String,
    alias: json['alias'] as String,
    address: json['address'] as String,
    city: json['city'] as String,
    state: json['state'] as String,
    zipCode: json['zip_code'] as String,
    latitude: json['latitude'] as String,
    longitude: json['longitude'] as String);

abstract class _$SchoolSerializerMixin {
  String get id;
  String get name;
  String get alias;
  String get address;
  String get city;
  String get state;
  String get zipCode;
  String get latitude;
  String get longitude;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'alias': alias,
        'address': address,
        'city': city,
        'state': state,
        'zip_code': zipCode,
        'latitude': latitude,
        'longitude': longitude
      };
}
