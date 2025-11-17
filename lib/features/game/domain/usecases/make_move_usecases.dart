import 'package:dartz/dartz.dart';
import '../entities/game_state.dart';
import '../entities/position.dart';
import '../entities/line.dart';
import '../entities/box.dart';
import '../entities/player.dart';
import '../../../../core/error/failures.dart';

class MakeMoveUseCase {
  Future<Either<Failure, GameState>> call({
    required GameState game,
    required Position start,
    required Position end,
  }) async {
    try {
      // Validar movimento
      if (!_isValidMove(game, start, end)) {
        return Left(InvalidMoveFailure('Movimento inválido'));
      }

      // Verificar se linha já existe
      if (_lineExists(game, start, end)) {
        return Left(InvalidMoveFailure('Linha já foi marcada'));
      }

      // Determinar orientação
      final orientation = _getOrientation(start, end);

      // Criar nova linha
      final newLine = Line(
        start: start,
        end: end,
        orientation: orientation,
        ownerId: game.currentPlayer.id,
      );

      final updatedLines = [...game.lines, newLine];

      // Verificar quadrados completados
      final completedBoxes = _checkCompletedBoxes(game, newLine, updatedLines);

      final updatedBoxes = [...game.boxes, ...completedBoxes];

      // Atualizar score dos jogadores
      final updatedPlayers = _updatePlayersScore(
        game.players,
        game.currentPlayer.id,
        completedBoxes.length,
      );

      // Determinar se há turno extra
      final hasExtraTurn = completedBoxes.isNotEmpty;

      // Próximo jogador (se não houver turno extra)
      final nextPlayerIndex = hasExtraTurn
          ? game.currentPlayerIndex
          : (game.currentPlayerIndex + 1) % game.players.length;

      // Verificar se o jogo terminou
      final isGameFinished = updatedBoxes.length == game.totalBoxes;

      final updatedGame = game.copyWith(
        lines: updatedLines,
        boxes: updatedBoxes,
        players: updatedPlayers,
        currentPlayerIndex: nextPlayerIndex,
        hasExtraTurn: hasExtraTurn,
        status: isGameFinished ? GameStatus.finished : GameStatus.playing,
      );

      return Right(updatedGame);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  bool _isValidMove(GameState game, Position start, Position end) {
    // Verificar se os pontos estão dentro do grid
    if (start.row < 0 ||
        start.row >= game.gridSize ||
        start.col < 0 ||
        start.col >= game.gridSize ||
        end.row < 0 ||
        end.row >= game.gridSize ||
        end.col < 0 ||
        end.col >= game.gridSize) {
      return false;
    }

    // Verificar se são pontos adjacentes
    final rowDiff = (start.row - end.row).abs();
    final colDiff = (start.col - end.col).abs();

    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
  }

  bool _lineExists(GameState game, Position start, Position end) {
    return game.lines.any((line) =>
        (line.start == start && line.end == end) ||
        (line.start == end && line.end == start));
  }

  LineOrientation _getOrientation(Position start, Position end) {
    return start.row == end.row
        ? LineOrientation.horizontal
        : LineOrientation.vertical;
  }

  List<Box> _checkCompletedBoxes(
    GameState game,
    Line newLine,
    List<Line> allLines,
  ) {
    final completedBoxes = <Box>[];

    // Verificar todos os possíveis quadrados que essa linha pode completar
    final potentialBoxes = _getPotentialBoxes(game, newLine);

    for (final boxPosition in potentialBoxes) {
      if (_isBoxCompleted(boxPosition, allLines)) {
        // Verificar se o box já não foi contado
        final alreadyCompleted = game.boxes.any(
          (box) => box.topLeft == boxPosition,
        );

        if (!alreadyCompleted) {
          completedBoxes.add(
            Box(
              topLeft: boxPosition,
              ownerId: game.currentPlayer.id,
            ),
          );
        }
      }
    }

    return completedBoxes;
  }

  List<Position> _getPotentialBoxes(GameState game, Line line) {
    final boxes = <Position>[];

    if (line.orientation == LineOrientation.horizontal) {
      // Linha horizontal pode completar box acima ou abaixo
      final row = line.start.row;
      final col = line.start.col < line.end.col ? line.start.col : line.end.col;

      // Box acima
      if (row > 0) {
        boxes.add(Position(row - 1, col));
      }
      // Box abaixo
      if (row < game.gridSize - 1) {
        boxes.add(Position(row, col));
      }
    } else {
      // Linha vertical pode completar box à esquerda ou à direita
      final col = line.start.col;
      final row = line.start.row < line.end.row ? line.start.row : line.end.row;

      // Box à esquerda
      if (col > 0) {
        boxes.add(Position(row, col - 1));
      }
      // Box à direita
      if (col < game.gridSize - 1) {
        boxes.add(Position(row, col));
      }
    }

    return boxes;
  }

  bool _isBoxCompleted(Position topLeft, List<Line> lines) {
    final top = Position(topLeft.row, topLeft.col);
    final bottom = Position(topLeft.row + 1, topLeft.col);
    final left = Position(topLeft.row, topLeft.col);
    final right = Position(topLeft.row, topLeft.col + 1);

    // Verificar as 4 linhas do quadrado
    final hasTop = _hasLine(lines, top, Position(top.row, top.col + 1));
    final hasBottom =
        _hasLine(lines, bottom, Position(bottom.row, bottom.col + 1));
    final hasLeft = _hasLine(lines, left, Position(left.row + 1, left.col));
    final hasRight = _hasLine(lines, right, Position(right.row + 1, right.col));

    return hasTop && hasBottom && hasLeft && hasRight;
  }

  bool _hasLine(List<Line> lines, Position p1, Position p2) {
    return lines.any((line) =>
        (line.start == p1 && line.end == p2) ||
        (line.start == p2 && line.end == p1));
  }

  List<Player> _updatePlayersScore(
    List<Player> players,
    String currentPlayerId,
    int additionalScore,
  ) {
    return players.map((player) {
      if (player.id == currentPlayerId) {
        return player.copyWith(score: player.score + additionalScore);
      }
      return player;
    }).toList();
  }
}
