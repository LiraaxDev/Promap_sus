import 'package:promap_sus/features/cartografia_territorial/domain/entities/item_fila_sincronizacao.dart';

abstract class ISyncApiAdapter {
  /// Envia um pacote do Outbox ao servidor (ou ao simulador local).
  /// Não deve lançar exceção para falhas previsíveis de rede: retorna
  /// [ResultadoEnvio.falha].
  Future<ResultadoEnvio> enviar(PacoteSincronizacao pacote);
}
