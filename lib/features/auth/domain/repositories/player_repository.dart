import 'package:dartz/dartz.dart';
import '../../../game/domain/entities/player.dart';
import '../../../../core/error/failures.dart';

abstract class PlayerRepository {
  Future<Either<Failure, Player?>> getCurrentPlayer();
  Future<Either<Failure, void>> savePlayer(Player player);
  Future<Either<Failure, void>> clearPlayer();
}
