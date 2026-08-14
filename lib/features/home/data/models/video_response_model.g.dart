// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoModel _$VideoModelFromJson(Map<String, dynamic> json) => VideoModel(
      id: json['id'] as String,
      name: json['name'] as String,
      key: json['key'] as String,
      site: json['site'] as String,
      type: json['type'] as String,
      official: json['official'] as bool?,
    );

Map<String, dynamic> _$VideoModelToJson(VideoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'key': instance.key,
      'site': instance.site,
      'type': instance.type,
      'official': instance.official,
    };

VideoResponseModel _$VideoResponseModelFromJson(Map<String, dynamic> json) =>
    VideoResponseModel(
      id: (json['id'] as num).toInt(),
      results: (json['results'] as List<dynamic>)
          .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VideoResponseModelToJson(VideoResponseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'results': instance.results.map((e) => e.toJson()).toList(),
    };
