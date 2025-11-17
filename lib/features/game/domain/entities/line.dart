import 'package:equatable/equatable.dart';
import 'position.dart';

enum LineOrientation { horizontal, vertical }

class Line extends Equatable {
  final Position start;
  final Position end;
  final LineOrientation orientation;
  final String? ownerId; // ID do jogador que fez a linha

  const Line({
    required this.start,
    required this.end,
    required this.orientation,
    this.ownerId,
  });

  Line copyWith({
    Position? start,
    Position? end,
    LineOrientation? orientation,
    String? ownerId,
  }) {
    return Line(
      start: start ?? this.start,
      end: end ?? this.end,
      orientation: orientation ?? this.orientation,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  @override
  List<Object?> get props => [start, end, orientation, ownerId];
}
