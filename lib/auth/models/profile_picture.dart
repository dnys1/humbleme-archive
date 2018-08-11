import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'util.dart';

part 'profile_picture.g.dart';

@immutable
@JsonSerializable()
class ProfilePicture extends Object with _$ProfilePictureSerializerMixin {
  final String id;
  final String path;
  final String downloadUrl;
  @JsonKey(fromJson: dateTimeFromJson, toJson: dateTimeToJson)
  final DateTime dateTime;

  ProfilePicture({
    this.id,
    this.path,
    this.downloadUrl,
    this.dateTime,
  });

  factory ProfilePicture.fromJson(Map<String, dynamic> json) =>
      _$ProfilePictureFromJson(json);
}
