import 'package:equatable/equatable.dart';

class Position extends Equatable {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  List<Object?> get props => [row, col];

  @override
  String toString() => '($row, $col)';
}
