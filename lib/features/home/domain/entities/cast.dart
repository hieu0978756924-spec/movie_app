import 'package:equatable/equatable.dart';

class Cast extends Equatable {
  final int id;
  final String name;
  final String character;
  final String? profilePath;
  final int order;

  const Cast({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
    this.order = 0,
  });

  @override
  List<Object?> get props => [id, name, character, profilePath, order];
}
