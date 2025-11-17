import 'package:equatable/equatable.dart';
import 'position.dart';

class Box extends Equatable {
  final Position topLeft;
  final String? ownerId; // ID do jogador que completou o quadrado

  const Box({
    required this.topLeft,
    this.ownerId,
  });

  Box copyWith({
    Position? topLeft,
    String? ownerId,
  }) {
    return Box(
      topLeft: topLeft ?? this.topLeft,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  @override
  List<Object?> get props => [topLeft, ownerId];
}
