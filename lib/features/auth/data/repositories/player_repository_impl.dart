import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/player_repository.dart';
import '../../../game/domain/entities/player.dart';
import '../../../../core/error/failures.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  final SharedPreferences sharedPreferences;
  static const String _playerKey = 'current_player';

  PlayerRepositoryImpl(this.sharedPreferences);

  @override
  Future<Either<Failure, Player?>> getCurrentPlayer() async {
    try {
      final playerJson = sharedPreferences.getString(_playerKey);
      if (playerJson == null) {
        return const Right(null);
      }

      final playerMap = json.decode(playerJson) as Map<String, dynamic>;
      final player = Player(
        id: playerMap['id'],
        name: playerMap['name'],
        icon: playerMap['icon'],
      );

      return Right(player);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> savePlayer(Player player) async {
    try {
      final playerMap = {
        'id': player.id,
        'name': player.name,
        'icon': player.icon,
      };

      await sharedPreferences.setString(_playerKey, json.encode(playerMap));
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearPlayer() async {
    try {
      await sharedPreferences.remove(_playerKey);
      return const Right(null);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
