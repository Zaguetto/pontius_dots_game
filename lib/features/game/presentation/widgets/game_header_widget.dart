import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/game_state.dart';
import '../bloc/game_bloc.dart';

class GameHeaderWidget extends StatelessWidget {
  final GameState game;

  const GameHeaderWidget({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _showExitDialog(context);
                },
              ),
              Text(
                _getGameModeTitle(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<GameBloc>().add(const ResetGameEvent());
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: game.players.map((player) {
              final isCurrentPlayer = player.id == game.currentPlayer.id;
              return _buildPlayerCard(
                context,
                player.name,
                player.icon,
                player.score,
                isCurrentPlayer,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(
    BuildContext context,
    String name,
    String icon,
    int score,
    bool isActive,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.white : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _getGameModeTitle() {
    switch (game.mode) {
      case GameMode.onePlayer:
        return 'Vs. Bot';
      case GameMode.twoPlayers:
        return 'Dois Jogadores';
      case GameMode.online:
        return 'Online';
    }
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do Jogo'),
        content: const Text('Deseja realmente sair? O progresso será perdido.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<GameBloc>().add(const ResetGameEvent());
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
