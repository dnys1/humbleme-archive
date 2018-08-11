// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_picture.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfilePicture _$ProfilePictureFromJson(Map<String, dynamic> json) =>
    new ProfilePicture(
        id: json['id'] as String,
        path: json['path'] as String,
        downloadUrl: json['downloadUrl'] as String,
        dateTime: json['dateTime'] == null
            ? null
            : dateTimeFromJson(json['dateTime']));

abstract class _$ProfilePictureSerializerMixin {
  String get id;
  String get path;
  String get downloadUrl;
  DateTime get dateTime;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'path': path,
        'downloadUrl': downloadUrl,
        'dateTime': dateTime == null ? null : dateTimeToJson(dateTime)
      };
}
