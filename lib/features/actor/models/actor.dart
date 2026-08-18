import 'package:equatable/equatable.dart';

class KnownMovie extends Equatable {
  final int id;
  final String title;
  final String posterPath;

  const KnownMovie({
    required this.id,
    required this.title,
    required this.posterPath,
  });

  factory KnownMovie.fromJson(Map<String, dynamic> json) {
    return KnownMovie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      posterPath: json['posterPath'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'posterPath': posterPath,
      };

  @override
  List<Object?> get props => [id, title, posterPath];
}

class Actor extends Equatable {
  final int id;
  final String name;
  final String profilePath;
  final String biography;
  final String birthday;
  final String placeOfBirth;
  final List<KnownMovie> knownFor;

  const Actor({
    required this.id,
    required this.name,
    required this.profilePath,
    required this.biography,
    required this.birthday,
    required this.placeOfBirth,
    required this.knownFor,
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    final knownForList = (json['knownFor'] as List<dynamic>?)
            ?.map((e) => KnownMovie.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return Actor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profilePath: json['profilePath'] ?? '',
      biography: json['biography'] ?? '',
      birthday: json['birthday'] ?? '',
      placeOfBirth: json['placeOfBirth'] ?? '',
      knownFor: knownForList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'profilePath': profilePath,
        'biography': biography,
        'birthday': birthday,
        'placeOfBirth': placeOfBirth,
        'knownFor': knownFor.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        id,
        name,
        profilePath,
        biography,
        birthday,
        placeOfBirth,
        knownFor,
      ];
}
