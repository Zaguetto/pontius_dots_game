import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/game_state.dart';
import '../bloc/game_bloc.dart';

class GameOverDialog extends StatelessWidget {
  final GameState game;

  const GameOverDialog({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final winner = game.winner;
    final isDraw = winner == null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isDraw ? '🤝' : '🎉',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              isDraw ? 'Empate!' : 'Vitória!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (!isDraw)
              Text(
                '${winner!.icon} ${winner.name}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            const SizedBox(height: 24),
            _buildScoreboard(context),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Menu'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _restartGame(context);
                    },
                    child: const Text('Jogar Novamente'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreboard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: game.players.map((player) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(player.icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      player.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${player.score}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _restartGame(BuildContext context) {
    context.read<GameBloc>().add(
          StartGameEvent(
            mode: game.mode,
            gridSize: game.gridSize,
            player1: game.players[0],
            player2: game.players.length > 1 ? game.players[1] : null,
          ),
        );
  }
}
