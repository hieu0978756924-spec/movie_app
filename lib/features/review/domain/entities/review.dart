import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String author;
  final String? avatarUrl;
  final double rating;
  final String content;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.author,
    this.avatarUrl,
    required this.rating,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        author,
        avatarUrl,
        rating,
        content,
        createdAt,
      ];
}
