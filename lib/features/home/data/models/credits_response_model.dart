import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/cast.dart';

part 'credits_response_model.g.dart';

@JsonSerializable()
class CastModel {
  final int id;
  final String name;
  final String? character;
  @JsonKey(name: 'profile_path')
  final String? profilePath;
  final int? order;

  CastModel({
    required this.id,
    required this.name,
    this.character,
    this.profilePath,
    this.order,
  });

  factory CastModel.fromJson(Map<String, dynamic> json) =>
      _$CastModelFromJson(json);

  Map<String, dynamic> toJson() => _$CastModelToJson(this);

  Cast toEntity() {
    return Cast(
      id: id,
      name: name,
      character: character ?? 'Actor',
      profilePath: profilePath,
      order: order ?? 0,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CreditsResponseModel {
  final int id;
  final List<CastModel> cast;

  CreditsResponseModel({
    required this.id,
    required this.cast,
  });

  factory CreditsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CreditsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreditsResponseModelToJson(this);
}
