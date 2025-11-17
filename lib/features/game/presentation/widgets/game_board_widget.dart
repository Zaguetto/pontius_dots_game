import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/position.dart';
import '../bloc/game_bloc.dart';
import 'game_board_painter.dart';

class GameBoardWidget extends StatelessWidget {
  final GameState game;

  const GameBoardWidget({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth * 0.9
            : constraints.maxHeight * 0.9;

        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: GameBoardPainter(
                game: game,
                onLineTap: game.status == GameStatus.playing &&
                        !game.currentPlayer.isBot
                    ? (start, end) {
                        context.read<GameBloc>().add(
                              MakeMoveEvent(start: start, end: end),
                            );
                      }
                    : null,
              ),
              child: GestureDetector(
                onTapUp: (details) => _handleTap(context, details, size),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTap(BuildContext context, TapUpDetails details, double size) {
    if (game.status != GameStatus.playing || game.currentPlayer.isBot) {
      return;
    }

    final cellSize = size / (game.gridSize - 1);
    final tapX = details.localPosition.dx;
    final tapY = details.localPosition.dy;

    // Detectar linha mais próxima
    final nearestLine = _detectNearestLine(tapX, tapY, cellSize);

    if (nearestLine != null) {
      final start = nearestLine.$1;
      final end = nearestLine.$2;
      context.read<GameBloc>().add(
            MakeMoveEvent(start: start, end: end),
          );
    }
  }

  (Position, Position)? _detectNearestLine(
    double tapX,
    double tapY,
    double cellSize,
  ) {
    const threshold = 20.0; // pixels de tolerância

    // Verificar linhas horizontais
    for (int row = 0; row < game.gridSize; row++) {
      for (int col = 0; col < game.gridSize - 1; col++) {
        final lineY = row * cellSize;
        final lineX1 = col * cellSize;
        final lineX2 = (col + 1) * cellSize;

        if ((tapY - lineY).abs() < threshold &&
            tapX >= lineX1 - threshold &&
            tapX <= lineX2 + threshold) {
          return (Position(row, col), Position(row, col + 1));
        }
      }
    }

    // Verificar linhas verticais
    for (int row = 0; row < game.gridSize - 1; row++) {
      for (int col = 0; col < game.gridSize; col++) {
        final lineX = col * cellSize;
        final lineY1 = row * cellSize;
        final lineY2 = (row + 1) * cellSize;

        if ((tapX - lineX).abs() < threshold &&
            tapY >= lineY1 - threshold &&
            tapY <= lineY2 + threshold) {
          return (Position(row, col), Position(row + 1, col));
        }
      }
    }

    return null;
  }
}