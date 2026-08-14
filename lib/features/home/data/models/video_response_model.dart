import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/video.dart';

part 'video_response_model.g.dart';

@JsonSerializable()
class VideoModel {
  final String id;
  final String name;
  final String key;
  final String site;
  final String type;
  final bool? official;

  VideoModel({
    required this.id,
    required this.name,
    required this.key,
    required this.site,
    required this.type,
    this.official,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) =>
      _$VideoModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoModelToJson(this);

  Video toEntity() {
    return Video(
      id: id,
      name: name,
      key: key,
      site: site,
      type: type,
      official: official ?? false,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class VideoResponseModel {
  final int id;
  final List<VideoModel> results;

  VideoResponseModel({
    required this.id,
    required this.results,
  });

  factory VideoResponseModel.fromJson(Map<String, dynamic> json) =>
      _$VideoResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$VideoResponseModelToJson(this);
}
