import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'school.g.dart';

@immutable
@JsonSerializable()
class School extends Object with _$SchoolSerializerMixin {
  final String id;
  final String name;
  final String alias;
  final String address;
  final String city;
  final String state;
  @JsonKey(name: 'zip_code')
  final String zipCode;
  final String latitude;
  final String longitude;

  School({
    this.id,
    this.name,
    this.alias,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.latitude,
    this.longitude,
  });

  factory School.fromJson(Map<String, dynamic> json) => _$SchoolFromJson(json);
}
