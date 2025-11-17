abstract class Failure {
  final String message;
  const Failure(this.message);
}

class InvalidMoveFailure extends Failure {
  const InvalidMoveFailure(String message) : super(message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(String message) : super(message);
}

