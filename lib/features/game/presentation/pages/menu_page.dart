import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/game_state.dart';
import '../../domain/entities/player.dart';
import '../bloc/game_bloc.dart';
import 'game_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _selectedGridSize = 6;
  final List<int> _gridSizes = [4, 5, 6, 7, 8];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<GameBloc, GameBlocState>(
          listener: (context, state) {
            if (state is GameInProgress) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GamePage()),
              );
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '• • • • •',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 16,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Jogo dos Pontinhos',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 48),
                      if (authState is! Authenticated)
                        _buildPlayerSetup(context)
                      else
                        _buildGameOptions(context, authState.player),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerSetup(BuildContext context) {
    final nameController = TextEditingController();
    final iconController = TextEditingController(text: '😊');

    return Column(
      children: [
        Text(
          'Crie seu perfil',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nome',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: iconController,
          decoration: const InputDecoration(
            labelText: 'Ícone (emoji)',
            border: OutlineInputBorder(),
          ),
          maxLength: 2,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.trim().isNotEmpty) {
              final player = Player(
                id: const Uuid().v4(),
                name: nameController.text.trim(),
                icon: iconController.text.trim().isNotEmpty
                    ? iconController.text.trim()
                    : '😊',
              );
              context.read<AuthBloc>().add(LoginEvent(player));
            }
          },
          child: const Text('Criar Perfil'),
        ),
      ],
    );
  }

  Widget _buildGameOptions(BuildContext context, Player player) {
    return Column(
      children: [
        if (player.name.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    player.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    player.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 32),
        Text(
          'Tamanho do Grid',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          alignment: WrapAlignment.center,
          children: _gridSizes.map((size) {
            final isSelected = size == _selectedGridSize;
            return ChoiceChip(
              label: Text('${size}x$size'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedGridSize = size;
                  });
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _startGame(context, player, GameMode.onePlayer),
            icon: const Icon(Icons.person),
            label: const Text('Jogar contra Bot'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _startGame(context, player, GameMode.twoPlayers),
            icon: const Icon(Icons.people),
            label: const Text('Dois Jogadores'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () {
            context.read<AuthBloc>().add(const LogoutEvent());
          },
          child: const Text('Trocar Perfil'),
        ),
      ],
    );
  }

  void _startGame(BuildContext context, Player player1, GameMode mode) {
    Player? player2;
    if (mode == GameMode.twoPlayers) {
      // Para dois jogadores, criar um segundo player temporário
      // Em uma versão completa, isso poderia ser uma tela de seleção
      player2 = Player(
        id: const Uuid().v4(),
        name: 'Jogador 2',
        icon: '🎮',
      );
    }

    context.read<GameBloc>().add(
          StartGameEvent(
            mode: mode,
            gridSize: _selectedGridSize,
            player1: player1,
            player2: player2,
          ),
        );
  }
}

