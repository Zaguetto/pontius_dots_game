import 'dart:math';
import 'package:dartz/dartz.dart';
import '../entities/game_state.dart';
import '../entities/position.dart';
import '../../../../core/error/failures.dart';
import 'make_move_usecases.dart';

class BotMoveUseCase {
  final MakeMoveUseCase makeMoveUseCase;

  BotMoveUseCase(this.makeMoveUseCase);

  Future<Either<Failure, GameState>> call(GameState game) async {
    try {
      // Estratégia do Bot (pode ser melhorada!)
      final move = _getBestMove(game);

      if (move == null) {
        return Left(InvalidMoveFailure('Nenhum movimento disponível'));
      }

      return await makeMoveUseCase(
        game: game,
        start: move.$1,
        end: move.$2,
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  (Position, Position)? _getBestMove(GameState game) {
    final availableMoves = _getAvailableMoves(game);

    if (availableMoves.isEmpty) return null;

    // Estratégia 1: Completar quadrados quando possível
    final completingMoves = availableMoves.where((move) {
      return _willCompleteBox(game, move.$1, move.$2);
    }).toList();

    if (completingMoves.isNotEmpty) {
      return completingMoves[Random().nextInt(completingMoves.length)];
    }

    // Estratégia 2: Evitar dar 3 lados de um quadrado
    final safeMoves = availableMoves.where((move) {
      return !_willGiveThreeSides(game, move.$1, move.$2);
    }).toList();

    if (safeMoves.isNotEmpty) {
      return safeMoves[Random().nextInt(safeMoves.length)];
    }

    // Estratégia 3: Movimento aleatório
    return availableMoves[Random().nextInt(availableMoves.length)];
  }

  List<(Position, Position)> _getAvailableMoves(GameState game) {
    final moves = <(Position, Position)>[];

    // Linhas horizontais
    for (int row = 0; row < game.gridSize; row++) {
      for (int col = 0; col < game.gridSize - 1; col++) {
        final start = Position(row, col);
        final end = Position(row, col + 1);

        if (!_lineExists(game, start, end)) {
          moves.add((start, end));
        }
      }
    }

    // Linhas verticais
    for (int row = 0; row < game.gridSize - 1; row++) {
      for (int col = 0; col < game.gridSize; col++) {
        final start = Position(row, col);
        final end = Position(row + 1, col);

        if (!_lineExists(game, start, end)) {
          moves.add((start, end));
        }
      }
    }

    return moves;
  }

  bool _lineExists(GameState game, Position start, Position end) {
    return game.lines.any((line) =>
        (line.start == start && line.end == end) ||
        (line.start == end && line.end == start));
  }

  bool _willCompleteBox(GameState game, Position start, Position end) {
    // Simula o movimento e verifica se completa algum box
    // (implementação simplificada)
    return false; // TODO: Implementar lógica completa
  }

  bool _willGiveThreeSides(GameState game, Position start, Position end) {
    // Verifica se o movimento deixará 3 lados completos em algum box
    // (implementação simplificada)
    return false; // TODO: Implementar lógica completa
  }
}
