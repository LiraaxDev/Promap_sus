/// Espelha `TB_FILA_SINCRONIZACAO` (Transactional Outbox).
class ItemFilaSincronizacao {
  const ItemFilaSincronizacao({
    required this.idItem,
    required this.tabelaOrigem,
    required this.idRegistroLocal,
    required this.payloadJson,
    required this.statusEnvio,
    required this.timestampCriacao,
  });

  static const statusPendente = 'PENDENTE';
  static const statusSincronizado = 'SINCRONIZADO';

  final int idItem;
  final String tabelaOrigem;
  final int idRegistroLocal;
  final String payloadJson;
  final String statusEnvio;
  final DateTime timestampCriacao;
}

/// Pacote entregue à porta ISyncApiAdapter.
class PacoteSincronizacao {
  const PacoteSincronizacao({
    required this.idItem,
    required this.tabelaOrigem,
    required this.idRegistroLocal,
    required this.payloadJson,
    required this.hashSha256,
  });

  final int idItem;
  final String tabelaOrigem;
  final int idRegistroLocal;
  final String payloadJson;

  /// SHA-256 (hex) de [payloadJson].
  final String hashSha256;
}

class ResultadoEnvio {
  const ResultadoEnvio.sucesso()
      : sucesso = true,
        mensagem = null;
  const ResultadoEnvio.falha(this.mensagem) : sucesso = false;

  final bool sucesso;
  final String? mensagem;
}
