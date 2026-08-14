import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/genre.dart';

part 'genre_model.g.dart';

@JsonSerializable()
class GenreModel {
  final int id;
  final String name;

  const GenreModel({
    required this.id,
    required this.name,
  });

  factory GenreModel.fromJson(Map<String, dynamic> json) =>
      _$GenreModelFromJson(json);

  Map<String, dynamic> toJson() => _$GenreModelToJson(this);

  Genre toEntity() => Genre(id: id, name: name);
}

@JsonSerializable()
class GenreResponseModel {
  final List<GenreModel> genres;

  const GenreResponseModel({required this.genres});

  factory GenreResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GenreResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GenreResponseModelToJson(this);
}
