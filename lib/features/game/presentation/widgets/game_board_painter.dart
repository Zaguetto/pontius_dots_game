import 'package:flutter/material.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/position.dart';
import '../../domain/entities/line.dart';

class GameBoardPainter extends CustomPainter {
  final GameState game;
  final void Function(Position start, Position end)? onLineTap;

  GameBoardPainter({required this.game, this.onLineTap});

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / (game.gridSize - 1);
    final dotRadius = 6.0;
    final lineWidth = 4.0;

    // Desenhar linhas disponíveis (cinza claro)
    _drawAvailableLines(canvas, cellSize, lineWidth);

    // Desenhar linhas marcadas
    _drawMarkedLines(canvas, cellSize, lineWidth);

    // Desenhar boxes completados
    _drawCompletedBoxes(canvas, cellSize);

    // Desenhar pontos
    _drawDots(canvas, cellSize, dotRadius);
  }

  void _drawAvailableLines(Canvas canvas, double cellSize, double lineWidth) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    // Linhas horizontais
    for (int row = 0; row < game.gridSize; row++) {
      for (int col = 0; col < game.gridSize - 1; col++) {
        final start = Position(row, col);
        final end = Position(row, col + 1);

        if (!_lineExists(start, end)) {
          canvas.drawLine(
            Offset(col * cellSize, row * cellSize),
            Offset((col + 1) * cellSize, row * cellSize),
            paint,
          );
        }
      }
    }

    // Linhas verticais
    for (int row = 0; row < game.gridSize - 1; row++) {
      for (int col = 0; col < game.gridSize; col++) {
        final start = Position(row, col);
        final end = Position(row + 1, col);

        if (!_lineExists(start, end)) {
          canvas.drawLine(
            Offset(col * cellSize, row * cellSize),
            Offset(col * cellSize, (row + 1) * cellSize),
            paint,
          );
        }
      }
    }
  }

  void _drawMarkedLines(Canvas canvas, double cellSize, double lineWidth) {
    for (final line in game.lines) {
      final player = game.players.firstWhere((p) => p.id == line.ownerId);
      final paint = Paint()
        ..color = _getPlayerColor(player.id)
        ..strokeWidth = lineWidth
        ..strokeCap = StrokeCap.round;

      final startOffset = Offset(
        line.start.col * cellSize,
        line.start.row * cellSize,
      );
      final endOffset = Offset(
        line.end.col * cellSize,
        line.end.row * cellSize,
      );

      canvas.drawLine(startOffset, endOffset, paint);
    }
  }

  void _drawCompletedBoxes(Canvas canvas, double cellSize) {
    for (final box in game.boxes) {
      final player = game.players.firstWhere((p) => p.id == box.ownerId);
      final color = _getPlayerColor(player.id).withOpacity(0.3);

      final rect = Rect.fromLTWH(
        box.topLeft.col * cellSize,
        box.topLeft.row * cellSize,
        cellSize,
        cellSize,
      );

      canvas.drawRect(rect, Paint()..color = color);

      // Desenhar ícone do jogador
      final textPainter = TextPainter(
        text: TextSpan(
          text: player.icon,
          style: TextStyle(fontSize: cellSize * 0.5),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          box.topLeft.col * cellSize + (cellSize - textPainter.width) / 2,
          box.topLeft.row * cellSize + (cellSize - textPainter.height) / 2,
        ),
      );
    }
  }

  void _drawDots(Canvas canvas, double cellSize, double dotRadius) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    for (int row = 0; row < game.gridSize; row++) {
      for (int col = 0; col < game.gridSize; col++) {
        canvas.drawCircle(
          Offset(col * cellSize, row * cellSize),
          dotRadius,
          paint,
        );
      }
    }
  }

  bool _lineExists(Position start, Position end) {
    return game.lines.any((line) =>
        (line.start == start && line.end == end) ||
        (line.start == end && line.end == start));
  }

  Color _getPlayerColor(String playerId) {
    final index = game.players.indexWhere((p) => p.id == playerId);
    final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange];
    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(GameBoardPainter oldDelegate) {
    return oldDelegate.game != game;
  }
}
