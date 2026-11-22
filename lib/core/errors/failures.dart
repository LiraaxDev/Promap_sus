/// Exceções do aplicativo PROMAP-SUS (tratamento de falhas - lib/core/errors).
abstract class PromapException implements Exception {
  const PromapException(this.mensagem);
  final String mensagem;

  @override
  String toString() => '$runtimeType: $mensagem';
}

class ValidacaoException extends PromapException {
  const ValidacaoException(super.mensagem);
}

class PersistenciaException extends PromapException {
  const PersistenciaException(super.mensagem);
}

class LocalizacaoException extends PromapException {
  const LocalizacaoException(super.mensagem);
}

class ConfiguracaoException extends PromapException {
  const ConfiguracaoException(super.mensagem);
}
