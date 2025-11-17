import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/game_bloc.dart';
import '../widgets/game_board_widget.dart';
import '../widgets/game_header_widget.dart';
import '../widgets/game_over_dialog.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<GameBloc, GameBlocState>(
          listener: (context, state) {
            if (state is GameFinished) {
              _showGameOverDialog(context, state.game);
            }
          },
          builder: (context, state) {
            if (state is GameLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is GameInProgress) {
              return Column(
                children: [
                  GameHeaderWidget(game: state.game),
                  Expanded(
                    child: GameBoardWidget(game: state.game),
                  ),
                ],
              );
            }

            if (state is GameFinished) {
              return Column(
                children: [
                  GameHeaderWidget(game: state.game),
                  Expanded(
                    child: GameBoardWidget(game: state.game),
                  ),
                ],
              );
            }

            if (state is GameError) {
              return Center(
                child: Text('Erro: ${state.message}'),
              );
            }

            return const Center(
              child: Text('Inicialize um jogo'),
            );
          },
        ),
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, dynamic game) {
    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => GameOverDialog(game: game),
      );
    });
  }
}
