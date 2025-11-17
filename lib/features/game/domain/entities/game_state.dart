import 'package:equatable/equatable.dart';
import 'player.dart';
import 'line.dart';
import 'box.dart';

enum GameMode { onePlayer, twoPlayers, online }

enum GameStatus { notStarted, playing, paused, finished }

class GameState extends Equatable {
  final String id;
  final GameMode mode;
  final GameStatus status;
  final int gridSize; // Número de pontos por lado (ex: 6 = grid 6x6)
  final List<Player> players;
  final int currentPlayerIndex;
  final List<Line> lines;
  final List<Box> boxes;
  final bool hasExtraTurn;

  const GameState({
    required this.id,
    required this.mode,
    required this.status,
    required this.gridSize,
    required this.players,
    this.currentPlayerIndex = 0,
    this.lines = const [],
    this.boxes = const [],
    this.hasExtraTurn = false,
  });

  Player get currentPlayer => players[currentPlayerIndex];

  Player? get winner {
    if (status != GameStatus.finished) return null;
    final sortedPlayers = List<Player>.from(players)
      ..sort((a, b) => b.score.compareTo(a.score));
    return sortedPlayers.first.score > sortedPlayers.last.score
        ? sortedPlayers.first
        : null;
  }

  int get totalBoxes => (gridSize - 1) * (gridSize - 1);

  GameState copyWith({
    String? id,
    GameMode? mode,
    GameStatus? status,
    int? gridSize,
    List<Player>? players,
    int? currentPlayerIndex,
    List<Line>? lines,
    List<Box>? boxes,
    bool? hasExtraTurn,
  }) {
    return GameState(
      id: id ?? this.id,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      gridSize: gridSize ?? this.gridSize,
      players: players ?? this.players,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      lines: lines ?? this.lines,
      boxes: boxes ?? this.boxes,
      hasExtraTurn: hasExtraTurn ?? this.hasExtraTurn,
    );
  }

  @override
  List<Object?> get props => [
        id,
        mode,
        status,
        gridSize,
        players,
        currentPlayerIndex,
        lines,
        boxes,
        hasExtraTurn,
      ];
}
