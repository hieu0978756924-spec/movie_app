import 'package:equatable/equatable.dart';

class Video extends Equatable {
  final String id;
  final String name;
  final String key;
  final String site;
  final String type;
  final bool official;

  const Video({
    required this.id,
    required this.name,
    required this.key,
    required this.site,
    required this.type,
    this.official = false,
  });

  @override
  List<Object?> get props => [id, name, key, site, type, official];
}
