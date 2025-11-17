import 'package:equatable/equatable.dart';

class Player extends Equatable {
  final String id;
  final String name;
  final String icon;
  final int score;
  final bool isBot;

  const Player({
    required this.id,
    required this.name,
    required this.icon,
    this.score = 0,
    this.isBot = false,
  });

  Player copyWith({
    String? id,
    String? name,
    String? icon,
    int? score,
    bool? isBot,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      score: score ?? this.score,
      isBot: isBot ?? this.isBot,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, score, isBot];
}
